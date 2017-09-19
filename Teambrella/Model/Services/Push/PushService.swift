//
//  PushService.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 31.08.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit
import UserNotifications

class PushService {
    var token: Data?
    var tokenString: String? {
        guard let token = token else { return nil }
        
        return [UInt8](token).reduce("") { $0 + String(format: "%02x", $1) }
    }
    var command: PushCommand?
    
    func askPermissionsForRemoteNotifications(application: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    application.registerForRemoteNotifications()
                } else {
                    log("User Notification permission denied: \(String(describing: error))", type: [.error, .push])
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
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            log("Notification settings: \(settings)", type: [.push, .serviceInfo])
        }
    }
    
    func remoteNotificationOnStart(in application: UIApplication,
                                   userInfo: [AnyHashable : Any]) {
        let pushData = PushData(dict: userInfo)
        self.command = pushData.command
    }
    
    func remoteNotification(in application: UIApplication,
                            userInfo: [AnyHashable : Any],
                            completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard command == nil else { return }
        
        log("\(userInfo)", type: .push)
        let pushData = PushData(dict: userInfo)
        self.command = pushData.command
        executeCommand()
    }
    
    func executeCommand() {
        guard let command = command else { return }
        
        switch command {
        case let .openClaim(id: id):
            service.router.presentClaim(claimID: id)
        default:
            break
        }
        self.command = nil
    }
}

struct PushData {
    let dict: [AnyHashable: Any]
    var aps: [String: Any] { return dict["aps"] as? [String : Any] ?? [:] }
    var body: String? { return (aps["alert"] as? [String: String])?["body"] }
    var title: String? { return (aps["alert"] as? [String: String])?["title"] }
    var badge: Int { return aps["badge"] as? Int ?? 0 }
    var isContentAvailable: Bool { return aps["content-available"] as? Bool ?? false }
    var command: PushCommand? { return PushCommand.with(dict: dict["cmd"] as? [String: Any]) }
}

enum PushCommand {
    case openClaim(id: String)
    case openChat(id: String)
    case openPrivateChat(userID: Int)
    
    static func with(dict: [String: Any]?) -> PushCommand? {
        guard let dict = dict else { return nil }
        guard let type = dict["type"] as? Int else { return nil }
        
        if type == 1, let claimID = dict["claimID"] as? String {
            return .openClaim(id: claimID)
        }
        return nil
    }
}
