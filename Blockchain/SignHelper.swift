//
//  SignHelper.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 10.05.17.

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

struct SignHelper {
    
    // https://github.com/MetacoSA/NBitcoin/blob/7743174a1e746c4beaaf0bba0a435c3e960a9a41/NBitcoin/ScriptReader.cs
    // public static Op GetPushOp(byte[] data)
    static func redeemScript(address: CryptoAddress) -> BTCScript {
        guard let publicKey = address.teammate.publicKey else {
            fatalError("No public key")
        }
        
        print("creating BTCAddress with publicKey: \(publicKey)")
        let ownerPublicKey = Data(hex: publicKey)
        
        let cosignersPublicKeys = address.cosigners.flatMap { $0.teammate.publicKey }.map { Data(hex:$0) }
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
        guard let bigInt = BTCBigNumber(int64: Int64(address.teammate.team.id)) else { fatalError() }
        
        script.appendData(bigInt.signedLittleEndian)
        script.append(BTCOpcode.OP_DROP)
        return script
    }
    
    
    static func generateStringAddress(from address: CryptoAddress) -> String {
        let script = redeemScript(address: address)
        let team = address.teammate.team
        
        let hashAddress: BTCAddress!
        if team.isTestnet {
            hashAddress = BTCScriptHashAddressTestnet(data: BTCHash160(script.data)! as Data)//script.scriptHashAddressTestnet
        } else {
            hashAddress = BTCScriptHashAddress(data: BTCHash160(script.data)! as Data)//script.scriptHashAddress
        }
        return hashAddress.string
    }
    
    //    static func pubKeyScript(from address: BtcAddress) -> BTCScript {
    //        let script = redeemScript(address: address)
    //        guard let pubScript = BTCScript() else { fatalError() }
    //
    //        pubScript.append(BTCOpcode.OP_HASH160)
    //        // Op.GetPushOp(redeemScript.GetScriptAddress(address.Teammate.Team.Network).ToBytes()),
    //        let network = address.teammate!.team!.network
    //        // let networkScript = script.pri
    //        //        pubScript.append(BTCScript(data: network)
    //        pubScript.append(BTCOpcode.OP_EQUAL)
    //        return pubScript
    //    }
    
    static func cosign(redeemScript: BTCScript, key: BTCKey, transaction: BTCTransaction, inputNum: Int) -> Data? {
        do {
            let hash = try transaction.signatureHash(for: redeemScript,
                                                     inputIndex: UInt32(inputNum),
                                                     hashType: .BTCSignatureHashTypeAll)
            return key.signature(forHash: hash)
        } catch {
            print("Cosign error")
            return nil
        }
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

