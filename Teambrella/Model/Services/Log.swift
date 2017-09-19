//
//  Log.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 19.09.2017.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

func log(_ string: String, type: Log.LogType) {
    #if DEBUG
    service.log.logPrint(string, type: type)
    #endif
}

class Log {
    enum LogLevel {
        case critical
        case minimal
        case normal
        case detailed
        
        case server
        case socket
        case push
        case facebook
        
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
        
        static var all: LogType { return LogType(rawValue: Int.max) }
    }
    
    let logLevel: LogLevel
    lazy var types: LogType = { self.typesFor(level: self.logLevel) }()
    
    var isEmojied: Bool = true
    
    init(logLevel: LogLevel) {
        self.logLevel = logLevel
    }
    
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
        return emojis + " " + string
    }
    
    private func typesFor(level: LogLevel) -> LogType {
        switch level {
        case .critical: return [.error]
        case .minimal: return [.error, .serverURL, .serviceInfo]
        case .normal: return [.error, .serverURL, .serviceInfo, .requestBody, .socket, .push]
        case .detailed: return [.error, .serverURL, .serviceInfo, .serverReply, .requestBody, .socket, .push]
        case .server: return [.serverURL, .requestBody, .serverReply]
        case .socket: return [.socket, .error]
        case .push: return [.push, .error]
        case .facebook: return [.social, .error]
        case .all: return LogType.all
        }
    }
    
}
