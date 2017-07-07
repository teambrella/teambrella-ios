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
}
