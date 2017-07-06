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
}
