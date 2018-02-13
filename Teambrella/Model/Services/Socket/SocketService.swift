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
    var socket: WebSocket!
    var actions: [AnyHashable: SocketListenerAction] = [:]
    var isConnected: Bool { return socket.isConnected }
    var unsentMessage: String?
    
    init(url: URL?) {
        // swiftlint:disable:next force_unwrapping
        let url = url ?? URL(string: "wss://" + "surilla.com" + "/wshandler.ashx")!
        log("trying to connect to socket: \(url.absoluteString)", type: .socket)
        socket = WebSocket(url: url)
        
        service.dao.freshKey { key in
            let application = Application()
            self.socket.headers["t"] = String(key.timestamp)
            self.socket.headers["key"] = key.publicKey
            self.socket.headers["sig"] = key.signature
            self.socket.headers["clientVersion"] = application.clientVersion
            self.socket.headers["deviceToken"] = service.push.tokenString ?? ""
            self.socket.headers["deviceId"] = application.uniqueIdentifier
            self.socket.connect()
        }
        socket.delegate = self
    }
    
    convenience init() {
        self.init(url: nil)
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
    func websocketDidConnect(socket: WebSocket) {
        log("connected", type: .socket)
        if let message = unsentMessage {
            send(string: message)
            unsentMessage = nil
        } else {
            auth()
        }
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        log("received data: \(data)", type: .socket)
        parse(data: data)
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        log("disconnected", type: .socket)
        if let error = error {
            log("disconnected with error: \(error)", type: [.error, .socket])
        }
        // start()
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        log("received: \(text)", type: .socket)
        guard let data = text.data(using: .utf8) else {
            log("Failed to create data from websocket string", type: [.error, .socket])
            return
        }
        
        parse(data: data)
    }
}
