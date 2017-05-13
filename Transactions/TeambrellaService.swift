//
//  TeambrellaService.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 11.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol TeambrellaServiceDelegate: class {
    func teambrellaDidUpdate(service: TeambrellaService)
}

class TeambrellaService {
    let server = BlockchainServer()
    let storage = BlockchainStorage()
    lazy var service = BlockchainService()
    weak var delegate: TeambrellaServiceDelegate?
    var fetcher: BlockchainStorageFetcher { return storage.fetcher }
    
    init() {
        server.delegate = self
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func update() {
        cosignApprovedTxs()
        publishApprovedAndCosignedTxs()
        save()
    }
    
    func save() {
        let lastUpdated = storage.lastUpdated
        guard let transactions = fetcher.transactionsNeedServerUpdate else { fatalError() }
        guard let signatures = fetcher.signaturesToUpdate else { fatalError() }
        
        server.getUpdates(privateKey: User.Constant.tmpPrivateKey,
                          lastUpdated: lastUpdated,
                          transactions: transactions,
                          signatures: signatures)
    }
    
 
    
    func cosignApprovedTxs() {
        let user = fetcher.user
        guard let txs = fetcher.transactionsResolvable else { return }
        
        txs.forEach { tx in
        
        }
        /*
         var user = _accountService.GetUser();
         var txs = _accountService.GetCoSignableTxs();
         foreach (var tx in txs)
         {
         var blockchainTx = GetTx(tx);
         var redeemScript = SignHelper.GetRedeemScript(tx.FromAddress);
         var txInputs = tx.Inputs.OrderBy(x => x.Id).ToList();
         for (int input = 0; input < txInputs.Count; input++)
         {
         var txInput = txInputs[input];
         var signature = SignHelper.Cosign(redeemScript, user.BitcoinPrivateKey, blockchainTx, input);
         var txSignature = new TxSignature
         {
         TxInput = txInput,
         Teammate = tx.Teammate.Team.GetMe(user),
         NeedUpdateServer = true,
         Signature = signature
         };
         _accountService.AddSignature(txSignature);
         }
         tx.Resolution = TxClientResolution.Signed;
         _accountService.UpdateTx(tx);
         }
         _accountService.SaveChanges();
         */

    }
    // add periodical sync with server
    // add changes listener
    
    func publishApprovedAndCosignedTxs() {
        /*
         var user = _accountService.GetUser();
         var txs = _accountService.GetApprovedAndCosignedTxs();
         foreach (var tx in txs)
         {
         var blockchainTx = GetTx(tx);
         var redeemScript = SignHelper.GetRedeemScript(tx.FromAddress);
         var txInputs = tx.Inputs.OrderBy(x => x.Id).ToList();
         
         List<Op>[] ops = new List<Op>[tx.Inputs.Count];
         foreach (var cosigner in tx.FromAddress.Cosigners.OrderBy(x => x.KeyOrder))
         {
         for (int input = 0; input < txInputs.Count; input++)
         {
         var txInput = txInputs[input];
         var txSignature = _accountService.GetSignature(txInput.Id, cosigner.Teammate.Id);
         if (txSignature == null)
         {
         break;
         }
         if (ops[input] == null)
         {
         ops[input] = new List<Op>();
         }
         if (ops[input].Count == 0)
         {
         ops[input].Add(OpcodeType.OP_0);
         }
         
         var vchSig = txSignature.Signature.ToList();
         vchSig.Add((byte)SigHash.All);
         ops[input].Add(Op.GetPushOp(vchSig.ToArray()));
         }
         }
         
         for (int input = 0; input < txInputs.Count; input++)
         {
         // add self-signatures
         var signature = SignHelper.Cosign(redeemScript, user.BitcoinPrivateKey, blockchainTx, input);
         var vchSig = signature.ToList();
         var txSignature = new TxSignature
         {
         TxInput = txInputs[input],
         Teammate = tx.Teammate.Team.GetMe(user),
         NeedUpdateServer = true,
         Signature = signature
         };
         _accountService.AddSignature(txSignature);
         
         
         vchSig.Add((byte)SigHash.All);
         ops[input].Add(Op.GetPushOp(vchSig.ToArray()));
         ops[input].Add(Op.GetPushOp(redeemScript.ToBytes()));
         blockchainTx.Inputs[input].ScriptSig = new Script(ops[input].ToArray());
         }
         
         string strTx = blockchainTx.ToHex();
         
         if (PostTx(strTx, tx.Teammate.Team.Network))
         {
         _accountService.ChangeTxResolution(tx, TxClientResolution.Published);
         }
         }
         */
    }
}

extension TeambrellaService: BlockchainServerDelegate {
    func serverInitialized(server: BlockchainServer) {
        print("server initialized")
    }
    
    func server(server: BlockchainServer, didReceiveUpdates updates: JSON, updateTime: Int64) {
        print("server received updates: \(updates)")
        storage.update(with: updates, updateTime: updateTime) { [weak self] in
            if let me = self {
                me.delegate?.teambrellaDidUpdate(service: me)
            }
        }
    }
    
    func server(server: BlockchainServer, didUpdateTimestamp timestamp: Int64) {
        print("server updated timestamp: \(timestamp)")
    }
    
    func server(server: BlockchainServer, failedWithError error: Error?) {
        error.map { print("server request failed with error: \($0)") }
    }
}
