import Foundation
import Fluent
import BogusApp_Common_Models
import BogusApp_Common_MockDataProvider
import Vapor

struct InsertMockData: Migration {
    private weak var app: Application!
    
    // TODO: move code from controller into a repository to avoid this kind of code
    private var targetsController = TargetSpecificsController()
    
    init(app: Application) {
        self.app = app
    }
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        MockData.fetch()!.convert()
            .map { targetsController.insertTarget($0, app.client, database, app.client.eventLoop) }
            .flatten(on: database.eventLoop)
            .transform(to: ())
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return TargetEntity.query(on: database).delete()
    }
}
