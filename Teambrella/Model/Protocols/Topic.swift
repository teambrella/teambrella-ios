//
//  Topic.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 11.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

protocol Topic: EntityLike {
    var posts: [Post] { get set }
}
