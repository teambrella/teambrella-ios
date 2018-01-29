//
/* Copyright(C) 2018 Teambrella, Inc.
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

struct CryptoServerUpdateInfo: Encodable, CustomStringConvertible {
    let txInfos: [TxInfo]
    let txSignatures: [TxSignatureInfo]
    let cryptoContracts: [MultisigInfo]
    let since: Int64

    var description: String {
        return """
        CryptoServerUpdateInfo{txInfos: \(txInfos.count), txSignatures: \(txSignatures.count), \
        cryptoContracts: \(cryptoContracts.count), since: \(since)}
        """
    }

    init(multisigs: [Multisig],
    transactions: [Tx],
    signatures: [TxSignature],
    lastUpdated: Int64, 
    formatter: BlockchainDateFormatter) {
        txInfos = transactions.flatMap { TxInfo(tx: $0, formatter: formatter) }
        txSignatures = signatures.map { TxSignatureInfo(txSignature: $0) }
        cryptoContracts = multisigs.flatMap { MultisigInfo(multisig: $0) }
        since = lastUpdated
    }

    enum CodingKeys: String, CodingKey {
case txInfos = "TxInfos"
        case txSignatures = "TxSignatures"
        case cryptoContracts = "CryptoContracts"
        case since = "Since"
    }

    struct TxInfo: Encodable {
        let id: String
        let resolutionTime: String
        let resolution: Int

        init?(tx: Tx, formatter: BlockchainDateFormatter) {
            guard let clientResolution = tx.clientResolutionTime else { return nil }

            id = tx.id.uuidString
            resolutionTime = formatter.string(from: clientResolution)
            resolution = tx.resolution.rawValue
        }

        enum CodingKeys: String, CodingKey {
            case id = "Id"
            case resolutionTime = "ResolutionTime"
            case resolution = "Resolution"
        }
    }

    struct TxSignatureInfo: Encodable {
        let signature: String
        let teammateID: Int
        let txInputID: String

        init(txSignature: TxSignature) {
            signature = txSignature.signature.base64EncodedString()
            teammateID = txSignature.teammateID
            txInputID = txSignature.inputID.uuidString
        }

        enum CodingKeys: String, CodingKey {
            case signature = "Signature"
            case teammateID = "TeammateId"
            case txInputID = "TxInputId"
        }
    }

    struct MultisigInfo: Encodable {
        let id: Int
        let teammateID: Int
        let creationTxID: String

        init?(multisig: Multisig) {
            guard let teammateID = multisig.teammate?.id else { return nil }
            guard let creationTxID = multisig.creationTx else { return nil }

            id = multisig.id
            self.teammateID = teammateID
            self.creationTxID = creationTxID
        }

        enum CodingKeys: String, CodingKey {
            case id = "Id"
            case teammateID = "TeammateId"
            case creationTxID = "BlockchainTxId"
        }
    }

}
