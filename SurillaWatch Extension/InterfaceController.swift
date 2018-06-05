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
import WatchKit

class InterfaceController: WKInterfaceController {
    @IBOutlet var ethValue: WKInterfaceLabel!
    @IBOutlet var fiatValue: WKInterfaceLabel!
    @IBOutlet var fiatCurrency: WKInterfaceLabel!
    @IBOutlet var teamName: WKInterfaceLabel!
    @IBOutlet var teamLogo: WKInterfaceImage!
    @IBOutlet var coverage: WKInterfaceLabel!
    
    @IBOutlet var walletTitle: WKInterfaceLabel!
    @IBOutlet var coverageTitle: WKInterfaceLabel!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        print(context)

        walletTitle.setText(NSLocalizedString("Wallet",
                                              tableName: "Watch",
                                              comment: ""))
        coverageTitle.setText(NSLocalizedString("Coverage",
                                                tableName: "Watch",
                                                comment: ""))
    }
    
    override func willActivate() {
        super.willActivate()

        let session = WCSession.default
        session.delegate = self
        if session.activationState != .activated {
            session.activate()
        }

        sendRequest()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    func setTeamLogo(urlString: String) {
        guard let urlData = urlString.data(using: .utf8) else { return }

        WCSession.default.sendMessageData(urlData, replyHandler: { [weak self] data in
            guard let image = UIImage(data: data) else { return }

            self?.teamLogo.setImage(image)
        }) { error in

        }
    }

    func sendRequest() {
        let walletCommand = WatchCommand.wallet
        WCSession.default.sendMessage(walletCommand.dict, replyHandler: { [weak self] message in
            if let wallet = WatchWallet(dict: message) {
                self?.setupWith(wallet: wallet)
                self?.setTeamLogo(urlString: wallet.team.logo)
            }
        })

        let coverageCommand = WatchCommand.coverage
        WCSession.default.sendMessage(coverageCommand.dict, replyHandler: { [weak self] message in
            if let coverage = WatchCoverage(dict: message) {
                self?.setupWith(coverage: coverage)
            }
        })
    }

    func setupWith(wallet: WatchWallet) {
        ethValue.setText(String(format: "%.2f", wallet.mETH))
        fiatValue.setText(String(format: "%.2f", wallet.mETH / 1000 * wallet.rate))
        fiatCurrency.setText(wallet.team.currency)
        teamName.setText(wallet.team.name)

        //teamLogo.setImage(message["image"] as? UIImage)
    }

    func setupWith(coverage: WatchCoverage) {
        self.coverage.setText("\(coverage.coverage)")
    }

}

extension InterfaceController: WCSessionDelegate {
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {

    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        WKInterfaceDevice().play(.click)
    }
}
