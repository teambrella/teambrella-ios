//
//  JoinTeamMessageCell.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 01.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class JoinTeamMessageCell: UICollectionViewCell, XIBInitableCell, UITextViewDelegate {
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var secondLabel: UILabel!
    @IBOutlet var message: UITextView!
    @IBOutlet var placeholder: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        message.delegate = self
        headerLabel.text = "Team.JoinTeamVC.MessageCell.headerLabel".localized
        secondLabel.text = "Team.JoinTeamVC.MessageCell.messageTitle".localized
        message.layer.borderWidth = 1
        message.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
        message.layer.cornerRadius = 3
        // swiftlint:disable:next line_length
        placeholder.text = "Team.JoinTeamVC.MessageCell.placeholder".localized
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholder.text = ""
    }
}
