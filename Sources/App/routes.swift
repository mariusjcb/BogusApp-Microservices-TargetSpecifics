import Fluent
import Vapor

enum Microservices: String, CaseIterable {
    case channels
}

extension Microservices {
    var path: String {
        return rawValue
    }
    
    var host: String? {
        return Environment.get(self.rawValue.uppercased() + "_HOST")
    }
}

func routes(_ app: Application) throws {
    try app.register(collection: TargetSpecificsController())
}
