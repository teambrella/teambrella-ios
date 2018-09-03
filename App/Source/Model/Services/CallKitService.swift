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

class CallKitService: NSObject {
    lazy var provider: CXProvider = {
        let config = CXProviderConfiguration(localizedName: "Teambrella")
        config.maximumCallsPerCallGroup = 1
//        config.supportedHandleTypes = [CXHandle.HandleType.generic]

        let provider = CXProvider(configuration: config)
        return provider
    }()

    func setDelegate(_ delegate: CXProviderDelegate) {
        provider.setDelegate(delegate, queue: nil)
    }

    func incomingCall(from name: String, id: UUID, completion: @escaping (Error?) -> Void) {
        let update = CXCallUpdate()
        update.localizedCallerName = name
        update.remoteHandle = CXHandle(type: .generic, value: name)
        provider.reportNewIncomingCall(with: id, update: update) { error in
            // add calls
            completion(error)
        }
    }

    func outgoingCall(to name: String, id: UUID, completion: @escaping (Error?) -> Void) {
        let controller = CXCallController()
        let action = CXStartCallAction(call: id, handle: CXHandle(type: .generic, value: name))
        let transaction = CXTransaction(action: action)
        controller.request(transaction, completion: completion)
    }

    func outgoingCallStartedConnecting(id: UUID) {
        print("\(#function)")
        provider.reportOutgoingCall(with: id, startedConnectingAt: Date())
    }

    func outgoingCallConnected(id: UUID) {
        print("\(#function)")
        provider.reportOutgoingCall(with: id, connectedAt: Date())
    }

    func remoteCallEnded(id: UUID) {
        print("\(#function)")
        let reason = CXCallEndedReason.remoteEnded
        provider.reportCall(with: id, endedAt: Date(), reason: reason)
    }

    func endRemoteCall(id: UUID) {
        print("\(#function)")
        let reason = CXCallEndedReason.remoteEnded
        provider.reportCall(with: id, endedAt: Date(), reason: reason)
    }

}
