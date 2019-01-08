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

enum TeambrellaGetRequestType: String {
    case cars = "carObject/getCars"
    case cities = "geoObject/getCities"
}

enum TeambrellaPostRequestType: String {
    case claimsList = "claim/getList"
    case claim = "claim/getOne"
    case claimVote = "claim/setVote"
    case claimChat = "claim/getChat"
    case newClaim = "claim/newClaim"
    case claimTransactions = "claim/getTransactionsList"
    case claimVotesList = "claim/getAllVotesList"

    case demoTeams = "demo/getTeams"

    case home = "feed/getHome"
    case feedDeleteCard = "feed/delCard"
    case teamFeed = "feed/getList"
    case feedChat = "feed/getChat"
    case mySettings = "feed/getMySettings"
    case pin = "feed/getPin"
    case newChat = "feed/newChat"
    case feedPinVote = "feed/setPinVote"
    case setMySettings = "feed/setMySettings"
    case mute = "feed/setIsMuted"
    case setPin = "feed/setPin"
    case setMyLike = "vote/setPostLike"

    case welcome = "join/getWelcome"
    case joinRregisterKey = "join/registerKey"

    case timestamp = "me/GetTimestamp"
    case initClient = "me/InitClient"
    case updates = "me/GetUpdates"
    case teams = "me/getTeams"
    case registerKey = "me/registerKey"
    case coverageForDate = "me/getCoverageForDate"
    case setLanguageEn = "me/setUiLang/en"
    case setLanguageEs = "me/setUiLang/es"
    case me = "me/getMe"
    case uploadAvatar = "me/setAvatar"

    case newPost = "post/newPost"
    case newPhotoPost = "post/newPhotoPost"
    case uploadPhoto = "post/newUpload"
    case deletePost = "post/delPost"

    case privateChat = "privatemessage/getChat"
    case privateList = "privatemessage/getList"
    case newPrivatePost = "privatemessage/newMessage"

    case myProxy = "proxy/setMyProxy"
    case myProxies = "proxy/getMyProxiesList"
    case proxyFor = "proxy/getIAmProxyForList"
    case proxyPosition = "proxy/setMyProxyPosition"
    case proxyRatingList = "proxy/getRatingList"
    
    case teammatesList = "teammate/getList"
    case teammate = "teammate/getOne"
    case teammateVote = "teammate/setVote"
    case teammateChat = "teammate/getChat"
    case teammateVotesList = "teammate/getAllVotesList"
    
    case wallet = "wallet/getOne"
    case walletTransactions = "wallet/getMyTxList"
    case withdrawTransactions = "wallet/getWithdraw"
    case withdraw = "wallet/newWithdraw"
}

extension TeambrellaPostRequestType {
    static func with(itemType: ItemType) -> TeambrellaPostRequestType {
        switch itemType {
        case .claim:
            return .claimChat
        case .teammate:
            return .teammateChat
        default:
            return .feedChat
        }
    }
}
