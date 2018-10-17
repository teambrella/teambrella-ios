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

class Console: UIViewController, Routable {
static let storyboardName = "Info"

    @IBOutlet var pushTokenField: UITextField!
    @IBOutlet var pushTokenAPNSField: UITextField!
    @IBOutlet var privateKeyField: UITextField!
    @IBOutlet var publicKeyField: UITextField!
    @IBOutlet var pushKitField: UITextField!
    
    @IBOutlet var versionLabel: UILabel!

    var push: PushService!
    var teambrella: TeambrellaService!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pushTokenField.text = push.tokenString
        pushTokenAPNSField.text = push.apnsTokenString
        privateKeyField.text = teambrella.key.privateKey
        publicKeyField.text = teambrella.key.publicKey
        pushKitField.text = push.pushKit.tokenString

        versionLabel.text = Application().clientVersion
    }

    @IBAction func sendDbDump(_ sender: UIButton) {
        teambrella.sendDBDump { success in

        }
    }

}
