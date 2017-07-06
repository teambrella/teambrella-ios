//
//  JoinTeamItemCell.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 01.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class JoinTeamItemCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var makeAndModel: LabeledTextField!
    @IBOutlet var year: LabeledTextField!
    @IBOutlet var currency: LabeledTextField!
    @IBOutlet var estimatedPrice: LabeledTextField!
    @IBOutlet var objectPhotosLabel: UILabel!
    @IBOutlet var photos: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        headerLabel.text = "Team.JoinTeamVC.ItemCell.headerLabel".localized
        makeAndModel.headerLabel.text = "Team.JoinTeamVC.ItemCell.makeModel".localized
        makeAndModel.textField.text = "Ford Focus S"
        year.headerLabel.text = "Team.JoinTeamVC.ItemCell.year".localized
        year.textField.text = "2016"
        currency.headerLabel.text = "Team.JoinTeamVC.ItemCell.currency".localized
        currency.textField.text = "usd".uppercased()
        estimatedPrice.headerLabel.text = "Team.JoinTeamVC.ItemCell.price".localized
        estimatedPrice.textField.text = "$17000"
        objectPhotosLabel.text = "Team.JoinTeamVC.ItemCell.objectPhotos".localized
    }

}
