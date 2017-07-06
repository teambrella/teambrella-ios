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
}
