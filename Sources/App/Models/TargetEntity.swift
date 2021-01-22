import Fluent
import Vapor
import BogusApp_Common_Models

final class TargetEntity: Model, Content {
    static let schema = "targets"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "title")
    var title: String
    
    @Children(for: \.$target)
    var channels: [TargetChannelEntity]
        
    var channelIds: [UUID] { $channels.wrappedValue.map { $0.channelId } }

    init() { }
    
    init(_ target: TargetSpecific) {
        self.id = target.id
        self.title = target.title
    }

    init(id: UUID, title: String) {
        self.id = id
        self.title = title
    }
    
    func convert(linking channels: [BogusApp_Common_Models.Channel]) -> TargetSpecific {
        let channels = channels.orderedSet
        return .init(id: id ?? UUID(), title: title, channels: channels.filter { channelIds.contains($0.id) })
    }
}

extension TargetSpecific: Content { }
