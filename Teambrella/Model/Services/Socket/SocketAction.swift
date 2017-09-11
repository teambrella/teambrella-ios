//
//  SocketAction.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 11.09.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

struct SocketAction: CustomStringConvertible {
    let command: SocketCommand
    let data: SocketData
    
    var description: String { return "Socket action: \(command); data: \(data.stringValue)" }
    var socketString: String { return data.stringValue }
    
    init?(string: String) {
        let components = string.components(separatedBy: ";")
        guard let first = components.first,
            let intValue = Int(first),
            let command = SocketCommand(rawValue: intValue) else {
                return nil
        }
        guard let data = SocketData.with(command: command, components: components) else {
            return nil
        }
        
        self.init(command: command, data: data)
    }
    
    init?(command: SocketCommand, data: SocketData) {
        guard command == data.command else {
            return nil
        }
        
        self.command = command
        self.data = data
    }
    
    init(data: SocketData) {
        self.command = data.command
        self.data = data
    }
    
}
