//
/* Copyright(C) 2016-2018 Teambrella, Inc.
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
 * along with this program.  If not, see http://www.gnu.org/licenses/
 */

import Foundation

final class SinchService: NSObject {
    #if SURILLA
    let host = "sandbox.sinch.com"
   let environment: SINAPSEnvironment = .development
    #else
    let host = "clientapi.sinch.com"
    let environment: SINAPSEnvironment = .production
    #endif

    var client: SINClient?
    var callClient: SINCallClient?

    var outgoingCall: SINCall?

    var push: SINManagedPush?
    var currentUserID: String?

    func setupPush() {
        push = Sinch.managedPush(with: environment)
        push?.delegate = self
        push?.setDesiredPushTypeAutomatically()
    }

    func askPushCredentialsIfNeeded() {
        push?.registerUserNotificationSettings()
    }

    func startWith(userID: String) {
        if let currentUserID = currentUserID {
            guard userID != currentUserID else {
                return
            }

            terminate()
        }
        
        let client: SINClient = Sinch.client(withApplicationKey: "723c3702-29a7-4bb3-a802-5e7b03b5a46f",
                                             applicationSecret: "N6x/aZ3ZkEOaIUdNK4/T6w==",
                                             environmentHost: host,
                                             userId: userID)
        client.setSupportCalling(true)
        client.enableManagedPushNotifications()

        client.delegate = self
        client.start()
        client.startListeningOnActiveConnection()

        self.client = client
        self.currentUserID = userID
    }

    func terminate() {
        if let client = client {
            client.stopListeningOnActiveConnection()
            client.terminateGracefully()
        }
        self.client = nil
    }

    func call(userID: String) {
        guard let client = client else { return }

        let callClient = client.call()
        self.callClient = callClient
        guard let call = callClient?.callUser(withId: userID) else {
            print("Couldn't establish call")
            return
        }

        call.delegate = self
        self.outgoingCall = call
    }


}

extension SinchService: SINClientDelegate {
    func clientDidStart(_ client: SINClient!) {
        print("\(#file); \(#function)")
    }

    func clientDidStop(_ client: SINClient!) {
        print("\(#file); \(#function)")
    }

    func clientDidFail(_ client: SINClient!, error: Error!) {
        print("\(#file); \(#function)")
        log(error)
    }
}

// Manage outgoing calls
extension SinchService: SINCallDelegate {
    func callDidEstablish(_ call: SINCall!) {
        print("\(#file); \(#function)")
    }

    func callDidProgress(_ call: SINCall!) {
        print("\(#file); \(#function)")
    }

    func callDidEnd(_ call: SINCall!) {
        print("\(#file); \(#function)")
    }

    func call(_ call: SINCall!, shouldSendPushNotifications pushPairs: [Any]!) {
        print("\(#file); \(#function); \(pushPairs)")
    }
}

// Manage incoming calls
extension SinchService: SINCallClientDelegate {
    func client(_ client: SINCallClient!, didReceiveIncomingCall call: SINCall!) {

        call.delegate = self
    }

    func client(_ client: SINCallClient!,
                localNotificationForIncomingCall call: SINCall!) -> SINLocalNotification! {
        let notification = SINLocalNotification()
        notification.alertAction = "Answer"
        notification.alertBody = "Incoming call"
        return notification
    }
}

extension SinchService: SINManagedPushDelegate {
    func managedPush(_ managedPush: SINManagedPush!,
                     didReceiveIncomingPushWithPayload payload: [AnyHashable : Any]!,
                     forType pushType: String!) {
        print("Sinch Service Received push with payload: \(payload)")
    }
}


