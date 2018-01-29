//
//  Log.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 19.09.2017.
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

func log(_ string: String, type: Log.LogType) {
    #if DEBUG
    Log.shared.logPrint(string, type: type)
    #endif
}

func log(_ error: Error) {
    #if DEBUG
        if let error = error as? TeambrellaError {
            Log.shared.logPrint(error.description, type: [.error])
        } else {
        Log.shared.logPrint((error as NSError).description, type: [.error])
        }
    #endif
}

class Log {
    enum LogLevel {
        case none
        
        case critical
        case minimal
        case normal
        case detailed
        
        case server
        case socket
        case push
        case facebook

        case crypto
        case cryptoDetailed
        case cryptoAll
        
        case all
    }
    
    struct LogType: OptionSet {
        let rawValue: Int
        
        static let error    = LogType(rawValue: 1 << 0)
        static let serverURL = LogType(rawValue: 1 << 1)
        static let serverReply = LogType(rawValue: 1 << 2)
        static let requestBody = LogType(rawValue: 1 << 3)
        static let socket = LogType(rawValue: 1 << 4)
        static let userInteraction = LogType(rawValue: 1 << 5)
        static let callback = LogType(rawValue: 1 << 6)
        static let serviceInfo =  LogType(rawValue: 1 << 7)
        static let push = LogType(rawValue: 1 << 8)
        static let social = LogType(rawValue: 1 << 9)
        static let crypto = LogType(rawValue: 1 << 10)
        static let cryptoDetails = LogType(rawValue: 1 << 11)
        static let cryptoRequests = LogType(rawValue: 1 << 12)
        static let dataBase = LogType(rawValue: 1 << 13)

        static var all: LogType { return LogType(rawValue: Int.max) }
    }
    
    var logLevel: LogLevel = .cryptoDetailed
    lazy var types: LogType = { self.typesFor(level: self.logLevel) }()
    
    var isEmojied: Bool = true
    
   static let shared = Log()
    
    init() { }
    
    func logPrint(_ string: String, type: LogType) {
        guard types.contains(type) else { return }
        
        if isEmojied {
        print(emojiString(string, type: type))
        } else {
            print(string)
        }
    }
    
    private func emojiString(_ string: String, type: LogType) -> String {
        var emojis = ""
        if type.contains(.error) {
           emojis.append("🛑")
        }
        if type.contains(.requestBody) {
            emojis.append("🌕")
        }
        if type.contains(.serverURL) {
            emojis.append("👉")
        }
        if type.contains(.serverReply) {
            emojis.append("👍")
        }
        if type.contains(.socket) {
            emojis.append("🔄")
        }
        if type.contains(.push) {
            emojis.append("🔔")
        }
        if type.contains(.social) {
            emojis.append("👥")
        }
        if type.contains(.crypto) {
            emojis.append("🔒")
        }
        return emojis + " " + string
    }
    
    //swiftlint:disable:next cyclomatic_complexity
    private func typesFor(level: LogLevel) -> LogType {
        switch level {
        case .none: return []
        case .critical: return [.error]
        case .minimal: return [.error, .serverURL, .serviceInfo, .dataBase]
        case .normal: return [.error, .serverURL, .serviceInfo, .requestBody, .socket, .push, .dataBase]
        case .detailed: return [.error, .serverURL, .serviceInfo, .serverReply, .requestBody, .socket, .push, .dataBase]

        case .server: return [.serverURL, .requestBody, .serverReply]
        case .socket: return [.socket, .error]
        case .push: return [.push, .error]
        case .facebook: return [.social, .error]

        case .crypto: return [.error, .crypto, .dataBase]
        case .cryptoDetailed: return [.error, .crypto, .cryptoDetails, .dataBase]
        case .cryptoAll: return [.error, .crypto, .cryptoDetails, .cryptoRequests, .dataBase]

        case .all: return LogType.all
        }
    }
    
}
