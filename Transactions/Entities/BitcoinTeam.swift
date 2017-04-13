//
//  BitcoinTeam.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 13.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

public struct BitcoinTeam {
    let autoApprovalOff = -1
    let id: Int
    let name: String
    let isTestnet: Bool
    
    let payToAddressOKage: Int
    let autoApprovalMyGoodAddress: Int
    let autoApprovalCosignGoodAddress: Int
    let autoApprovalMyNewAddress: Int
    let autoApprovalCosignNewAddress: Int
    
    let teammates: [BitcoinTeammate]
    
    // network?
    
}
