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

import AudioToolbox
import ExtensionsPack
import UIKit

class Vibrator {
    
    func vibrate() {
        if UIDevice.current.hasHapticEngine {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        } else if UIDevice.current.hasSemiHapticEngine {
            /*
             1519 - Peek (weak boom)
             1520 - Pop (strong boom)
             1521 - Nope (three weak booms)
             */
            AudioServicesPlaySystemSound(1520)
        } else {
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        }
    }
    
    func lightVibes() {
        if UIDevice.current.hasHapticEngine {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        } else if UIDevice.current.hasSemiHapticEngine {
            /*
             1519 - Peek (weak boom)
             1520 - Pop (strong boom)
             1521 - Nope (three weak booms)
             */
            AudioServicesPlaySystemSound(1521)
        } else {
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        }
    }
    
}
