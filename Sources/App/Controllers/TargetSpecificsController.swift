import Fluent
import Vapor
import BogusApp_Common_Models

struct TargetSpecificsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let targets = routes.grouped("")
        targets.post(use: create)
        targets.post(":targetId", "channels", use: insertChannel)
        targets.get(use: index)
    }
    
    // GET

    func index(req: Request) throws -> EventLoopFuture<[TargetSpecific]> {
        let query = (try? req.query.get(at: "id")) ?? [UUID]()
        let name: String? = try? req.query.get(at: "name")
        return fetchTargets(query, name, req.client, req.db, req.eventLoop)
    }
    
    // POST
    
    func create(req: Request) throws -> EventLoopFuture<TargetSpecific> {
        let target = try req.content.decode(TargetSpecific.self)
        return insertTarget(target, req.client, req.db, req.eventLoop)
    }
    
    // Helpers
    // Todo: Move this code into some repository
    
    func fetchTargets(_ ids: [UUID] = [], _ name: String? = nil, _ client: Client, _ db: Database, _ eventLoop: EventLoop) -> EventLoopFuture<[TargetSpecific]> {
        TargetEntity
            .query(on: db)
            .with(\.$channels)
            .all()
            .mapEachCompact { (ids.isEmpty || ids.contains($0.id!)) && ($0.title == name || name == nil) ? $0 : nil } // Filter by name and ids
            .flatMapEach(on: eventLoop) { target in
                ChannelsApi
                    .fetchChannelsByIds(target.channelIds, client: client) // Fetch channels from Channels microservice
                    .map { target.convert(linking: $0) } // Return common TargetSpecific model including channels
            }
    }
    
    func insertTarget(_ target: TargetSpecific, _ client: Client, _ db: Database, _ eventLoop: EventLoop) -> EventLoopFuture<TargetSpecific> {
        TargetEntity(target).save(on: db) // Try to save channel
            .flatMapAlways { _ in
                TargetEntity.query(on: db) // Fetch saved channel
                    .filter(.string("title"), .equal, target.title)
                    .with(\.$channels)
                    .first()
            }.flatMap { targetEntity in
                ChannelsApi
                    .createChannels(target.channels, client: client) // Create channels for plan
                    .flatMap { channels in
                        channels.map {
                            TargetChannelEntity(targetEntity!.id!, $0.id).save(on: db) // Save target-channel association in db
                        }.flatten(on: eventLoop)
                        .map { targetEntity!.convert(linking: channels) } // Return common Plan model
                    }
            }
    }
    
    func insertChannel(req: Request) throws -> EventLoopFuture<TargetSpecific> {
        guard let idStr = req.parameters.get("targetId"), let targetId = UUID.init(uuidString: idStr) else {
            throw Abort(.notFound)
        }
        let channel = try req.content.decode(BogusApp_Common_Models.Channel.self)
        return TargetEntity
            .query(on: req.db)
            .filter(.id, .equal, targetId)
            .first()
            .flatMap { target -> EventLoopFuture<[BogusApp_Common_Models.Channel]> in
                if target == nil {
                    return req.eventLoop.makeFailedFuture(ApiError.code(.notFound)) // Error if there is no target with id
                } else {
                    return ChannelsApi.createChannels([channel], client: req.client) // Get already saved channels if target exists
                }
            }
            .mapEachCompact { TargetChannelEntity(targetId, $0.id).save(on: req.db) }
            .flatMap { _ in
                TargetEntity
                    .query(on: req.db)
                    .filter(.id, .equal, targetId)
                    .all()
            }.flatMap { _ in self.fetchTargets([targetId], nil, req.client, req.db, req.eventLoop) }
            .map { $0.first! }
    }
}
