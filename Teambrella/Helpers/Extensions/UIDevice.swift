//
/* Copyright(C) 2017 Teambrella, Inc.
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

import Foundation

extension UIDevice {
    public var hasHapticEngine: Bool {
        guard let version = platform().split(separator: ",").first else { return false}
        
        return ["iPhone9", "iPhone10"].contains(version)
    }
    
    public var isIphoneX: Bool {
        return ["iPhone10,3", "iPhone10,6"].contains(platform())
    }
    
    public func platform() -> String {
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        return String(bytes: Data(bytes: &sysinfo.machine,
                                  count: Int(_SYS_NAMELEN)),
                      encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }
    
}
