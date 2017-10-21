//
//  TransactionsTeammateVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 25.04.17.

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
        // signatureLabel.text = teammate.signature?.id.uuidString
        var cosignerNames: [String] = []
        let cosigners = teammate.cosignerOf
        for cosigner in cosigners {
            cosignerNames.append(cosigner.address.teammate.name)
        }
        cosignersLabel.text = cosignerNames.description
        
        let fetcher = teambrella.storage.contentProvider
        let hisCosigners = fetcher.cosigners(for: teammate)
        var hisCosignerNames: [String] = []
        for cosigner in hisCosigners {
            hisCosignerNames.append(cosigner.address.teammate.name)
        }
        self.hisCosigners.text = hisCosignerNames.description
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
