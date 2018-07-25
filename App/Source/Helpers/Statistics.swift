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

import Crashlytics
import Firebase
import Foundation

class Statistics {
    enum Event: String {
        case showHomeScreen
        case tapQRCodeLogin
        case tapSavePrivateKey
        case tapPrintPrivateKey
        case tapPhotoPrivateKey
        case voipPushReceived
        case voipPushWrongPayload
    }

    static func crash() {
        Crashlytics.sharedInstance().crash()
    }

    static func register(userID: String) {
        Crashlytics.sharedInstance().setUserIdentifier(userID)
        Analytics.setUserID(userID)
    }

    static func log(error: Error) {
        if let error = error as? TeambrellaError {
            Crashlytics.sharedInstance().recordError(error.nsError)
        } else {
        Crashlytics.sharedInstance().recordError(error)
        }
    }

    static func log(event: Event, dict: [String: Any]? = nil) {
        let title = event.rawValue
        Analytics.logEvent(title, parameters: dict)
    }

}
