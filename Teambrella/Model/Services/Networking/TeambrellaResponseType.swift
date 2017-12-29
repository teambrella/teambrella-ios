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
import SwiftyJSON

enum TeambrellaResponseType {
    case timestamp
    case initClient
    case updates
    case teams(TeamsModel)
    case teammatesList([TeammateEntity])
    case teammate(ExtendedTeammateEntity)
    case teammateVote(JSON)
    case newPost(ChatEntity)
    case registerKey
    case coverageForDate(Double, Double)
    case setLanguage(String)
    case claimsList([ClaimEntity])
    case claim(EnhancedClaimEntity)
    case claimVote(JSON)
    case claimUpdates(JSON)
    case claimTransactions([ClaimTransactionsCellModel])
    case home(JSON)
    case feedDeleteCard(HomeScreenModel)
    case teamFeed(FeedChunk)
    case chat(ChatModel)
    case wallet(WalletEntity)
    case walletTransactions([WalletTransactionsCellModel])
    case uploadPhoto(String)
    case myProxy(Bool)
    case myProxies([ProxyCellModel])
    case proxyFor([ProxyForCellModel], Double)
    case proxyPosition
    case proxyRatingList([UserIndexCellModel], Int)
    
    case privateList([PrivateChatUser])
    case privateChat([ChatEntity])
    case withdrawTransactions(WithdrawChunk)
    case mute(Bool)
    
    case votesList(VotersList)
}
