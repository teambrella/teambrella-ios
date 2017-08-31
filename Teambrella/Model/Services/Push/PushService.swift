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
    
    func askPermissionsForRemoteNotifications(application: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                application.registerForRemoteNotifications()
            } else {
                print("User Notification permission denied: \(String(describing: error))")
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        token = deviceToken
        print("Did register for remote notifications with token \(tokenString ?? "nil")")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
}
