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

import Firebase
import UIKit
import UserNotifications

final class PushService: NSObject {
    var token: Data?
    var tokenString: String? {
        return currentFirebaseToken
    }
    var apnsTokenString: String? {
        guard let token = token else { return nil }

        return [UInt8](token).reduce("") { $0 + String(format: "%02x", $1) }
    }

    var listeners: [AnyHashable: (RemoteCommandType, [AnyHashable: Any]) -> Bool] = [:]

    var command: RemotePayload?
    
    var router: MainRouter { return service.router }
    var session: Session? { return service.session }
    var teambrella: TeambrellaService { return service.teambrella }

    var currentFirebaseToken: String?

    lazy var pushKit: PushKitWorker = {
        let pushKit = PushKitWorker()
        return pushKit
    }()
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self

        // Firebase
        Messaging.messaging().delegate = self
    }

    func addListener(_ listener: AnyHashable, handler: @escaping (RemoteCommandType, [AnyHashable: Any]) -> Bool) {
        listeners[listener] = handler
    }

    func removeListener(_ listener: AnyHashable) {
        listeners[listener] = nil
    }

    func startPushKit() {
        self.pushKit.onTokenUpdate = { token in
            print("PushKit token: \(token)")
        }
        pushKit.onPushReceived = { [weak self] dict, completion in
            guard let cmd = dict["cmd"] as? String, let command = PushKitCommand(rawValue: cmd) else {
                print("No command found in PushKit dictionary: \(dict)")
                Statistics.log(event: .voipPushWrongPayload, dict: dict as? [String: Any])
                return
            }
            
            Statistics.log(event: .voipPushReceived, dict: dict as? [String: Any])
            print("got cmd string: \(cmd), command: \(command)")
            switch command {
            case .getUpdates:
                self?.teambrella.startUpdating { result in
                    print("PushKit has finished it's job")
                    completion()
                }
            case .getDatabaseDump:
                self?.teambrella.sendDBDump { success in
                    completion()
                }
            }
        }
    }

    func presentPushKitUserNotification(dict: [AnyHashable: Any]) {
        let state = UIApplication.shared.applicationState

        let content = UNMutableNotificationContent()

        content.title = "PushKit. App state: \(state.rawValue)"
        content.body = dict.description
        content.categoryIdentifier = "notify-test"

        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest.init(identifier: "notify-test", content: content, trigger: trigger)

        let center = UNUserNotificationCenter.current()
        center.add(request)
    }

    func askPermissionsForRemoteNotifications(application: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                // moved token register to AppDelegate
                //application.registerForRemoteNotifications()
                if !granted {
                    log("User Notification permission denied: \(String(describing: error))", type: [.error, .push])
                    //service.error.present(error: error)
                }
            }
        }
    }

    func register(application: UIApplication) {
        application.registerForRemoteNotifications()
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        token = deviceToken
        log("Did register for remote notifications with firebase token \(tokenString ?? "nil")", type: .push)
        log("apns token \(apnsTokenString ?? "nil")", type: .push)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        log("Failed to register for remote notifications: \(error)", type: [.error, .push])
        service.error.present(error: error)
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            log("Notification settings: \(settings)", type: [.push, .info])
        }
    }
    
    func remoteNotificationOnStart(in application: UIApplication,
                                   userInfo: [AnyHashable: Any]) {
        prepareCommand(userInfo: userInfo)
    }
    
    func remoteNotification(in application: UIApplication,
                            userInfo: [AnyHashable: Any],
                            completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let aps = userInfo["aps"] as? [AnyHashable: Any], let content = aps["content-available"] as? Bool {
            if content == true {
                log("Content is available: \(userInfo)", type: .push)
                service.teambrella.startUpdating(completion: { result in
                    log("Remote notification get updetes result is: \(result)", type: .push)
                })
            }
        }
        //guard command == nil else { return }

        prepareCommand(userInfo: userInfo)
        executeCommand()
    }

    private func prepareCommand(userInfo: [AnyHashable: Any]) {
        guard let payloadDict = userInfo["Payload"] as? [AnyHashable: Any] else { return }
        guard let apsDict = userInfo["aps"] as? [AnyHashable: Any] else { return }

        log("\(userInfo)", type: .push)
        let aps = APS(dict: apsDict)
        let payload = RemotePayload(dict: payloadDict)
        self.command = payload

        clearNotificationsThread(id: aps.threadID)
    }
    
    func executeCommand() {
        guard let command = command else {
            print("No remote command to execute")
            return
        }

        router.popToBase()

        let type = command.type
        switch type {
        case .newTeammate:
            router.presentMemberProfile(teammateID: String(command.teammateIDValue))
        case .privateMessage:
            showPrivateMessage(command: command)
        case .walletFunded:
            showWalletFunded(teamID: command.teamIDValue)
        case .topicMessage:
            showTopic(details: command.topicDetails)
        case .newClaim:
            showTopic(details: command.topicDetails)
        //showNewClaim(teamID: command.teamIDValue, claimID: command.claimIDValue)
        case .approvedTeammate:
            logAsApprovedMember(payload: command)
        default:
            break
        }
        self.command = nil
    }

    private func logAsApprovedMember(payload: RemotePayload) {
        log("Trying to log in as a new member of: \(payload.teamNameValue) team", type: .push)
        if let session = service.session {
            if let currentTeamID = session.currentTeam?.teamID, currentTeamID == payload.teamIDValue {
                log("Already logged into the team \(payload.teamNameValue). No action needed", type: .push)
            } else {
                log("Active session found. Trying to switch to the new team", type: .push)
                let router = service.router
                router.logout(mode: .idle) {
                    router.login(teamID: payload.teamID)
                }
            }
        } else {
            log("First login initiated", type: .push)
            service.router.login(teamID: payload.teamID)
        }
    }

    private func clearNotificationsThread(id: String?) {
        guard let id = id else { return }

        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            let ids: [String] = notifications.compactMap { notification in
                if notification.request.content.threadIdentifier == id {
                    return notification.request.identifier
                } else {
                    return nil
                }
            }
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ids)
        }
    }
    
    private func showNewClaim(teamID: Int, claimID: Int) {
        if selectCorrectTeam(teamID: teamID) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                // service.router.switchTeam()
                //                service.router.presentClaims(animated: false)
                service.router.presentClaim(claimID: claimID)
            }
        }
    }
    
    private func showPrivateMessage(command: RemotePayload) {
        //        service.router.presentPrivateMessages()
        if let user = PrivateChatUser(remotePayload: command) {
            let context = ChatContext.privateChat(user)
            service.router.presentChat(context: context, itemType: .privateChat, animated: false)
        }
    }
    
    private func selectCorrectTeam(teamID: Int) -> Bool {
        if let session = service.session {
            if let team = session.currentTeam, team.teamID != teamID {
                for team in session.teams where team.teamID == teamID {
                    service.session?.switchToTeam(id: teamID)
                    service.router.switchTeam()
                    return true
                }
            } else {
                return true
            }
        }
        return false
    }
    
    private func showWalletFunded(teamID: Int) {
        service.router.switchToWallet()
        //        if selectCorrectTeam(teamID: teamID) {
        //        }
    }
    
    private func showTopic(details: RemoteTopicDetails?) {
        if let details = details as? RemotePayload.Claim {
            //            service.router.switchToFeed()
            //            service.router.presentClaims(animated: false)
            //            service.router.presentClaim(claimID: details.claimID, animated: false)
            service.router.presentChat(context: ChatContext.remote(details), itemType: .claim, animated: false)
        } else if let details = details as? RemotePayload.Discussion {
            service.router.presentChat(context: ChatContext.remote(details), itemType: .teamChat, animated: false)
        } else if let details = details as? RemotePayload.Teammate {
            //            service.router.presentMemberProfile(teammateID: details.userID, animated: false)
            service.router.presentChat(context: ChatContext.remote(details), itemType: .teammate, animated: false)
        }
    }
    
}

extension PushService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let dict = notification.request.content.userInfo
        print("userNotificationCenter dict: \(dict)")
        if let payload = dict["Payload"] as? [AnyHashable: Any],
            let commandInt = payload["Cmd"] as? Int,
            let command = RemoteCommandType(rawValue: commandInt) {
            for (_, handler) in listeners {
                // listeners may opt into showing push (sending true) or not
                if handler(command, payload) == false {
                    return
                }
            }
        }
        completionHandler([.alert, .sound, .badge])
    }
}

extension PushService: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        currentFirebaseToken = fcmToken
        print("Firebase token: \(fcmToken)")
    }
}
