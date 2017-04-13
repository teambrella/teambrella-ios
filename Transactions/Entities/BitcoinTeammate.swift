//
//  BitcoinTeammate.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 13.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

public struct BitcoinTeammate {
    let id: Int
    let teamID: Int
    let name: String
    let fbName: String
    let publicKey: String
    
    let team: BitcoinTeam
    let payTo: [BitcoinPayTo]
    let addresses: [BitcoinAddress]
    
    var addressPrevious: BitcoinAddress? {
        return addresses.filter { $0.status == .previous }.first
    }
    var addressCurrent: BitcoinAddress? {
        return addresses.filter { $0.status == .current }.first
    }
    var addressNext: BitcoinAddress? {
        return addresses.filter { $0.status == .next }.first
    }
    let cosignerOf: [BitcoinCosigner]
//    let disbandings: [Disbanding]
//    let currentDisbanding: Disbanding
    
}
