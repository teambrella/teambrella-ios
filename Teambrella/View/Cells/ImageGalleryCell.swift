//
//  ImageGalleryCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 07.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit
import ImageSlideshow

class ImageGalleryCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var slideshow: ImageSlideshow!
    @IBOutlet var avatarView: RoundImageView!
    @IBOutlet var titleLabel: MessageTitleLabel!
    @IBOutlet var textLabel: MessageTextLabel!
    @IBOutlet var timeLabel: InfoLabel!
    @IBOutlet var unreadCountLabel: RoundImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupGallery(with imageURLs: [String]) {
        let inputs: [InputSource] = imageURLs.flatMap { KingfisherSource(urlString: $0) }
        slideshow.setImageInputs(inputs)
    }

}
