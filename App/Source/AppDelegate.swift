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

//import Auth0
import Fabric
//import FBSDKCoreKit
import Firebase
import PushKit
import UIKit
//import UXCam

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
//     FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        // Register for Push here to be able to receive silent notifications even if user will restrict push service
        service.push.register(application: application)
        service.push.startPushKit()
        if let userID = SimpleStorage().string(forKey: .userID) {
            service.sinch.startWith(userID: userID)
        }
        TeambrellaStyle.apply()
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        // Pull in case of emergency :)
        // service.cryptoMalfunction()
        configureLibs()
        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplicationOpenURLOptionsKey: Any] = [ : ]) -> Bool {
        guard options[.sourceApplication] as? String != nil else {
            if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
                return handle(dynamicLink: dynamicLink)
            }
            return false
        }
        
//        if source.hasPrefix("com.facebook") {
//            log("Opening app from Facebook application", type: .social)
//            return FBSDKApplicationDelegate.sharedInstance().application(app,
//                                                                         open: url,
//                                                                         sourceApplication: source,
//                                                                         annotation: options[.annotation])
//        } else {
//            log("Opening app from Auth0", type: .social)
//            return Auth0.resumeAuth(url, options: options)
//        }
        return true
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
        
        // Add XCam
        //UXCam.start(withKey: Resources.UXCam.accountKey)
        
        // Add Crashlytics in debug mode
        #if SURILLA
        Fabric.sharedSDK().debug = true
        #endif
    }
    
    func handle(dynamicLink: DynamicLink) -> Bool {
        print("Handling firebase dynamic link: \(dynamicLink)")
        guard let url = dynamicLink.url else { return false }
        
        let components = url.pathComponents
        let team = components.last
        
        var invite: String?
        if let query = url.query, let range = query.range(of: "invite=") {
            invite = String(query[range.upperBound...])
        }
        
        service.invite = invite
        service.joinTeamID = team.flatMap { Int($0) }
        
        NotificationCenter.default.post(name: .dynamicLinkReceived, object: nil)
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
