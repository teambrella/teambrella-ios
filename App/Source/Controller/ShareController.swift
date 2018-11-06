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

class ShareController {
    var invitationText: String? { return service.session?.currentTeam?.inviteText }

    func shareInvitation(in viewController: UIViewController) {
        guard let text = invitationText else { return }

        share(text: text, in: viewController)
    }

    func share(text: String, in viewController: UIViewController) {
        let vc = UIActivityViewController(activityItems: [text], applicationActivities: [])
        viewController.present(vc, animated: true)
    }

}
