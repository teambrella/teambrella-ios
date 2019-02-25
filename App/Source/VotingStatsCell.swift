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

class VotingStatsCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var containerView: UIView!
    @IBOutlet var headerLabel: BlockHeaderLabel!
    
    @IBOutlet var forRisksTitleLabel: Label!
    @IBOutlet var forRisksValueLabel: Label!
    @IBOutlet var forRisksInfoLabel: Label!
    
    @IBOutlet var forPayoutsTitleLabel: Label!
    @IBOutlet var forPayoutsValueLabel: Label!
    @IBOutlet var forPayoutsInfoLabel: Label!
    
    @IBOutlet var risksStatsView: UIView!
    @IBOutlet var claimsStatsView: UIView!

    var onTapRisks: (() -> Void)?
    var onTapClaims: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()

        let gestureRisks = UITapGestureRecognizer(target: self, action: #selector(tapRisks))
        risksStatsView.isUserInteractionEnabled = true
        risksStatsView.addGestureRecognizer(gestureRisks)

        let gestureClaims = UITapGestureRecognizer(target: self, action: #selector(tapClaims))
        claimsStatsView.isUserInteractionEnabled = true
        claimsStatsView.addGestureRecognizer(gestureClaims)
    }

    func setup() {
        containerView.layer.cornerRadius = 6
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.lightBlueGray.cgColor

        contentView.translatesAutoresizingMaskIntoConstraints = false

        let leftConstraint = contentView.leftAnchor.constraint(equalTo: leftAnchor)
        let rightConstraint = contentView.rightAnchor.constraint(equalTo: rightAnchor)
        let topConstraint = contentView.topAnchor.constraint(equalTo: topAnchor)
        let bottomConstraint = contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        NSLayoutConstraint.activate([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
    }

    @objc
    func tapRisks() {
        onTapRisks?()
    }
    @objc
    func tapClaims() {
        onTapClaims?()
    }
}
