//
//  SocketData.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 11.09.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

enum SocketData {
    case auth
    case newPost(teamID: Int,
        userID: String,
        topicID: String,
        postID: String,
        name: String,
        url: String,
        text: String)
    case deletePost(teamID: Int,
        userID: String,
        topicID: String,
        postID: String)
    case meTyping(teamID: Int,
        topicID: String,
        name: String)
    case newClaim(teamID: Int,
        userID: String,
        claimID: String,
        name: String,
        url: String,
        amount: Double,
        teamURL: String,
        teamName: String)
    case privateMessage(userID: String,
        name: String,
        url: String,
        text: String)
    case walletFunded(teamID: Int,
        userID: String,
        newAmount: Double,
        fiatAmount: String,
        teamURL: String,
        teamName: String)
    case newMessages(count: Int)
    case theyTyping(teamID: Int,
        userID: String,
        topicID: String,
        name: String)
    
    var stringValue: String {
        var strings: [String] = [String(command.rawValue)]
        switch self {
        case .auth:
            break
        default:
            let mirror = Mirror(reflecting: self)
            if let child = mirror.children.first {
                let tuple = Mirror(reflecting: child.value)
                for item in tuple.children {
                    strings.append("\(item.value)")
                }
            }
        }
        return strings.joined(separator: ";")
    }
    
    var command: SocketCommand {
        switch self {
        case .auth:
            return .auth
        case .newPost(teamID: _, userID: _, topicID: _, postID: _, name: _, url: _, text: _):
            return .newPost
        case .deletePost(teamID: _, userID: _, topicID: _, postID: _):
            return .deletePost
        case .meTyping(teamID: _, topicID: _, name: _):
            return .meTyping
        case .newClaim(teamID: _, userID: _, claimID: _, name: _, url: _, amount: _, teamURL: _, teamName: _):
            return .newClaim
        case .privateMessage(userID: _, name: _, url: _, text: _):
            return .privateMessage
        case .walletFunded(teamID: _, userID: _, newAmount: _, fiatAmount: _, teamURL: _, teamName: _):
            return .walletFunded
        case .newMessages(count: _):
            return .newMessages
        case .theyTyping(teamID: _, userID: _, topicID: _, name: _):
            return .theyTyping
        }
    }
    
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    static func with(command: SocketCommand, components: [String]) -> SocketData? {
        switch command {
        case .auth:
            return .auth
        case .newPost:
            if components.count > 7,
                let teamID = Int(components[1]) {
                return .newPost(teamID: teamID,
                                userID: components[2],
                                topicID: components[3],
                                postID: components[4],
                                name: components[5],
                                url: components[6],
                                text: components[7])
            }
        case .deletePost:
            if components.count > 4, let teamID = Int(components[1]) {
                return .deletePost(teamID: teamID, userID: components[2], topicID: components[3], postID: components[4])
            }
        case .meTyping:
            if components.count > 3, let teamID = Int(components[1]) {
                return .meTyping(teamID: teamID, topicID: components[2], name: components[3])
            }
        case .newClaim:
            if components.count > 8,
                let teamID = Int(components[1]),
                let amount = Double(components[6]) {
                return .newClaim(teamID: teamID,
                                 userID: components[2],
                                 claimID: components[3],
                                 name: components[4],
                                 url: components[6],
                                 amount: amount,
                                 teamURL: components[7],
                                 teamName: components[8])
            }
        case .privateMessage:
            if components.count > 4 {
                return .privateMessage(userID: components[1],
                                       name: components[2],
                                       url: components[3],
                                       text: components[4])
            }
        case .walletFunded:
            if components.count > 6, let teamID = Int(components[1]), let newAmount = Double(components[3]) {
                return .walletFunded(teamID: teamID,
                                     userID: components[2],
                                     newAmount: newAmount,
                                     fiatAmount: components[4],
                                     teamURL: components[5],
                                     teamName: components[6])
            }
        case .newMessages:
            if components.count > 1, let count = Int(components[1]) {
                return .newMessages(count: count)
            }
        case .theyTyping:
            if components.count > 4, let teamID = Int(components[1]) {
                return .theyTyping(teamID: teamID,
                                   userID: components[2],
                                   topicID: components[3],
                                   name: components[4])
            }
        }
        return nil
    }
    
}
