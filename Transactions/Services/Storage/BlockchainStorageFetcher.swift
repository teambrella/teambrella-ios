//
//  BlockchainStorageFetcher.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 25.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import CoreData

class BlockchainStorageFetcher {
    let context: NSManagedObjectContext!
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: User
    var user: User {
        let request: NSFetchRequest<User> = User.fetchRequest()
       // request.predicate = NSPredicate(format: "addressValue = %@", id)
        let result = try? context.fetch(request)
        if let user = result?.first {
            return user
        } else {
            return createUser()
        }
    }
    
    private func createUser() -> User {
        let user = User(context: context)
        //   PrivateKey = key.GetBitcoinSecret(Network.Main).ToString()
        user.privateKeyValue =  User.Constant.tmpPrivateKey
        try? context.save()
        return user
    }
    
    // MARK: Address
    
    func address(id: String) -> BtcAddress? {
        let request: NSFetchRequest<BtcAddress> = BtcAddress.fetchRequest()
        request.predicate = NSPredicate(format: "addressValue = %@", id)
        let result = try? context.fetch(request)
        return result?.first
    }
    
    // MARK: Cosigner
    
    func cosigners(for teammate: Teammate) -> [Cosigner] {
            let request: NSFetchRequest<Cosigner> = Cosigner.fetchRequest()
            request.predicate = NSPredicate(format: "teammate = %@", teammate)
            let result = try? context.fetch(request)
            return result ?? []
    }
    
    // MARK: Team
    
    var firstTeam: Team? {
        let request: NSFetchRequest<Team> = Team.fetchRequest()
        let items = try? context.fetch(request)
        return items?.first
    }
    
    // MARK: Teammate
    
    var teammates: [Teammate]? {
        let request: NSFetchRequest<Teammate> = Teammate.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "nameValue", ascending: true)]
        let items = try? context.fetch(request)
        return items
    }
    
    // MARK: Transaction
    
     func transaction(id: String) -> Tx? {
        let request: NSFetchRequest<Tx> = Tx.fetchRequest()
        request.predicate = NSPredicate(format: "idValue = %@", id)
        let result = try? context.fetch(request)
        return result?.first
    }
    
    var resolvableTransactions: [Tx]? {
        let request: NSFetchRequest<Tx> = Tx.fetchRequest()
        request.predicate = NSPredicate(format: "resolutionValue <= \(TransactionClientResolution.published.rawValue)")
        //request.sortDescriptors = [NSSortDescriptor(key: "resolutionValue", ascending: true)]
        let items = try? context.fetch(request)
        return items
    }
    
    var cosignableTransactions: [Tx]? {
        let request: NSFetchRequest<Tx> = Tx.fetchRequest()
        request.predicate = NSPredicate(format: "resolutionValue == \(TransactionClientResolution.approved.rawValue)" +
            " AND stateValue == \(TransactionState.selectedForCosigning.rawValue)"/* +
            " AND inputs.@count > 0"*/)
        //request.sortDescriptors = [NSSortDescriptor(key: "resolutionValue", ascending: true)]
        let items = try? context.fetch(request)
        return items
    }
    
    // MARK: Signatures
    
    var signaturesToUpdate: [TxSignature]? {
        let request: NSFetchRequest<TxSignature> = TxSignature.fetchRequest()
        request.predicate = NSPredicate(format: "isServerUpdateNeededValue == TRUE")

        let items = try? context.fetch(request)
        return items
    }
    

//    var pendingPayments: [BlockchainPayTo]? {
//        let request: NSFetchRequest<BlockchainTeammate> = BlockchainPayTo.fetchRequest()
//        request.sortDescriptors = [NSSortDescriptor(key: "nameValue", ascending: true)]
//        let items = try? storage.context.fetch(request)
//        return items
//    }
}
