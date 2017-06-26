//
//  WalletDetailsVC.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 23.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import QRCode
import UIKit

class WalletDetailsVC: UIViewController, Routable {

    static let storyboardName = "Me"
    @IBOutlet var qrCodeImageView: UIImageView!
    @IBOutlet var fundButton: UIButton!
    @IBOutlet var headerLabel: BlockHeaderLabel!
    @IBOutlet var timeLabel: Label!
    @IBOutlet var bitcoinAddressLabel: Label!
    @IBOutlet var container: UICollectionReusableView!
    @IBOutlet var copyAddressButton: UIButton!
    
    var walletID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTransparentNavigationBar()
        title = "Me.WalletDetailsVC.title".localized
        fundButton.setTitle("Me.WalletDetailsVC.fundButton".localized, for: .normal)
        headerLabel.text = "Me.WalletDetailsVC.headerLabel".localized.uppercased()
        timeLabel.text = "Me.WalletDetailsVC.timeLabel".localized
        copyAddressButton.setTitle("Me.WalletDetailsVC.copyAddressButton".localized, for: .normal)
        CellDecorator.shadow(for: container)
        CellDecorator.roundedEdges(for: container)
        //let's say the server sends the walletID(string) into bitcoinAddressLabel
        bitcoinAddressLabel.text = walletID
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        generateQRCode()
    }
    
    func generateQRCode() {
        guard var qrCode = QRCode(walletID) else { return }
        
        qrCode.size = CGSize(width: 250, height: 250) // Zeplin (04.2 wallet-dialog-1)
        qrCode.color = CIColor(rgba: "2C3948")
        qrCode.backgroundColor = CIColor(rgba: "F8FAFD")
        let image = qrCode.image
        qrCodeImageView.image = image
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
