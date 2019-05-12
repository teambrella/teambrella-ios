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

import ExtensionsPack
import UIKit
import UserNotifications

class InfoMaker {
    struct ServicesOptions: OptionSet {
        let rawValue: Int

        static let silentPushEnabled    = ServicesOptions(rawValue: 1 << 0)
        static let pushEnabled          = ServicesOptions(rawValue: 1 << 1)
        static let pushNeverAsked       = ServicesOptions(rawValue: 1 << 2)
        static let isInLowPowerMode     = ServicesOptions(rawValue: 1 << 3)
    }

    private(set) var isReady = false
    private(set) var options: ServicesOptions = []

    // 11.3
    var systemVersion: String { return UIDevice.current.systemVersion }
    var platform: String { return UIDevice.current.platform }
    var platformHumanReadable: String {
        let platform = self.platform
        switch platform {
        case "iPod5,1":                                     return "iPodTouch5"
        case "iPod7,1":                                     return "iPodTouch6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":         return "4"
        case "iPhone4,1":                                   return "4s"
        case "iPhone5,1", "iPhone5,2":                      return "5"
        case "iPhone5,3", "iPhone5,4":                      return "5c"
        case "iPhone6,1", "iPhone6,2":                      return "5s"
        case "iPhone7,2":                                   return "6"
        case "iPhone7,1":                                   return "6Plus"
        case "iPhone8,1":                                   return "6s"
        case "iPhone8,2":                                   return "6sPlus"
        case "iPhone9,1", "iPhone9,3":                      return "7"
        case "iPhone9,2", "iPhone9,4":                      return "7Plus"
        case "iPhone8,4":                                   return "SE"
        case "iPhone10,1", "iPhone10,4":                    return "8"
        case "iPhone10,2", "iPhone10,5":                    return "8Plus"
        case "iPhone10,3", "iPhone10,6":                    return "X"
        case "iPhone11,2":                                  return "iPhone XS"
        case "iPhone11,4", "iPhone11,6":                    return "iPhone XS Max"
        case "iPhone11,8":                                  return "iPhone XR"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":    return "iPad2"
        case "iPad3,1", "iPad3,2", "iPad3,3":               return "iPad3"
        case "iPad3,4", "iPad3,5", "iPad3,6":               return "iPad4"
        case "iPad4,1", "iPad4,2", "iPad4,3":               return "iPadAir"
        case "iPad5,3", "iPad5,4":                          return "iPadAir2"
        case "iPad6,11", "iPad6,12":                        return "iPad5"
        case "iPad2,5", "iPad2,6", "iPad2,7":               return "iPadMini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           	return "iPadMini2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           	return "iPadMini3"
        case "iPad5,1", "iPad5,2":                      	return "iPadMini4"
        case "iPad6,3", "iPad6,4":                          return "iPadPro9.7"
        case "iPad6,7", "iPad6,8":                          return "iPadPro12.9"
        case "iPad7,1", "iPad7,2":                          return "iPadPro12.9Gen2"
        case "iPad7,3", "iPad7,4":                          return "iPadPro10.5"
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":    return "iPadPro11"
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":    return "iPadPro12.9Gen3)"
        case "AppleTV5,3":                                  return "AppleTV"
        case "AppleTV6,2":                                  return "AppleTV4K"
        case "AudioAccessory1,1":                           return "HomePod"
        case "i386", "x86_64":                              return "Simulator"
        default:                                            return platform
        }
    }

    var isSilentPushAvailable: Bool {
        defer { prepareServices() }
        return options.contains(.silentPushEnabled)
    }
    var isPushEnabled: Bool {
        defer { prepareServices() }
        return options.contains(.pushEnabled)
    }

    private var isPreparingServices: Bool = false

    init() {
        prepareServices()
    }

    var info: String {
        defer {
            isReady = false
            prepareServices()
        }

        return isReady
            ? "\(options.rawValue);\(systemVersion);\(platformHumanReadable)"//";\(Int(appSizeMB + 0.5));\(memoryMB)"
            : ""
    }

    func prepareServices() {
        guard !isPreparingServices else { return }

        isPreparingServices = true
        DispatchQueue.main.async {
            var options: ServicesOptions = []
            if UIApplication.shared.backgroundRefreshStatus == .available { options.insert(.silentPushEnabled) }
            if UIDevice.current.isInLowPowerMode { options.insert(.isInLowPowerMode) }

            let procName = ProcessInfo.processInfo.processName
            if (procName == "IBDesignablesAgentCocoaTouch" || procName == "IBDesignablesAgent-iOS") {
                return
            }
            
            let current = UNUserNotificationCenter.current()
            current.getNotificationSettings { settings in
                switch settings.authorizationStatus {
                case .notDetermined:
                    options.insert(.pushNeverAsked)
                case .authorized:
                    options.insert(.pushEnabled)
                default:
                    break
                }
                self.options = options
                self.isReady = true
                self.isPreparingServices = false
            }
        }
    }

    lazy private var appSizeMB: Double = {
        var paths = [Bundle.main.bundlePath]
        let docDirDomain = FileManager.SearchPathDirectory.documentDirectory
        let docDirs = NSSearchPathForDirectoriesInDomains(docDirDomain, .userDomainMask, true)
        if let docDir = docDirs.first {
            paths.append(docDir)
        }
        let libDirDomain = FileManager.SearchPathDirectory.libraryDirectory
        let libDirs = NSSearchPathForDirectoriesInDomains(libDirDomain, .userDomainMask, true)
        if let libDir = libDirs.first {
            paths.append(libDir)
        }
        paths.append(NSTemporaryDirectory() as String)

        var totalSize: Double = 0
        for path in paths {
            if let size = bytesIn(directory: path) {
                totalSize += size
            }
        }
        return totalSize / 1000000
    }()

    private func bytesIn(directory: String) -> Double? {
        let fm = FileManager.default
        guard let subdirectories = try? fm.subpathsOfDirectory(atPath: directory) as NSArray else {
            return nil
        }
        let enumerator = subdirectories.objectEnumerator()
        var size: UInt64 = 0
        while let fileName = enumerator.nextObject() as? String {
            do {
                let fileDictionary = try
                    fm.attributesOfItem(atPath: directory.appending("/" + fileName)) as NSDictionary
                size += fileDictionary.fileSize()
            } catch let err {
                log("err getting attributes of file \(fileName): \(err.localizedDescription)", type: [.error, .info])
            }
        }
        return Double(size)
    }

    var memoryMB: Int {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        if kerr == KERN_SUCCESS {
            return Int(taskInfo.resident_size / 1000000)
        } else {
            return -1
        }
    }

}
