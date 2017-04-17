//
//  BitcoinPayTo.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 13.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct BitcoinPayTo {
    let id: String
    let teammateID: Int
    let knownSince: Date
    let address: String
    let isDefault: Bool
    var teammate: BitcoinTeammate?

}

public struct BitcoinPayToFactory {
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    func payTos(from json: JSON) -> [BitcoinPayTo] {
        return json.arrayValue.map { self.payTo(json: $0) }
    }
    
    func payTo(json: JSON) -> BitcoinPayTo {
        return BitcoinPayTo(id: json["Id"].stringValue,
                            teammateID: json["TeammateId"].intValue,
                            knownSince: formatter.date(from: json["KnownSince"].stringValue) ?? Date(),
                            address: json["Address"].stringValue,
                            isDefault: json["IsDefault"].boolValue,
                            teammate: nil)
    }
}
