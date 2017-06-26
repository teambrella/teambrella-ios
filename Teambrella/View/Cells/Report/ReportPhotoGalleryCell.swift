//
//  ReportPhotoGalleryCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 24.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class ReportPhotoGalleryCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var headerLabel: Label!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
