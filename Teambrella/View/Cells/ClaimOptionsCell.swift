//
//  ClaimOptionsCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 07.06.17.

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

class ClaimOptionsCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var allVotesLabel: Label!
    @IBOutlet var cashFlowLabel: Label!
    @IBOutlet var transactionsLabel: Label!
    
    var tapRecognizer = UITapGestureRecognizer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tapRecognizer = UITapGestureRecognizer(target: transactionsLabel,
                                               action: #selector(showTransactions))
        transactionsLabel.addGestureRecognizer(tapRecognizer)
    }
    
    func showTransactions() {
        //if sender.state == .ended {
            print("tap trnss")
            //service.router.presentClaimTransactionsList(teamID: <#T##Int#>, claimID: <#T##Int#>)
        //}
    }

}
