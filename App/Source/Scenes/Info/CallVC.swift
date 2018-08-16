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

import UIKit

class CallVC: UIViewController, Routable {
    static let storyboardName = "Info"

    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var avatarView: RoundImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var cancelButton: BorderedButton!

    var name: String!
    var avatar: String!
    var id: String!

    var sinch: SinchService { return service.sinch }

    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = name
        avatarView.showAvatar(string: avatar)
        sinch.delegate = self
    }

    @IBAction func tapCancel(_ sender: BorderedButton) {
        sinch.stopCalling()
        close()
    }

    func close() {
        dismiss(animated: true) {

        }
    }

}

extension CallVC: SinchServiceDelegate {
    func sinch(service: SinchService, didFail: Error) {
        log(didFail)
        close()
    }

    func sinch(service: SinchService, didEndCall: Any) {
close()
    }

    func sinch(service: SinchService, didStartCall: Any) {

    }
}
