import Fluent
import BogusApp_Common_Models
import Vapor

struct CreateTargetChannelAssoc: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("target_channel_assoc")
            .id()
            .field("targetId", .uuid, .required)
            .field("channelId", .uuid, .required)
            .field("createdAt", .datetime, .required)
            .unique(on: "targetId", "channelId")
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("target_channel_assoc").delete()
    }
}
