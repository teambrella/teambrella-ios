//
//  WalletDetailsVC.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 23.06.17.

/* Copyright(C) 2017  Teambrella, Inc.
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

import QRCode
import UIKit

class WalletDetailsVC: UIViewController, Routable {
    
    static let storyboardName = "Me"
    @IBOutlet var qrCodeImageView: UIImageView!
    @IBOutlet var fundButton: UIButton!
    @IBOutlet var headerLabel: BlockHeaderLabel!
    @IBOutlet var timeLabel: Label!
    @IBOutlet var cryptoAddressLabel: Label!
    @IBOutlet var container: UIView!
    @IBOutlet var copyAddressButton: UIButton!
    
    var walletID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientNavBar()
        title = "Me.WalletDetailsVC.title".localized
        fundButton.setTitle("Me.WalletDetailsVC.fundButton".localized, for: .normal)
        headerLabel.text = "Me.WalletDetailsVC.headerLabel".localized.uppercased()
        timeLabel.text = ""// "Me.WalletDetailsVC.timeLabel".localized
        copyAddressButton.setTitle("Me.WalletDetailsVC.copyAddressButton".localized, for: .normal)
        ViewDecorator.homeCardShadow(for: container)
//        ViewDecorator.rounded(edges: .allCorners, for: container)
//        ViewDecorator.roundedEdges(for: container)
//        ViewDecorator.heavyShadow(for: container)
        //let's say the server sends the walletID(string) into bitcoinAddressLabel
        cryptoAddressLabel.text = walletID
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        qrCodeImageView.image = QRCodeManager().code(from: walletID)
    }
    
    @IBAction func tapCopy(_ sender: UIButton) {
        UIPasteboard.general.string = cryptoAddressLabel.text
        sender.setTitle("Me.WalletDetailsVC.copiedAddress".localized, for: .normal)
        sender.isEnabled = false
    }
    
}
