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

struct SocketAction: CustomStringConvertible {
    let command: SocketCommand
    let teamID: Int
    let teammateID: Int
    let topicID: String?
    
    var description: String { return "Socket action: \(command); team: \(teamID); teammate: \(teammateID)" }
    var socketString: String { return "\(command.rawValue);\(teamID);\(teammateID)" }
    
    init?(string: String) {
        let array = string.components(separatedBy: ";")
        guard array.count >= 3,
            let command = SocketCommand(rawValue: Int(array[0]) ?? -1),
            let teamID = Int(array[1]) else {
                return nil
        }
        
        self.command = command
        self.teamID = teamID
        self.teammateID = Int(array[2]) ?? 0
        self.topicID = array.count > 3 ? array[3] : nil
    }
    
    init(command: SocketCommand, teamID: Int, teammateID: Int, topicID: String? = nil) {
        self.command = command
        self.teamID = teamID
        self.teammateID = teammateID
        self.topicID = topicID
    }
    
}

enum SocketCommand: Int {
    case auth = 0
    case post = 1
    case deletePost = 2
    case typing = 3
}

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
    
    func auth(teamID: Int, teammateID: Int) {
        let action = SocketAction(command: .auth, teamID: teamID, teammateID: teammateID)
        send(action: action)
    }
    
    func typing(teamID: Int, teammateID: Int) {
        let action = SocketAction(command: .typing, teamID: teamID, teammateID: teammateID)
        send(action: action)
    }
    
}

extension SocketService: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocket) {
        print("🔄 connected")
        if let message = unsentMessage {
            send(string: message)
            unsentMessage = nil
        } else if let teamID = service.session?.currentTeam?.teamID,
            let teammateID = service.session?.currentUserTeammateID {
            auth(teamID: teamID, teammateID: teammateID)
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
