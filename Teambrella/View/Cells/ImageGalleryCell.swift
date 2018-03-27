//
//  ImageGalleryCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 07.06.17.

/* Copyright(C) 2017  Teambrella, Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License(version 3) as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see<http://www.gnu.org/licenses/>.
 */

import ImageSlideshow
import Kingfisher
import UIKit

class ImageGalleryCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var slideshow: ImageSlideshow!
    @IBOutlet var avatarView: RoundImageView!
    @IBOutlet var titleLabel: MessageTitleLabel!
    @IBOutlet var textLabel: MessageTextLabel!
    @IBOutlet var timeLabel: ThinStatusSubtitleLabel!
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
