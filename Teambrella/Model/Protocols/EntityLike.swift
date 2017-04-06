//
//  EntityLike.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 06.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol EntityLike: CustomStringConvertible {
    /// id of the item in the current context
    var id: String { get }
    /// entity version (every change of this entity on server increments this)
    var ver: Int64 { get }
    
    init(json: JSON)
}
