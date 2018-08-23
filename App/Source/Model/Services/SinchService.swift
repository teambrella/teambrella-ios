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

import CallKit
import Foundation

protocol SinchServiceDelegate: class {
    func sinch(service: SinchService, didStartCall: Any)
    func sinch(service: SinchService, didEndCall: Any)
    func sinch(service: SinchService, didFail: Error)
}

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

    var call: SINCall?

    var push: SINManagedPush?
    var currentUserID: String?

    var isReceivingCall: Bool = false

   lazy var callService: CallKitService = {
    let service = CallKitService()
    service.setDelegate(self)
    return service
   }()

    weak var delegate: SinchServiceDelegate?

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

            print("Terminating previous session (userID: \(currentUserID)")
            terminate()
        }
        
        let client: SINClient = Sinch.client(withApplicationKey: Resources.Sinch.applicationKey,
                                             applicationSecret: Resources.Sinch.applicationSecret,
                                             environmentHost: host,
                                             userId: userID)
        print("Sinch client created for userID: \(userID)")
        client.enableManagedPushNotifications()
        client.setSupportCalling(true)
        client.setSupportPushNotifications(true)
        client.delegate = self
        client.start()
        client.startListeningOnActiveConnection()
        print("Sinch start client: \(client.description)")

        self.client = client
        self.currentUserID = userID

        setupPush()
        askPushCredentialsIfNeeded()
    }

    func terminate() {
        if let client = client {
            client.stopListeningOnActiveConnection()
            client.terminateGracefully()
        }
        self.client = nil
    }

    func call(userID: String, name: String) {
        guard let client = client else { return }

        print("Calling \(userID)")
        let headers: [String: String] = ["name": name]
        guard let call = callClient?.callUser(withId: userID, headers: headers) else {
            print("Couldn't establish call")
            return
        }

        call.delegate = self
    }

    func stopCalling() {
        self.call?.hangup()
        self.call = nil
    }

}

extension SinchService: SINClientDelegate {
    func clientDidStart(_ client: SINClient!) {
        print("\(#file); \(#function)")
        let callClient = client.call()
        callClient?.delegate = self
        self.callClient = callClient
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
        print("\(#file); \(#function), \(call)")
        delegate?.sinch(service: self, didStartCall: call)
    }

    func callDidProgress(_ call: SINCall!) {
        print("\(#file); \(#function), \(call)")
        self.call = call
    }

    func callDidEnd(_ call: SINCall!) {
        print("\(#file); \(#function), \(call.details)")
        switch call.details.endCause {
        case .canceled:
            print("cancelled")
        case .denied:
            print("denied")
        case .error:
            print("error")
        case .noAnswer:
            print("no answer")
        case .timeout:
            print("timeout")
        case .hungUp:
            print("hung up")
        default:
            print("other cause \(call.details.endCause.rawValue)")
        }
        if isReceivingCall, let id = UUID(uuidString: call.remoteUserId) {
            isReceivingCall = false
            callService.endRemoteCall(id: id)
        }

        delegate?.sinch(service: self, didEndCall: call)
        self.call = nil
    }

    func call(_ call: SINCall!, shouldSendPushNotifications pushPairs: [Any]!) {
        print("\(#file); \(#function); \(pushPairs)")
    }
}

// Manage incoming calls
extension SinchService: SINCallClientDelegate {
    func client(_ client: SINCallClient!, didReceiveIncomingCall call: SINCall!) {
        call.delegate = self
        self.call = call

        guard let id = UUID(uuidString: call.remoteUserId) else { return }

        let name = call.headers["name"] as? String ?? "unknown"

        callService.incomingCall(from: name, id: id) { error in

        }
        isReceivingCall = true
        //call.answer()
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
                     didReceiveIncomingPushWithPayload payload: [AnyHashable: Any]!,
                     forType pushType: String!) {
        print("Sinch Service Received push with payload: \(payload)")
    }
}

extension SinchService: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
    }

    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        callService.outgoingCallStartedConnecting(id: action.callUUID)
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        self.call?.answer()
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        self.stopCalling()
        action.fulfill()
    }

}
