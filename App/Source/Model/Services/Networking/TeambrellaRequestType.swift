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

enum TeambrellaRequestType: String {
    case timestamp = "me/GetTimestamp"
    case initClient = "me/InitClient"
    case updates = "me/GetUpdates"
    case teams = "me/getTeams"
    case demoTeams = "demo/getTeams"
    case registerKey = "me/registerKey"
    case coverageForDate = "me/getCoverageForDate"
    case setLanguageEn = "me/setUiLang/en"
    case setLanguageEs = "me/setUiLang/es"
    case teammatesList = "teammate/getList"
    case teammate = "teammate/getOne"
    case teammateVote = "teammate/setVote"
    case teammateChat = "teammate/getChat"
    case newPost = "post/newPost"
    case claimsList = "claim/getList"
    case claim = "claim/getOne"
    case claimVote = "claim/setVote"
    case claimChat = "claim/getChat"
    case newClaim = "claim/newClaim"
    case claimTransactions = "claim/getTransactionsList"
    case home = "feed/getHome"
    case feedDeleteCard = "feed/delCard"
    case teamFeed = "feed/getList"
    case feedChat = "feed/getChat"
    case newChat = "feed/newChat"
    case wallet = "wallet/getOne"
    case walletTransactions = "wallet/getMyTxList"
    case uploadPhoto = "post/newUpload"
    case myProxy = "proxy/setMyProxy"
    case myProxies = "proxy/getMyProxiesList"
    case proxyFor = "proxy/getIAmProxyForList"
    case proxyPosition = "proxy/setMyProxyPosition"
    case proxyRatingList = "proxy/getRatingList"
    
    case privateChat = "privatemessage/getChat"
    case privateList = "privatemessage/getList"
    case newPrivatePost = "privatemessage/newMessage"
    case feedPinVote = "feed/setPinVote"
    
    case withdrawTransactions = "wallet/getWithdraw"
    case withdraw = "wallet/newWithdraw"
    case mute = "feed/setIsMuted"
    
    case teammateVotesList = "teammate/getAllVotesList"
    case claimVotesList = "claim/getAllVotesList"
    case me = "me/getMe"
}
