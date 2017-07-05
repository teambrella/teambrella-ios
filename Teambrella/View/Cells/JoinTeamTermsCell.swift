//
//  JoinTeamTermsCell.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 01.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class JoinTeamTermsCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var textView: UITextView!
    @IBOutlet var bottomLabel: UILabel!
    var nonBoldString = ""
    var boldString = ""
  
    override func awakeFromNib() {
        super.awakeFromNib()
        headerLabel.text = "Terms & conditions".uppercased()
        // swiftlint:disable:next line_length
        textView.text = "This team covers Jimmy Wong for the amount of their regular collision policy deductible. Integer posuere erat a ante venenatis dapibus posuere velit aliquet. Nulla vitae elit libero, a pharetra augue. Cras mattis consectetur purus sit amet fermentum. Nullam id dolor id nibh ultricies vehicula ut id elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec id elit non mi porta gravida at eget metus. Integer posuere erat a ante venenatis dapibus posuere velit aliquet. Praesent commodo cursus magna, vel scelerisque nisl consectetur et. Nullam quis risus eget urna mollis ornare vel eu leo. Cras justo odio, dapibus ac facilisis in, egestas eget quam. Maecenas faucibus mollis interdum. Nulla vitae elit libero, a pharetra augue. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus. Nullam quis risus eget urna mollis ornare vel eu leo. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis mollis, est non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit. Praesent commodo cursus magna, vel scelerisque nisl consectetur et. Integer posuere erat a ante venenatis dapibus posuere velit aliquet. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Cras justo odio, dapibus ac facilisis in, egestas eget quam. Morbi leo risus, porta ac consectetur ac, vestibulum at eros. Curabitur blandit tempus porttitor. Donec sed odio dui. Aenean lacinia bibendum nulla sed consectetur."
        textView.contentInset.left = 0
        
        nonBoldString = "By pressing on ‘Send Application’\nI accept the Teambrella’s "
        boldString = "Terms & Conditions"
        let resultString = nonBoldString + boldString
        let range = NSRange(location: 0, length: nonBoldString.characters.count)
        bottomLabel.attributedText = resultString.attributedBoldString(nonBoldRange: range)
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
