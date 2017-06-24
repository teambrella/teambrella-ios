//
//  WalletDetailsVC.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 23.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

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
        
        bitcoinAddressLabel.text = "13CAnApBYfERwCvpp4KSypHg7BQ5BXwg3x".uppercased() 
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
