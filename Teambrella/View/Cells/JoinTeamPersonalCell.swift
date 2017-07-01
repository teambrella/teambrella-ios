//
//  JoinTeamPersonalCell.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 01.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class JoinTeamPersonalCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var infoButton: UIButton!
    @IBOutlet var name: LabeledTextField!
    @IBOutlet var dateOfBirth: LabeledTextField!
    @IBOutlet var status: LabeledTextField!
    @IBOutlet var location: LabeledTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        headerLabel.text = "Personal info".uppercased()
        name.headerLabel.text = "What's your name".uppercased()
        name.textField.text = "Frank Smith"
        
        dateOfBirth.headerLabel.text = "Date of birth".uppercased()
        dateOfBirth.textField.text = "11/30/1989"
        
        status.headerLabel.text = "Status".uppercased()
        status.textField.text = "Single"
        
        location.headerLabel.text = "Location".uppercased()
        location.textField.text = "Amsterdam, The Netherlands"
    }

}
