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
        headerLabel.text = "Your car".uppercased()
        makeAndModel.headerLabel.text = "Make and model".uppercased()
        makeAndModel.textField.text = "Ford Focus S"
        year.headerLabel.text = "Year".uppercased()
        year.textField.text = "2016"
        currency.headerLabel.text = "Currency".uppercased()
        currency.textField.text = "usd".uppercased()
        estimatedPrice.headerLabel.text = "Estimated price".uppercased()
        estimatedPrice.textField.text = "$17000"
        objectPhotosLabel.text = "Object photos".uppercased()
    }

}
