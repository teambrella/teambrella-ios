//
//  ReportContext.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 18.08.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

enum ReportContext {
    // ClaimItem Coverage, Balance
    case claim(item: ClaimItem, coverage: Double, balance: Double)
}

struct ClaimItem {
    let name: String
    let photo: String
    let location: String
}
