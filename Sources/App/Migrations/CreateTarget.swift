import Fluent
import BogusApp_Common_Models

struct CreateTargets: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("targets")
            .id()
            .field("title", .string, .required)
            .unique(on: "title")
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("targets").delete()
    }
}
