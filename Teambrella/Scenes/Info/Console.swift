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

    @IBOutlet var versionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        pushTokenField.text = service.push.tokenString
        pushTokenAPNSField.text = service.push.apnsTokenString
        privateKeyField.text = service.teambrella.key.privateKey
        publicKeyField.text = service.teambrella.key.publicKey

        versionLabel.text = Application().clientVersion
    }

    @IBAction func sendDbDump(_ sender: UIButton) {
        service.teambrella.sendDBDump { success in

        }
    }

}
