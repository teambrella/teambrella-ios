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

protocol CryptoServerReply {
    var status: ServerStatusImpl { get }
}

struct UpdatesServerImpl: Codable, CustomStringConvertible {
    let lastUpdated: Int64

    let multisigs: [MultisigServerImpl]
    let txs: [TxServerImpl]
    let cosigners: [CosignerServerImpl]
    let txSignatures: [TxSignatureServerImpl]
    let payTos: [PayToServerImpl]
    let txOutputs: [TxOutputServerImpl]
    let teammates: [TeammateServerImpl]
    let teams: [TeamServerImpl]
    let txInputs: [TxInputServerImpl]

    var description: String {
        return """
        \(type(of: self)){ \
        multisigs: \(multisigs.count), txs: \(txs.count), cosigners: \(cosigners.count), \
        txSignatures: \(txSignatures.count), payTos: \(payTos.count), txOutputs: \(txOutputs.count), \
        teammates: \(teammates.count), teams: \(teams.count), txInputs: \(txInputs.count)}, \
        lastUpdated: \(lastUpdated)
        """
    }

    enum CodingKeys: String, CodingKey {
        case lastUpdated = "LastUpdated"
        case multisigs = "Multisigs"
        case txs = "Txs"
        case cosigners = "Cosigners"
        case txSignatures = "TxSignatures"
        case payTos = "PayTos"
        case txOutputs = "TxOutputs"
        case teammates = "Teammates"
        case teams = "Teams"
        case txInputs = "TxInputs"
    }

}

struct ServerStatusImpl: Codable {
    let timestamp: Int64

    enum CodingKeys: String, CodingKey {
        case timestamp = "Timestamp"
    }
}

struct TimestampReplyServerImpl: Codable, CryptoServerReply {
    let status: ServerStatusImpl

    enum CodingKeys: String, CodingKey {
        case status = "Status"
    }
}

struct GetUpdatesReplyServerImpl: Codable, CryptoServerReply {
    let status: ServerStatusImpl
    let updates: UpdatesServerImpl

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case updates = "Data"
    }
}
