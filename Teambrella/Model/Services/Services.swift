//
//  Services.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 04.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

fileprivate(set)var service = ServicesHandler.i

class ServicesHandler {
    static let i = ServicesHandler()
    
//    lazy var bitcoin = BitcoinService()
    lazy var server = ServerService()
    lazy var transformer = TransformerService()
    lazy var router = MainRouter()
    lazy var socket = SocketService()
    
    private init() {}
    
}
