//
//  ImageGalleryCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 07.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import ImageSlideshow
import Kingfisher
import UIKit

class ImageGalleryCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var slideshow: ImageSlideshow!
    @IBOutlet var avatarView: RoundImageView!
    @IBOutlet var titleLabel: MessageTitleLabel!
    @IBOutlet var textLabel: MessageTextLabel!
    @IBOutlet var timeLabel: InfoLabel!
    @IBOutlet var unreadCountLabel: RoundImageView!
    
    var tapGalleryGesture: UITapGestureRecognizer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupGallery(with imageURLs: [String], options: KingfisherOptionsInfo? = nil) {
        guard slideshow.images.isEmpty else { return }
        
        let inputs: [InputSource] = imageURLs.flatMap { KingfisherSource(urlString: $0, options: options) }
        slideshow.setImageInputs(inputs)
        slideshow.contentScaleMode = .scaleAspectFill
    }

}
