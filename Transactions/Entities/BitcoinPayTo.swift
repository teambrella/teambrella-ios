//
//  BitcoinPayTo.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 13.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

public struct BitcoinPayTo {
    let id: String
    let teammateID: Int
    let knownSince: Date
    let address: String
    let isDefault: Bool
    let teammate: BitcoinTeammate
}
