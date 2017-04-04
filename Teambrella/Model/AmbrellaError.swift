//
//  AmbrellaError.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 29.03.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

struct AmbrellaError: Error {
    let kind: AmbrellaErrorKind
    let description: String
    
    enum AmbrellaErrorKind: Int {
        case unknownError               = -666
        case emptyReply                 = -1
        
        case fatalError                 = 1
        case brokenSignature            = 2
        case permissionDenied           = 3
        
        case teamAlreadyJoined          = 5010
        case teamJoinedAndProxyExists   = 5011
        case teamRoutedToAddProxt       = 5012
        
        case badEmail                   = 701000
        case teamNotExists              = 701011
        case teamIsPrivate              = 701012
        
        case insuranseBasicNotExists    = 701020
        
        case teamsNotSelected           = 701021
        
        case teammateNoAccess           = 702001
        case teammateNotExists          = 702011
    }
    
}

struct AmbrellaErrorFactory {
    static func emptyReplyError() -> AmbrellaError {
        return AmbrellaError(kind: .emptyReply, description: "No content in reply")
    }
    
    static func unknownError() -> AmbrellaError {
        return AmbrellaError(kind: .unknownError, description: "Unknown error occured")
    }
    
    static func error(with dict: [String: Any]?) -> AmbrellaError {
        guard let dict = dict else { return unknownError() }
        guard let code = dict["ResultCode"] as? Int,
            let errorKind =  AmbrellaError.AmbrellaErrorKind(rawValue: code) else { return unknownError() }
        
        let errorDescription = dict["ErrorMessage"] as? String ?? ""
        return AmbrellaError(kind: errorKind, description: errorDescription)
    }
}
