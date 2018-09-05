//
//  AmbrellaError.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 29.03.17.

/* Copyright(C) 2017  Teambrella, Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License(version 3) as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see<http://www.gnu.org/licenses/>.
 */

import Foundation

struct TeambrellaError: Error {
    let kind: TeambrellaErrorKind
    let description: String
    var nsError: NSError {
        return NSError(domain: "Teambrella.error", code: kind.rawValue, userInfo: ["description": description])
    }
    
    enum TeambrellaErrorKind: Int {
        case unknownError                = -666
        case wrongReply                  = -665
        case malformedEthereumAddress    = -664
        case malformedDate               = -663
        case noPagingInfo                = -662
        case emptyReply                  = -1

        case fatalError                  = 1
        case brokenSignature             = 2
        case permissionDenied            = 3
        case keyAlreadyRegistered        = 5
        case noTeamsYet                  = 6
        case noTeamsApplicationPending   = 8
        case noTeamsApplicationApproved  = 9
        case argumentOutOfRange          = 10
        case unsupportedClientVersion    = 12
        case noTeamButApplicationStarted = 13

        case teamAlreadyJoined           = 5010
        case teamJoinedAndProxyExists    = 5011
        case teamRoutedToAddProxt        = 5012

        case badEmail                    = 701000
        case teamNotExists               = 701011
        case teamIsPrivate               = 701012

        case insuranseBasicNotExists     = 701020

        case teamsNotSelected            = 701021

        case teammateNoAccess            = 702001
        case teammateNotExists           = 702011

        case noTopicFound                = 703111

        case claimNotExists              = 704011

        case withdrawalAddressEmpty      = 710101
        case withdrawalAddressFormat     = 710102
        case withdrawalAddressChecksum   = 710103

        case walletNotCreated            = 710013

        case keyIsNotForDemo             = 901000
        case demoNotDeductibleTeam       = 901001
        case demoNotPetTeam              = 901002

        case serverTimeout               = -1001

        case malformedETCSignature       = -10001
    }
    
}

enum ServerServiceError: Error {
    case unknownStatus(ServerStatus?)
    case statusNotReceived
}

struct TeambrellaErrorFactory {
    static func emptyReplyError() -> TeambrellaError {
        return TeambrellaError(kind: .emptyReply, description: "No content in reply")
    }
    
    static func unknownError() -> TeambrellaError {
        return TeambrellaError(kind: .unknownError, description: "Unknown error occured")
    }

    static func wrongReply() -> TeambrellaError {
        return TeambrellaError(kind: .wrongReply, description: "Wrong reply from server")
    }

    static func noPagingInfo() -> TeambrellaError {
        return TeambrellaError(kind: .noPagingInfo, description: "No Paging info")
    }
    static func malformedEthereumAddress() -> TeambrellaError {
        return TeambrellaError(kind: .malformedEthereumAddress, description: "Not a valid Ethereum address")
    }
    
    static func malformedDate(format: String) -> TeambrellaError {
        return TeambrellaError(kind: .malformedDate, description: "Date string is in incorrect format: \(format)")
    }
    
    static func error(with status: ServerStatus?) -> Error {
        guard let status = status else { return ServerServiceError.statusNotReceived }
        guard let errorKind = TeambrellaError.TeambrellaErrorKind(rawValue: status.resultCode) else {
            return ServerServiceError.unknownStatus(status)
        }
        
        return TeambrellaError(kind: errorKind, description: status.errorMessage ?? "")
    }
    
    static func malformedETCsignature() -> TeambrellaError {
        return TeambrellaError(kind: .malformedETCSignature,
                               description: "Couldn't create ETH signature for the given public key")
    }
    
}
