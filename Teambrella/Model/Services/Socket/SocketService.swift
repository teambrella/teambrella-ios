//
//  SocketService.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 13.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Starscream

typealias SocketListenerAction = (String) -> Void

class SocketService {
    var socket: WebSocket!
    var actions: [AnyHashable: SocketListenerAction] = [:]
    var isConnected: Bool { return socket.isConnected }
    var unsentMessage: String?
    
    init(url: URL?) {
        // swiftlint:disable:next force_unwrapping
        let url = url ?? URL(string: "wss://" + "surilla.com" + "/echo2.ashx")!
        print("trying to connect to socket: \(url.absoluteString)")
        socket = WebSocket(url: url)
        socket.delegate = self
    }
    
    convenience init() {
        self.init(url: nil)
    }
    
    func add(listener: AnyHashable, action: @escaping SocketListenerAction) {
        actions[listener] = action
    }
    
    func send(string: String) {
        if isConnected {
            socket.write(string: string)
        } else {
            unsentMessage = string
            start()
        }
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
        socket.write(string: "0;1;16")
    }
}

extension SocketService: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocket) {
        print("Websocket connected")
        if let message = unsentMessage {
            send(string: message)
            unsentMessage = nil
        } else {
            auth()
        }
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        print("Websocket received data: \(data)")
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("Websocket disconnected")
        if let error = error {
            print("with error: \(error)")
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        print("Websocket received string: \(text)")
        for action in actions.values {
            action(text)
        }
    }
}
