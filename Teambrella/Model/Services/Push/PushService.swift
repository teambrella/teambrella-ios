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
