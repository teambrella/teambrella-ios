//
//  JoinTeamPersonalCell.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 01.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class JoinTeamPersonalCell: UICollectionViewCell, XIBInitableCell {
    
    @IBOutlet var verticalSpacings: [NSLayoutConstraint]!
    
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var infoButton: UIButton!
    @IBOutlet var name: LabeledTextField!
    @IBOutlet var dateOfBirth: LabeledTextField!
    @IBOutlet var status: LabeledTextField!
    @IBOutlet var location: LabeledTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        headerLabel.text = "Team.JoinTeamVC.PersonalCell.headerLabel".localized
        name.headerLabel.text = "Team.JoinTeamVC.PersonalCell.name".localized
        name.textField.text = "Frank Smith"
        
        dateOfBirth.headerLabel.text = "Team.JoinTeamVC.PersonalCell.birthday".localized
        dateOfBirth.textField.text = "11/30/1989"
        
        status.headerLabel.text = "Team.JoinTeamVC.PersonalCell.status".localized
        status.textField.text = "Single"
        
        location.headerLabel.text = "Team.JoinTeamVC.PersonalCell.location".localized
        location.textField.text = "Amsterdam, The Netherlands"

        let verticalOffset: CGFloat = isSmallIPhone ? 8 : 19
        verticalSpacings.forEach { $0.constant = verticalOffset }
    }

}
