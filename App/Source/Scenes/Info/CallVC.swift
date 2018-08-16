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
    @IBOutlet var timeLabel: UILabel!

    var name: String!
    var avatar: String!
    var id: String!

    var sinch: SinchService { return service.sinch }

    var periodicEvent: PeriodicEvent?
    var isConnected: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = name
        avatarView.showAvatar(string: avatar)

        sinch.delegate = self

        headerLabel.text = "Info.CallVC.calling".localized
        cancelButton.setTitle("Info.CallVC.CancelButton.Title".localized, for: .normal)
        createPeriodicEvent()
    }

    private func createPeriodicEvent() {
        periodicEvent = PeriodicEvent(step: 1, event: { [weak self] in
            self?.updateTimeLabel()
        })
    }

    private func updateTimeLabel() {
        guard let event = periodicEvent else { return }

        let interval = Interval(start: event.startDate, end: Date())
        if isConnected {
            timeLabel.text = interval.formattedString
        } else {
            timeLabel.text = String(repeating: ".", count: interval.seconds % 3 + 1)
        }

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
        periodicEvent?.invalidate()
        isConnected = true
        createPeriodicEvent()
    }
}
