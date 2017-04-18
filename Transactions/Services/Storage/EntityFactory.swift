//
//  EntityFactory.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 18.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import CoreData
import Foundation
import SwiftyJSON

struct EntityFactory {
    let context: NSManagedObjectContext
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    func addresses(json: JSON) -> [KeychainAddress] {
        return json.arrayValue.map { item in
            let address = KeychainAddress(context: context)
            address.address = item["Address"].stringValue
            address.dateCreated = formatter.date(from: item["DateCreated"].stringValue) as NSDate?
            address.rawStatus = item["Status"].int16Value
            address.teammateID = item["TeammateId"].int64Value
            return address
        }
    }
    
    func cosigners(json: JSON) -> [KeychainCosigner] {
        return json.arrayValue.map { item in
            let cosigner = KeychainCosigner(context: context)
            cosigner.addressID = item["Address"].stringValue
            cosigner.keyOrder = item["KeyOrder"].int16Value
            cosigner.teammateID = item["TeammateId"].int64Value
            return cosigner
        }
    }
    
    func payTos(json: JSON) -> [KeychainPayTo] {
        return json.arrayValue.map { item in
            let payTo = KeychainPayTo(context: context)
            payTo.address = item["Address"].stringValue
            payTo.id = item["Id"].stringValue
            payTo.isDefault = item["IsDefault"].boolValue
            payTo.knownSince = formatter.date(from: json["KnownSince"].stringValue) as NSDate?
            payTo.teammateID = item["TeammateId"].int64Value
            return payTo
        }
    }
    
    // Teammates
    func teammates(json: JSON) -> [KeychainTeammate] {
        /*
         FBName = "";
         Id = 237;
         Name = "August Macke";
         PublicKey = "<null>";
         TeamId = 2;
         */
        return json.arrayValue.map { item in
            let teammate = KeychainTeammate(context: context)
            teammate.fbName = item["FBName"].stringValue
            teammate.id = item["Id"].int64Value
            teammate.name = item["Name"].stringValue
            teammate.publicKey = item["PublicKey"].string
            teammate.teamID = item["TeamId"].int64Value
            return teammate
        }
    }
    
    // Teams
    func teams(json: JSON) -> [KeychainTeam] {
        /*
         Id = 2;
         Name = "4 legged friend";
         Testnet = 1;
         
 */
        return json.arrayValue.map { item in
            let team = KeychainTeam(context: context)
            team.id = item["Id"].int64Value
            team.name = item["Name"].stringValue
            team.isTestnet = item["Testnet"].boolValue
            return team
        }
    }
    
    // TxInputs
    func inputs(json: JSON) -> [KeychainInput] {
        /* */
        return []
    }
    
    // TxOutputs
    func outputs(json: JSON) -> [KeychainOutput] {
        /*
         AmountBTC = "0.03869702";
         Id = "00000000-0000-0000-0000-000000000036";
         PayToId = "00000000-0000-0000-0000-00000000000a";
         TxId = "00000000-0000-0000-0000-000000000036";
 */
        return json.arrayValue.map { item in
            let output = KeychainOutput(context: context)
            output.ammount = Decimal(item["AmountBTC"].doubleValue) as NSDecimalNumber
            output.id = item["Id"].stringValue
            output.payToID = item["PayToId"].stringValue
            output.transactionID = item["TxId"].stringValue
            return output
        }
    }
    
    // TxSignatures
    func signatures(json: JSON) -> [KeychainSignature] {
        /* */
        return []
    }
    
    // Txs
    func transactions(json: JSON) -> [KeychainTransaction] {
        /*
         AmountBTC = "0.01107533";
         ClaimId = 1;
         ClaimTeammateId = 16;
         Id = "00000000-0000-0000-0000-000000000042";
         InitiatedTime = "2016-07-02 19:09:16";
         Kind = 0;
         State = 10;
         TeammateId = 16;
         WithdrawReqId = "<null>";
 */
        return json.arrayValue.map { item in
            let transaction = KeychainTransaction(context: context)
            transaction.amountBTC = Decimal(item["AmountBTC"].doubleValue) as NSDecimalNumber
            transaction.claimID = item["ClaimId"].int64Value
            transaction.claimTeammateID = item["ClaimTeammateId"].int64Value
            transaction.id = item["Id"].stringValue
            if let initiatedTime = formatter.date(from: json["InitiatedTime"].stringValue) as? NSDate {
            transaction.initiatedTime = initiatedTime
            }
            transaction.rawKind = item["Kind"].int16Value
            transaction.rawState = item["State"].int16Value
            transaction.teammateID = item["TeammateId"].int64Value
            transaction.withdrawReqID = item["WithdrawReqId"].int64Value
            return transaction
        }
    }
    
}
