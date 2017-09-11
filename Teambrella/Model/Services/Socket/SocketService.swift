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
        print("🔄 trying to connect to socket: \(url.absoluteString)")
        socket = WebSocket(url: url)
        service.storage.freshKey { key in
            self.socket.headers["t"] = String(key.timestamp)
            self.socket.headers["key"] = key.publicKey
            self.socket.headers["sig"] = key.signature
            self.socket.connect()
        }
        socket.delegate = self
    }
    
    convenience init() {
        self.init(url: nil)
    }
    
    func add(listener: AnyHashable, action: @escaping SocketListenerAction) {
        actions[listener] = action
        print("🔄 added listener. ListenersCount: \(actions.count)")
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
        print("🔄 sending action: \(action)")
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
    
}

extension SocketService: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocket) {
        print("🔄 connected")
        if let message = unsentMessage {
            send(string: message)
            unsentMessage = nil
        } else {
            auth()
        }
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        print("🔄 received data: \(data)")
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("🔄 disconnected")
        if let error = error {
            print("with error: \(error)")
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        print("🔄 received: \(text)")
        guard let socketAction = SocketAction(string: text) else { return }
        
        for action in actions.values {
            action(socketAction)
        }
    }
}
