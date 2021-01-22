//
//  File.swift
//
//
//  Created by Marius Ilie on 21/01/2021.
//

import Foundation
import Vapor
import BogusApp_Common_Models

// It is required for Linux environments to use Type(contentsOf:)
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

enum ApiError: Error {
    case code(HTTPStatus)
}

class ChannelsApi {
    static func fetchChannelsByNames(_ names: [String], client: Client) -> EventLoopFuture<[BogusApp_Common_Models.Channel]> {
        let queryItems = names.map { URLQueryItem(name: "name", value: $0) }
        var fakeUrl = URLComponents(string: "localhost")!
        fakeUrl.queryItems = queryItems
        return fetch(path: "search", query: fakeUrl.query ?? "", client: client)
    }
    
    static func fetchChannelsByIds(_ ids: [UUID], client: Client) -> EventLoopFuture<[BogusApp_Common_Models.Channel]> {
        let queryItems = ids.map { URLQueryItem(name: "id", value: $0.uuidString) }
        var fakeUrl = URLComponents(string: "localhost")!
        fakeUrl.queryItems = queryItems
        return fetch(query: fakeUrl.query ?? "", client: client)
    }
    
    static func createChannels(_ channels: [BogusApp_Common_Models.Channel], client: Client) -> EventLoopFuture<[BogusApp_Common_Models.Channel]> {
        return fetch(method: .POST, body: try? JSONEncoder().encode(channels), client: client)
    }
    
    // Helpers
    
    static func fetch<T: Decodable>(service: Microservices = .channels,
                                    path: String = "",
                                    query: String? = nil,
                                    method: HTTPMethod = .GET,
                                    headers: HTTPHeaders = .init([("Content-Type", "application/json")]),
                                    body: Data? = nil,
                                    client: Client) -> EventLoopFuture<T> {
        var url = URI(string: service.host ?? "")
        url.path = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        url.query = query?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let request = ClientRequest(method: method, url: url, headers: headers, body: body != nil ? ByteBuffer(data: body!) : nil)
        return client
            .send(request)
            .flatMapAlways { result -> EventLoopFuture<T> in
                switch result {
                case .success(let success):
                    do {
                        var data = Data()
                        data.append(contentsOf: success.body!.readableBytesView)
                        if success.status == .ok, let data = success.body {
                            let object = try JSONDecoder().decode(T.self, from: data)
                            return client.eventLoop.makeSucceededFuture(object)
                        } else {
                            return client.eventLoop.makeFailedFuture(ApiError.code(success.status))
                        }
                    } catch {
                        return client.eventLoop.makeFailedFuture(error)
                    }
                case .failure(let error):
                    let future: EventLoopFuture<T> = client.eventLoop.makeFailedFuture(error)
                    return future
                }
            }
    }
}
