//
//  SignHelper.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 10.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

struct SignHelper {
    
    // https://github.com/MetacoSA/NBitcoin/blob/7743174a1e746c4beaaf0bba0a435c3e960a9a41/NBitcoin/ScriptReader.cs
    // public static Op GetPushOp(byte[] data)
    static func redeemScript(address: BtcAddress) -> BTCScript {
        guard let publicKey = address.teammate?.publicKey else {
            fatalError("No public key")
        }
        
        print("creating BTCAddress with publicKey: \(publicKey)")
        let ownerPublicKey = Data(hex: publicKey)
    
        let cosignersPublicKeys = address.cosigners.flatMap { $0.teammate?.publicKey }.map { Data(hex:$0) }
        let n = cosignersPublicKeys.count
        guard let script = BTCScript() else { fatalError("Couldn't initialize script") }
        
        script.appendData(ownerPublicKey)
        script.append(BTCOpcode.OP_CHECKSIGVERIFY)
        if n > 6 {
            script.append(BTCOpcode.OP_3)
        } else if n > 3 {
            script.append(BTCOpcode.OP_2)
        } else if n > 0 {
            script.append(BTCOpcode.OP_1)
        } else {
            script.append(BTCOpcode.OP_0)
        }
        cosignersPublicKeys.forEach { key in
            script.appendData(key)
        }
        script.append(BTCOpcode(rawValue: UInt8(80 + n))!)
        script.append(BTCOpcode.OP_CHECKMULTISIG)
        guard let bigInt = BTCBigNumber(int64: Int64(address.teammate!.team!.id)) else { fatalError() }
        
        script.appendData(bigInt.signedLittleEndian)
        script.append(BTCOpcode.OP_DROP)
       return script
    }
 
    
    static func generateStringAddress(from address: BtcAddress) -> String {
        let script = redeemScript(address: address)
        guard let hash = script.scriptHashAddress else { fatalError() }
        return hash.public.string
        //return script.standardAddress.string
//        guard let hash = script.scriptHashAddress else { fatalError("Can't create hash") }
//        return hash.string
    }
    
    static func pubKeyScript(from address: BtcAddress) -> BTCScript {
        let script = redeemScript(address: address)
        guard let pubScript = BTCScript() else { fatalError() }
        
        pubScript.append(BTCOpcode.OP_HASH160)
       // Op.GetPushOp(redeemScript.GetScriptAddress(address.Teammate.Team.Network).ToBytes()),
        let network = address.teammate!.team!.network
       // let networkScript = script.pri
//        pubScript.append(BTCScript(data: network)
        pubScript.append(BTCOpcode.OP_EQUAL)
        return pubScript
    }
    
    static func cosign(redeemScript: BTCScript, key: BTCKey, transaction: BTCTransaction, inputNum: Int) -> Data {
        let machine = BTCScriptMachine(transaction: transaction, inputIndex: UInt32(inputNum))
//        let hash = machine.r
        let data = Data()
        return key.signature(forHash: data, hashType: BTCSignatureHashType.BTCSignatureHashTypeAll)
    }
     /*
     
     public static byte[] Cosign(Script redeemScript, Key key, Transaction transaction, int inputNum)
     {
     uint256 hash = redeemScript.SignatureHash(transaction, inputNum, SigHash.All);
     return key.Sign(hash).ToDER();
     }
     }
     */
}

