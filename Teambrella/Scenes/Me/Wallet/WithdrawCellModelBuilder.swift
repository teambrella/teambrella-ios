//
/* Copyright(C) 2017 Teambrella, Inc.
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

class WithdrawModelBuilder {
    func detailsModel() -> WithdrawDetailsCellModel {
        return WithdrawDetailsCellModel()
    }
    
    func modelFrom(transaction: WithdrawTx) -> WithdrawTransactionCellModel {
        var dateText = ""
        if let date = transaction.withdrawalDate {
            dateText = Formatter.teambrella.string(from: date)
        }
        return WithdrawTransactionCellModel(topText: dateText,
                                            isNew: transaction.isNew,
                                            bottomText: "No address given",
                                            amountText: String.truncatedNumber(transaction.amount))
    }
    
}

protocol WithdrawCellModel {
    
}

class WithdrawDetailsCellModel: WithdrawCellModel {
    var title: String = "WITHDRAW DETAILS"
    var toText: String = "TO"
    var toValue: String = ""
    var amountText: String = "AMOUNT mETH"
    var amountValue: String = ""
    var buttonTitle: String = "Submit"
    
}

struct WithdrawTransactionCellModel: WithdrawCellModel {
    let topText: String
    let isNew: Bool
    let bottomText: String
    let amountText: String
}
