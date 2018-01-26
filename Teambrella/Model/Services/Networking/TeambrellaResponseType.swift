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
    case teammatesList([TeammateListEntity])
    case teammate(TeammateLarge)
    case teammateVote(TeammateVotingResult)
    case newPost(ChatEntity)
    case registerKey
    case coverageForDate(Double, Double)
    case setLanguage(String)
    case claimsList([ClaimEntity])
    case claim(ClaimEntityLarge)
    case claimVote(JSON)
    case claimUpdates(JSON)
    case claimTransactions([ClaimTransactionsModel])
    case home(HomeModel)
    case feedDeleteCard(HomeModel)
    case teamFeed(FeedChunk)
    case chat(ChatModel)
    case wallet(WalletEntity)
    case walletTransactions([WalletTransactionsModel])
    case uploadPhoto(String)
    case myProxy(Bool)
    case myProxies([ProxyCellModel])
    case proxyFor(ProxyForEntity)
    case proxyPosition
    case proxyRatingList(ProxyRatingEntity)
    
    case privateList([PrivateChatUser])
    case privateChat([ChatEntity])
    case withdrawTransactions(WithdrawChunk)
    case mute(Bool)
    
    case votesList(VotersList)
}
