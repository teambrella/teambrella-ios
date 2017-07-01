//
//  JoinTeamGreetingCell.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 01.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class JoinTeamGreetingCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var avatar: RoundImageView!
    @IBOutlet var greetingLabel: UILabel!
    @IBOutlet var textLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        greetingLabel.text = "Hi Frank!"
        let boldString = "Deductable Savers "
        let nonBoldString = "team are the best team for insuring olders cars. We’re just going to need a few details."
        let resultString = boldString + nonBoldString
        let range = NSMakeRange(boldString.characters.count, resultString.characters.count)
        textLabel.attributedText = attributedString(from: resultString, nonBoldRange: range)
    }
    
    func attributedString(from string: String, nonBoldRange: NSRange?) -> NSAttributedString {
        let fontSize = UIFont.systemFontSize
        let attrs = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: fontSize),
            NSForegroundColorAttributeName: UIColor.black
        ]
        let nonBoldAttribute = [NSFontAttributeName: UIFont.systemFont(ofSize: fontSize)]
        let attrStr = NSMutableAttributedString(string: string, attributes: attrs)
        if let range = nonBoldRange {
            attrStr.setAttributes(nonBoldAttribute, range: range)
        }
        return attrStr
    }

}
