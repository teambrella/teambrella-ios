//
//  CoverageType.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 15.08.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

enum CoverageType: Int {
    case other                        = 0
    case bicycle                      = 40
    case carCollisionDeductable       = 100
    case carCollision                 = 101
    case carComprehensive             = 102
    case thirdParty                   = 103
    case carCollisionAndComprehensive = 104
    case drone                        = 140
    case mobile                       = 200
    case homeAppliances               = 220
    case pet                          = 240
    case unemployment                 = 260
    case healthDental                 = 280
    case healthOther                  = 290
    case businessBees                 = 400
    case businessCrime                = 440
    case businessLiability            = 460
}
