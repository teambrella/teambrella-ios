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
            
            log("Terminating previous session (userID: \(currentUserID)", type: .voip)
            terminate()
        }
        
        let client: SINClient = Sinch.client(withApplicationKey: Resources.Sinch.applicationKey,
                                             applicationSecret: Resources.Sinch.applicationSecret,
                                             environmentHost: host,
                                             userId: userID)
        log("Sinch client created for userID: \(userID)", type: .voip)
        client.enableManagedPushNotifications()
        client.setSupportCalling(true)
        client.setSupportPushNotifications(true)
        client.delegate = self
        client.start()
        client.startListeningOnActiveConnection()
        log("Sinch start client: \(client.description)", type: .voip)
        
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
        log("Calling \(userID)", type: .voip)
        let headers: [String: String] = ["name": name]
        guard let call = callClient?.callUser(withId: userID, headers: headers) else {
            log("Couldn't establish call", type: .voip)
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
        log("\(#file); \(#function)", type: .voip)
        let callClient = client.call()
        callClient?.delegate = self
        self.callClient = callClient
    }
    
    func clientDidStop(_ client: SINClient!) {
        log("\(#file); \(#function)", type: .voip)
    }
    
    func clientDidFail(_ client: SINClient!, error: Error!) {
        log("\(#file); \(#function)", type: .voip)
        log(error)
    }
}

// Manage outgoing calls
extension SinchService: SINCallDelegate {
    func callDidEstablish(_ call: SINCall!) {
        log("\(#file); \(#function), \(String(describing: call))", type: .voip)
        delegate?.sinch(service: self, didStartCall: call)
    }
    
    func callDidProgress(_ call: SINCall!) {
        log("\(#file); \(#function), \(String(describing: call))", type: .voip)
        self.call = call
    }
    
    func callDidEnd(_ call: SINCall!) {
        log("\(#file); \(#function), \(String(describing: call.details))", type: .voip)
        switch call.details.endCause {
        case .canceled:
            log("cancelled", type: .voip)
        case .denied:
            log("denied", type: .voip)
        case .error:
            log("error", type: .voip)
        case .noAnswer:
            log("no answer", type: .voip)
        case .timeout:
            log("timeout", type: .voip)
        case .hungUp:
            log("hung up", type: .voip)
        default:
            log("other cause \(call.details.endCause.rawValue)", type: .voip)
        }
        if isReceivingCall, let id = UUID(uuidString: call.remoteUserId) {
            isReceivingCall = false
            callService.endRemoteCall(id: id)
        }
        
        delegate?.sinch(service: self, didEndCall: call)
        self.call = nil
    }
    
    func call(_ call: SINCall!, shouldSendPushNotifications pushPairs: [Any]!) {
        log("\(#file); \(#function); \(String(describing: pushPairs))", type: .voip)
    }
}

// Manage incoming calls
extension SinchService: SINCallClientDelegate {
    func client(_ client: SINCallClient!, didReceiveIncomingCall call: SINCall!) {
        call.delegate = self
        self.call = call
        guard let id = UUID(uuidString: call.remoteUserId) else {
            return
        }
        
        let name = call.headers["name"] as? String ?? "unknown"
        
        self.callService.incomingCall(from: name, id: id) { error in
            DispatchQueue.main.async {
                if let error = error {
                    log("error receiving call: \(error)", type: .voip)
                } else {
                    log("Receiving call", type: .voip)
                }
            }
            self.isReceivingCall = true
        }
    }
    //call.answer()
}

func client(_ client: SINCallClient!,
            localNotificationForIncomingCall call: SINCall!) -> SINLocalNotification! {
    let notification = SINLocalNotification()
    notification.alertAction = "Answer"
    notification.alertBody = "Incoming call"
    return notification
}

extension SinchService: SINManagedPushDelegate {
    func managedPush(_ managedPush: SINManagedPush!,
                     didReceiveIncomingPushWithPayload payload: [AnyHashable: Any]!,
                     forType pushType: String!) {
        log("Sinch Service Received push with payload: \(String(describing: payload))", type: .voip)
        guard let cmd = payload["cmd"] as? String, let command = PushKitCommand(rawValue: cmd) else {
            log("No command found in PushKit dictionary: \(String(describing: payload))", type: .push)
            Statistics.log(event: .voipPushWrongPayload, dict: payload as? [String: Any])
            return
        }

        Statistics.log(event: .voipPushReceived, dict: payload as? [String: Any])
        log("got cmd string: \(cmd), command: \(command)", type: .push)
        switch command {
        case .getUpdates:
            service.teambrella.startUpdating { result in
                log("SinchService has finished it's job", type: .push)

            }
        case .getDatabaseDump:
            service.teambrella.sendDBDump { success in
                
            }
        case .clearDB:
            do {
                try service.teambrella.clear()
            } catch {
                log("Error clearing the DB: \(error)", type: .error)
            }
        }
    }
}

extension SinchService: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        log("Provider did reset call", type: .voip)
    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        callService.outgoingCallStartedConnecting(id: action.callUUID)
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        self.call?.answer()
        action.fulfill()
    }
    
    func providerDidBegin(_ provider: CXProvider) {
        log("Provider did begin", type: .voip)
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        self.stopCalling()
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        log("\(#function)", type: .voip)
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        log("\(#function)", type: .voip)
    }
    
}
