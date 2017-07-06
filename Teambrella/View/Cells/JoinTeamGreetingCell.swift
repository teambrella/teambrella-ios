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
    @IBOutlet var radarView: RadarView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        CellDecorator.roundedEdges(for: self)
        CellDecorator.shadow(for: self)
        greetingLabel.text = "Team.JoinTeamVC.GreetingCell.greeting".localized("Frank")
        let boldString = "Deductable Savers "
        let nonBoldString = "team are the best team for insuring olders cars. We’re just going to need a few details."
        let resultString = boldString + nonBoldString
        let range = NSRange(location: boldString.characters.count, length: nonBoldString.characters.count)
        textLabel.attributedText =  resultString.attributedBoldString(nonBoldRange: range)
    }

}
