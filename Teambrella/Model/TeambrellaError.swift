//
//  AmbrellaError.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 29.03.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

struct TeambrellaError: Error {
    let kind: TeambrellaErrorKind
    let description: String
    
    enum TeambrellaErrorKind: Int {
        case unknownError               = -666
        case emptyReply                 = -1
        
        case fatalError                 = 1
        case brokenSignature            = 2
        case permissionDenied           = 3
        case keyAlreadyRegistered       = 5
        
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

struct TeambrellaErrorFactory {
    static func emptyReplyError() -> TeambrellaError {
        return TeambrellaError(kind: .emptyReply, description: "No content in reply")
    }
    
    static func unknownError() -> TeambrellaError {
        return TeambrellaError(kind: .unknownError, description: "Unknown error occured")
    }
    
    static func error(with status: ResponseStatus?) -> TeambrellaError {
        guard let status = status else { return unknownError() }
        guard let errorKind =  TeambrellaError.TeambrellaErrorKind(rawValue: status.code) else { return unknownError() }
        
        return TeambrellaError(kind: errorKind, description: status.errorMessage)
    }
    
}
