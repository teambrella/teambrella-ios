//
//  SocketService.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 13.06.17.

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

import Starscream

typealias SocketListenerAction = (SocketAction) -> Void

class SocketService {
    struct Constant {
        static let scheme: String = "wss"
        static let path: String = "wshandler.ashx"
        #if SURILLA
        static let serverName: String = "surilla.com"
        #else
         static let serverName: String = "teambrella.com"
        #endif
    }
    
    var socket: WebSocket!
    var actions: [AnyHashable: SocketListenerAction] = [:]
    var isConnected: Bool = false //{ return socket.isConnected }
    var unsentMessage: String?
    var dao: DAO
    
    init(dao: DAO, url: URL?) {
        self.dao = dao
        guard let url = url ?? URL(string: "\(Constant.scheme)://\(Constant.serverName)/\(Constant.path)") else {
            fatalError("Unable to create socket URL")
        }

        log("trying to connect to socket: \(url.absoluteString)", type: .socket)
        dao.freshKey { key in
            let application = Application()
            var request = URLRequest(url: url)
            request.setValue(String(key.timestamp), forHTTPHeaderField: "t")
            request.setValue(key.publicKey, forHTTPHeaderField: "key")
            request.setValue(key.signature, forHTTPHeaderField: "sig")
            request.setValue(application.clientVersion, forHTTPHeaderField: "clientVersion")
            request.setValue(service.push.tokenString ?? "", forHTTPHeaderField: "deviceToken")
            request.setValue(application.uniqueIdentifier, forHTTPHeaderField: "deviceId")
            self.socket = WebSocket(request: request)
            self.socket.delegate = self
            log("connecting with request: \(request)", type: .socket)
            self.socket.connect()
        }
    }
    
    func add(listener: AnyHashable, action: @escaping SocketListenerAction) {
        actions[listener] = action
        log("added listener. ListenersCount: \(actions.count)", type: .socket)
    }
    
    func send(string: String) {
        if isConnected {
            socket.write(string: string)
        } else {
            unsentMessage = string
            start()
        }
    }
    
    func send(action: SocketAction) {
        log("sending action: \(action)", type: .socket)
        send(string: action.socketString)
    }
    
    @discardableResult
    func remove(listener: AnyHashable) -> Bool {
        return actions.removeValue(forKey: listener) != nil
    }
    
    func start() {
        socket.connect()
    }
    
    func stop() {
        socket.disconnect()
    }
    
    func auth() {
        let action = SocketAction(data: .auth)
        send(action: action)
    }
    
    func meTyping(teamID: Int, topicID: String, name: String) {
        let action = SocketAction(data: .meTyping(teamID: teamID, topicID: topicID, name: name))
        send(action: action)
    }
    
    func parse(data: Data) {
        guard let socketAction = SocketAction(data: data) else {
            log("couldn't create socket action from data", type: [.socket, .error])
            return
        }
        
        // send action to subscribers
        for action in actions.values {
            action(socketAction)
        }
    }
    
}

extension SocketService: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isConnected = true
            log("connected", type: .socket)
            if let message = unsentMessage {
                send(string: message)
                unsentMessage = nil
            } else {
                auth()
            }
        case .disconnected(let reason, let code):
            isConnected = false
            log("disconnected with reason: \(reason) and code: \(code)", type: [.socket])
        case .text(let string):
            log("received: \(string)", type: .socket)
            guard let data = string.data(using: .utf8) else {
                log("Failed to create data from websocket string", type: [.error, .socket])
                return
            }
            
            parse(data: data)
        case .binary(let data):
            log("received data: \(data)", type: .socket)
            parse(data: data)
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
//            handleError(error)
        }
    }
}
