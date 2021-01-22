import Fluent
import Vapor
import BogusApp_Common_Models

final class TargetChannelEntity: Model, Content {
    static let schema = "target_channel_assoc"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "targetId")
    var targetId: TargetEntity.IDValue

    @Field(key: "channelId")
    var channelId: UUID
    
    @Parent(key: "targetId")
    var target: TargetEntity
    
    @Field(key: "createdAt")
    var createdAt: Date
    
    init() { }
    
    init(_ targetId: TargetEntity.IDValue, _ channelId: UUID) {
        self.targetId = targetId
        self.channelId = channelId
        self.createdAt = Date()
    }
}
