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
import WatchConnectivity

class WatchService: NSObject {
    let dao: WatchDAO = WatchDAO()

    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

}

extension WatchService: WCSessionDelegate {
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {

    }

    func sessionDidBecomeInactive(_ session: WCSession) {

    }

    func sessionDidDeactivate(_ session: WCSession) {

    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print("message received: \(message)")
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any],
                 replyHandler: @escaping ([String: Any]) -> Void) {
        guard let command = WatchCommand(dict: message) else { return }

        var result = command.dict
        switch command {
        case .wallet:
            dao.getWallet { wallet in
                guard let wallet = wallet else {
                    replyHandler(result)
                    return
                }

                result.merge(wallet.dict, uniquingKeysWith: { (first, _) in first })
            }
        case .coverage:
            dao.getCoverage { coverage in
                guard let item = coverage else {
                    replyHandler(result)
                    return
                }

                result.merge(item.dict, uniquingKeysWith: { (first, _) in first })
            }
        }
        replyHandler(result)
        /*
        if  let wallet = self.wallet,
            let team = service.session?.currentTeam {
            let mETH = MEth(wallet.cryptoBalance).value
            let fiat = mETH * wallet.currencyRate
            let name = team.teamName

            var message: [String: Any] = ["crypto": mETH,
                                          "fiat": fiat,
                                          "name": name
            ]
            replyHandler(message)
            UIImage.fetchImage(string: team.teamLogo) { image, error in

                //                if let image = image {
                //                    message["image"] = image
                //                }

                // WCSession.default.sendMessage(message, replyHandler: nil)
            }
        }
 */
    }
}
