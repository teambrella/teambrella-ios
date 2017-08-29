//
//  PhotoPreviewDelegate.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 21.08.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

protocol PhotoPreviewDelegate: class {
    func photoPreview(controller: PhotoPreviewVC, didDeleteItemAt indexPath: IndexPath)
    
}
