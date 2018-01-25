//
/* Copyright(C) 2018 Teambrella, Inc.
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

import UIKit
import UserNotifications

class InfoMaker {
    struct ServicesOptions: OptionSet {
        let rawValue: Int

        static let silentPushEnabled    = ServicesOptions(rawValue: 1 << 0)
        static let pushEnabled          = ServicesOptions(rawValue: 1 << 1)
        static let pushNeverAsked       = ServicesOptions(rawValue: 1 << 2)
    }

    private(set) var isReady = false
    private(set) var options: ServicesOptions = []

    // 11.3
    var systemVersion: String { return UIDevice.current.systemVersion }
    var platform: String { return UIDevice.current.platform }
    var platformHumanReadable: String {
        let platform = self.platform
        switch platform {
        case "iPod5,1":                                 return "iPodTouch5"
        case "iPod7,1":                                 return "iPodTouch6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "4"
        case "iPhone4,1":                               return "4s"
        case "iPhone5,1", "iPhone5,2":                  return "5"
        case "iPhone5,3", "iPhone5,4":                  return "5c"
        case "iPhone6,1", "iPhone6,2":                  return "5s"
        case "iPhone7,2":                               return "6"
        case "iPhone7,1":                               return "6Plus"
        case "iPhone8,1":                               return "6s"
        case "iPhone8,2":                               return "6sPlus"
        case "iPhone9,1", "iPhone9,3":                  return "7"
        case "iPhone9,2", "iPhone9,4":                  return "7Plus"
        case "iPhone8,4":                               return "SE"
        case "iPhone10,1", "iPhone10,4":                return "8"
        case "iPhone10,2", "iPhone10,5":                return "8Plus"
        case "iPhone10,3", "iPhone10,6":                return "X"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPadAir"
        case "iPad5,3", "iPad5,4":                      return "iPadAir2"
        case "iPad6,11", "iPad6,12":                    return "iPad5"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPadMini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPadMini2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPadMini3"
        case "iPad5,1", "iPad5,2":                      return "iPadMini4"
        case "iPad6,3", "iPad6,4":                      return "iPadPro9.7"
        case "iPad6,7", "iPad6,8":                      return "iPadPro12.9"
        case "iPad7,1", "iPad7,2":                      return "iPadPro12.9Gen2"
        case "iPad7,3", "iPad7,4":                      return "iPadPro10.5"
        case "AppleTV5,3":                              return "AppleTV"
        case "AppleTV6,2":                              return "AppleTV4K"
        case "AudioAccessory1,1":                       return "HomePod"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return platform
        }
    }

    init() {
        prepareServices()
    }

    var info: String {
        defer {
            isReady = false
            prepareServices()
        }

        return isReady
            ? "\(options.rawValue);\(systemVersion);\(platformHumanReadable)"
            : ""
    }

    func prepareServices() {
        var options: ServicesOptions = []
        if UIApplication.shared.backgroundRefreshStatus == .available { options.insert(.silentPushEnabled) }

        let current = UNUserNotificationCenter.current()
        current.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                options.insert(.pushNeverAsked)
            case .authorized:
                options.insert(.pushEnabled)
            case .denied:
                break
            }
            self.options = options
            self.isReady = true
        }
    }

}
