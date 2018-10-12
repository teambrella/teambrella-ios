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
import PushKit
import UserNotifications

class PushKitWorker: NSObject {
    let pushType: PKPushType = PKPushType.voIP

    var pushRegistry: PKPushRegistry!
    var token: Data? {
            return pushRegistry.pushToken(for: pushType)
    }
    var tokenString: String {
        guard let token = token else { return "" }

        return [UInt8](token).reduce("") { $0 + String(format: "%02x", $1) }
    }

    var onTokenUpdate: ((_ token: String) -> Void)?
    var onPushReceived: (([AnyHashable: Any], @escaping () -> Void) -> Void)?

    override init() {
        pushRegistry = PKPushRegistry(queue: nil)
        super.init()
        pushRegistry.delegate = self
        pushRegistry.desiredPushTypes = [pushType]
    }

}

extension PushKitWorker: PKPushRegistryDelegate {
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        onTokenUpdate?(tokenString)
    }

    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        log("PushRegistry did invalidate token", type: .push)
    }

    // iOS 11
    func pushRegistry(_ registry: PKPushRegistry,
                      didReceiveIncomingPushWith payload: PKPushPayload,
                      for type: PKPushType) {
        log("Push received 1", type: .push)
    }

    func pushRegistry(_ registry: PKPushRegistry,
                      didReceiveIncomingPushWith payload: PKPushPayload,
                      for type: PKPushType,
                      completion: @escaping () -> Void) {
        log("Push received 2", type: .push)
        onPushReceived?(payload.dictionaryPayload, completion)
    }

}
