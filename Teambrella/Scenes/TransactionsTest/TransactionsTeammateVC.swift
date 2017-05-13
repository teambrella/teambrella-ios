//
//  TransactionsTeammateVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 25.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class TransactionsTeammateVC: UIViewController {
    var teammate: Teammate!
    var teambrella: TeambrellaService!

    @IBOutlet var idLabel: UILabel!
    @IBOutlet var fbLabel: UILabel!
    @IBOutlet var publicKeyLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var signatureLabel: UILabel!
    @IBOutlet var cosignersLabel: UILabel!
    @IBOutlet var hisCosigners: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = teammate.name
        idLabel.text = String(teammate.id)
        fbLabel.text = teammate.fbName
        publicKeyLabel.text = teammate.publicKey
        addressLabel.text = teammate.addressCurrent?.address
        signatureLabel.text = teammate.signature?.id.uuidString
        var cosignerNames: [String] = []
        if let cosigners = teammate.cosignerOf as? Set<Cosigner> {
        for cosigner in cosigners {
            cosigner.address?.teammate.map { cosignerNames.append($0.name) }
        }
            cosignersLabel.text = cosignerNames.description
        }
        
        let fetcher = teambrella.fetcher
        let hisCosigners = fetcher.cosigners(for: teammate)
        var hisCosignerNames: [String] = []
        for cosigner in hisCosigners {
            cosigner.address?.teammate.map { hisCosignerNames.append($0.name) }
        }
        self.hisCosigners.text = hisCosignerNames.description
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
