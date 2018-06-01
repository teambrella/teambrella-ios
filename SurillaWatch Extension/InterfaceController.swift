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
import WatchKit

class InterfaceController: WKInterfaceController {
    @IBOutlet var ethValue: WKInterfaceLabel!
    @IBOutlet var fiatValue: WKInterfaceLabel!
    @IBOutlet var teamName: WKInterfaceLabel!
    @IBOutlet var teamLogo: WKInterfaceImage!
    @IBOutlet var coverage: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        ethValue.setText("0")
        fiatValue.setText("0")
        teamName.setText("Team name")
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
