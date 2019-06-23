//
//  TeambrellaRequest.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 29.03.17.

/* Copyright(C) 2017  Teambrella, Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License(version 3) as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see<http://www.gnu.org/licenses/>.
 */

import ExtensionsPack

private var decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(DateFormatter.teambrella)
    decoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: "PositiveInfinity",
                                                                    negativeInfinity: "NegativeInfinity",
                                                                    nan: "NaN")
    return decoder
}()

struct TeambrellaGetRequest<Value: Decodable> {
    let type: TeambrellaGetRequestType
    var parameters: [String: String]
    let success: (Value) -> Void
    var failure: ((Error) -> Void)?
    
    func start(server: ServerService) {
        server.get(string: type.rawValue, parameters: parameters, success: self.parseReply, failure: self.handleError)
    }
    
    func parseReply(data: Data) {
        do {
            let value = try decoder.decode(Value.self, from: data)
            success(value)
        } catch {
            handleError(error: error)
        }
    }
    
    func handleError(error: Error) {
        failure?(error)
    }
}

struct TeambrellaRequest<Value: Decodable> {
    let type: TeambrellaPostRequestType
    var parameters: [String: String]?
    let body: RequestBody
    let success: (ServerReplyBox<Value>) -> Void
    let failure: (Error) -> Void
    var suffix: String? = nil
    
    private var requestString: String {
        let value: String
        if let suffix = suffix {
            value = type.rawValue + "/" + suffix
        } else {
            value = type.rawValue
        }
        return value
    }
    
    init(type: TeambrellaPostRequestType,
         parameters: [String: String]? = nil,
         body: RequestBody,
         success: @escaping (ServerReplyBox<Value>) -> Void,
         failure: @escaping (Error) -> Void) {
        self.type = type
        self.parameters = parameters
        self.body = body
        self.success = success
        self.failure = failure
    }
    
    func start(server: ServerService, isErrorAutoManaged: Bool = true) {
        server.ask(for: requestString, parameters: parameters, body: body, success: { reply in
            self.parseReply(server: server, reply: reply)
        }, failure: { error in
            log("\(error)", type: [.error, .serverReply])
            if isErrorAutoManaged {
                service.error.present(error: error, retry: nil)
            }
            self.failure(error)
        })
    }
    
    private func printRawReply(data: Data) {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            log("Raw json object: \(json)", type: .serverReply)
        } catch {
            log("Error printing raw json: \(error)", type: .error)
        }
    }
    
    private func parseReply(server: ServerService, reply: Data) {
        #if DEBUG
        printRawReply(data: reply)
        #endif
        
        do {
            let box = try decoder.decode(ServerReplyBox<Value>.self, from: reply)
            log("Boxed reply: \(box)", type: .serverReplyStats)
            server.timestamp = box.status.timestamp
            let manager = SODManager(router: service.router)
            manager.checkVersion(serverStatus: box.status)
            if box.status.isError {
                failure(TeambrellaErrorFactory.error(with: box.status))
            } else {
                success(box)
            }
            Log.shared.configureLogstash(with: box.status)
        } catch {
            failure(error)
        }
    }
    
}
