//
//  PhotoPreviewCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 21.08.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class PhotoPreviewCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var cancelButton: UIButton!
    var imageString: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
