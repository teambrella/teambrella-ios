//
//  JoinTeamMessageCell.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 01.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class JoinTeamMessageCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var message: LabeledTextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        headerLabel.text = "Team".uppercased()
        message.headerLabel.text = "Message to teammates".uppercased()
        // swiftlint:disable:next line_length
        message.textField.placeholder = "Introduce yourself to your future team mates by telling them a bit more about yourself. Note that this will help them approve of decline your application"
    }

}
