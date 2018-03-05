//
//  SocketAction.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 11.09.17.
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
//

import Foundation

struct SocketAction: CustomStringConvertible {
    let command: SocketCommand
    let data: SocketData
    
    var description: String { return "Socket action: \(command); data: \(data.stringValue)" }
    var socketString: String { return data.stringValue }
    
    init?(data: Data) {
        do {
            guard let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                return nil
            }
            guard let commandValue = dict["Cmd"] as? Int else { return nil }
            guard let command = SocketCommand(rawValue: commandValue) else { return nil }
            guard let data = SocketData.with(command: command, dict: dict) else { return nil }

            self.command = command
            self.data = data

        } catch {
            log("Error initializing \(type(of: self)): \(error)", type: .error)
            return nil
        }
    }

    /*
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
    */
    
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
