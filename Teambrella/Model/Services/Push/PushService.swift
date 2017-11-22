//
//  PushService.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 31.08.17.
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

import UIKit
import UserNotifications

class PushService: NSObject {
    var token: Data?
    var tokenString: String? {
        guard let token = token else { return nil }
        
        return [UInt8](token).reduce("") { $0 + String(format: "%02x", $1) }
    }
    var command: RemoteCommand?
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func askPermissionsForRemoteNotifications(application: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    application.registerForRemoteNotifications()
                } else {
                    log("User Notification permission denied: \(String(describing: error))", type: [.error, .push])
                    service.error.present(error: error)
                }
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        token = deviceToken
        log("Did register for remote notifications with token \(tokenString ?? "nil")", type: .push)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        log("Failed to register for remote notifications: \(error)", type: [.error, .push])
        service.error.present(error: error)
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            log("Notification settings: \(settings)", type: [.push, .serviceInfo])
        }
    }
    
    func remoteNotificationOnStart(in application: UIApplication,
                                   userInfo: [AnyHashable: Any]) {
        guard let payloadDict = userInfo["Payload"] as? [AnyHashable: Any] else { return }
        
        let payload = RemotePayload(dict: payloadDict)
        self.command = RemoteCommand.command(from: payload)
    }
    
    func remoteNotification(in application: UIApplication,
                            userInfo: [AnyHashable: Any],
                            completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let aps = userInfo["aps"] as? [AnyHashable: Any], let content = aps["content-available"] as? Bool {
            if content == true {
                print("Content is available")
                service.teambrella.startUpdating()
            }
        }
        guard command == nil else { return }
        guard let payloadDict = userInfo["Payload"] as? [AnyHashable: Any] else { return }
        
        log("\(userInfo)", type: .push)
        let payload = RemotePayload(dict: payloadDict)
        self.command = RemoteCommand.command(from: payload)
        executeCommand()
    }
    
    func executeCommand() {
        guard let command = command else { return }
        
        switch command {
        case let .newTeammate(teamID: _,
                              userID: _,
                              teammateID: teammateID,
                              name: _,
                              avatar: _,
                              teamName: _):
            service.router.presentMemberProfile(teammateID: String(teammateID))
        case .privateMessage:
            showPrivateMessage(command: command)
        case let .walletFunded(teamID: teamID,
                               userID: _,
                               cryptoAmount: _,
                               currencyAmount: _,
                               teamLogo: _,
                               teamName: _):
            showWalletFunded(teamID: teamID)
        case let .topicMessage(topicID: _,
                               topicName: _,
                               userName: _,
                               avatar: _, details: details):
            showTopic(details: details)
        default:
            break
        }
        self.command = nil
    }
    
    private func showPrivateMessage(command: RemoteCommand) {
        service.router.presentPrivateMessages()
        if let user = PrivateChatUser(remoteCommand: command) {
            let context = ChatContext.privateChat(user)
            service.router.presentChat(context: context, itemType: .privateChat, animated: false)
        }
    }
    
    private func showWalletFunded(teamID: Int) {
        if let session = service.session {
            if let team = session.currentTeam, team.teamID != teamID {
                for team in session.teams where team.teamID == teamID {
                    service.session?.switchToTeam(id: teamID)
                    service.router.switchTeam()
                    break
                }
            }
        }
        service.router.switchToWallet()
    }
    
    private func showTopic(details: RemoteTopicDetails?) {
        if let details = details as? RemotePayload.Claim {
            service.router.switchToFeed()
            service.router.presentClaims(animated: false)
            service.router.presentClaim(claimID: details.claimID, animated: false)
            service.router.presentChat(context: ChatContext.remote(details), itemType: .claim, animated: false)
        } else if let details = details as? RemotePayload.Teammate {
            service.router.presentMemberProfile(teammateID: details.userID, animated: false)
            service.router.presentChat(context: ChatContext.remote(details), itemType: .teammate, animated: false)
        } else if let details = details as? RemotePayload.Discussion {
            service.router.presentChat(context: ChatContext.remote(details), itemType: .teamChat, animated: false)
        }
    }
    
}

extension PushService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
}
