//
//  AppDelegate.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 28.03.17.

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

import Auth0
import Fabric
import FBSDKCoreKit
import Firebase
//import FirebaseDynamicLinks
import PushKit
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        // Register for Push here to be able to receive silent notifications even if user will restrict push service
        service.push.register(application: application)
        service.push.startPushKit()

        if let userID = SimpleStorage().string(forKey: .userID) {
            service.sinch.startWith(userID: userID)
        }

        TeambrellaStyle.apply()
        //        if let notification = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
        //            service.push.remoteNotificationOnStart(in: application, userInfo: notification)
        //        }
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)

        // Pull in case of emergency :)
        // service.cryptoMalfunction()

        configureLibs()

        return true
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplicationOpenURLOptionsKey: Any] = [ : ]) -> Bool {
        guard let source = options[.sourceApplication] as? String else {
            print("Failed to get source application from options")
            if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
                 return handle(dynamicLink: dynamicLink)
            }
            return false
        }

        if source.hasPrefix("com.facebook") {
            print("Opening app from Facebook application")
            return FBSDKApplicationDelegate.sharedInstance().application(app,
                                                                         open: url,
                                                                         sourceApplication: source,
                                                                         annotation: options[.annotation])
        } else {
            print("Opening app from Auth0")
            return Auth0.resumeAuth(url, options: options)
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        service.socket?.start()

        if service.session != nil {
            service.teambrella.startUpdating(completion: { result in
                let description = result.rawValue == 0 ? "new data" : result.rawValue == 1 ? "no data" : "failed"
                log("Teambrella service get updates results: \(description)", type: .info)
            })
        }

        let router = service.router
        let info = service.info
        info.prepareServices()
        SODManager(router: router).checkSilentPush(infoMaker: info)

        stitches()
    }

    /// move all users to real group once
    private func stitches() {
        let storage = SimpleStorage()
        if let lastUserType = storage.string(forKey: .lastUserType),
            lastUserType == KeyStorage.LastUserType.real.rawValue {
            return
        }

        if storage.bool(forKey: .didMoveToRealGroup) == false {
            service.router.logout()
            service.keyStorage.setToRealUser()
            storage.store(bool: false, forKey: .didLogWithKey)
            storage.store(bool: true, forKey: .didMoveToRealGroup)
        }
    }

    private func configureLibs() {
        // Add firebase support
        FirebaseApp.configure()
        // Add Crashlytics in debug mode
        #if SURILLA
        Fabric.sharedSDK().debug = true

        // Check how screen rendering is working
        /*
        let link = CADisplayLink(target: self, selector: #selector(AppDelegate.update(link:)))
        link.add(to: .main, forMode: .commonModes)
 */
        #endif
    }

    /*
    var lastTime: TimeInterval = 0
    @objc
    private func update(link: CADisplayLink) {
        if lastTime == 0 {
            lastTime = link.timestamp
        }

        let currentTime = link.timestamp
        let elapsedTime = floor((currentTime - lastTime) * 10_000) / 10

        // less than 60 frames per second
        if elapsedTime > 16.7 {
            print("Dropped frames! elapsed time: \(elapsedTime) ms.")
        }
        lastTime = link.targetTimestamp
    }
    */
    
    func handle(dynamicLink: DynamicLink) -> Bool {
        print("Handling firebase dynamic link: \(dynamicLink)")
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        service.socket?.stop()
        print("enter background")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("will terminate")
    }
    
    // MARK: Push
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        service.push.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        service.push.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        log("remote notification: \(userInfo)", type: .push)
        service.push.remoteNotification(in: application, userInfo: userInfo, completionHandler: completionHandler)
    }

    func application(_ application: UIApplication,
                     performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        service.teambrella.startUpdating(completion: completionHandler)

    }
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        print(userActivity)
        guard let url = userActivity.webpageURL else {
            return false
        }
        
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(url) { link, error in
            guard let link = link else { return }
            
            _ = self.handle(dynamicLink: link)
        }
        return handled
    }

}
