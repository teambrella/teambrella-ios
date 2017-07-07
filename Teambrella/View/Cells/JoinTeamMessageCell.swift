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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholder.text = ""
    }
}
