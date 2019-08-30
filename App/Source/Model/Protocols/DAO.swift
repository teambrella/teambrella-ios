//
//  Storage.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 06.07.17.

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

typealias ErrorHandler = (Error?) -> Void

/// Data access object protocol
protocol DAO {
    var recentScene: SceneType { get set }
    
    func freshKey(completion: @escaping (Key) -> Void)
    func requestHome(teamID: Int) -> Future<HomeModel>
    func requestTeamFeed(context: FeedRequestContext, needTemporaryResult: Bool) -> Future<FeedChunk>
    // actual and potential teams
    func requestTeams(demo: Bool) -> Future<TeamsModel>
    func requestPrivateList(offset: Int, limit: Int, filter: String?) -> Future<[PrivateChatUser]>
    func requestCoverage(for date: Date, teamID: Int) -> Future<CoverageForDate>

    // MARK: Wallet

    func requestWallet(teamID: Int) -> Future<WalletEntity>
    func requestWalletTransactions(teamID: Int,
                                   offset: Int,
                                   limit: Int,
                                   search: String) -> Future<[WalletTransactionsModel]>

    // MARK: Proxy

    func requestProxyRating(teamID: Int,
                            offset: Int,
                            limit: Int,
                            searchString: String?,
                            sortBy: SortVC.SortType) -> Future<ProxyRatingEntity>
    func requestMyProxiesList(teamID: Int, offset: Int, limit: Int) -> Future<[ProxyCellModel]>
    func updateProxyPosition(teamID: Int, userID: String, newPosition: Int) -> Future<Bool>
    func requestProxyFor(teamID: Int, offset: Int, limit: Int) -> Future<ProxyForEntity>
    func requestWithdrawTransactions(teamID: Int) -> Future<WithdrawChunk>
    func withdraw(teamID: Int, amount: Double, address: EthereumAddress) -> Future<WithdrawChunk>
    func requestTeammateOthersVoted(teamID: Int, teammateID: Int) -> Future<VotersList>
    func requestRisksVotesList(teamID: Int, offset: Int, limit: Int, teammateID: Int) -> Future<RiskVotesList>

    // MARK: Claims

    func requestClaimOthersVoted(teamID: Int, claimID: Int) -> Future<VotersList>
    func requestClaimsList(teamID: Int, offset: Int, limit: Int, filterTeammateID: Int?) -> Future<[ClaimEntity]>
    func requestClaimsVotesList(teamID: Int, offset: Int, limit: Int, votesOfTeammateID: Int) -> Future<[ClaimEntity]>
    func requestClaim(claimID: Int) -> Future<ClaimEntityLarge>
    func requestClaimTransactions(teamID: Int,
                                  claimID: Int,
                                  limit: Int,
                                  offset: Int) -> Future<[ClaimTransactionsModel]>

    // MARK: Teammates

    func requestTeammatesList(teamID: Int,
                              offset: Int,
                              limit: Int,
                              isOrderedByRisk: Bool) -> Future<(TeammatesList, PagingInfo?)>
    func requestTeammate(userID: String, teamID: Int) -> Future<TeammateLarge>

    func requestChat(type: TeambrellaPostRequestType, body: [String: Any]) -> Future<ChatModel>
    func sendPrivateChatMessage(type: TeambrellaPostRequestType, body: [String: Any]) -> Future<ChatModel>
    func sendChatMessage(type: TeambrellaPostRequestType, body: [String: Any]) -> Future<ChatEntity>
    /// this method guarantees that the photo was made via our app (if isCertified is true)
    func sendPhotoPost(topicID: String, postID: String, isCertified: Bool, data: Data) -> Future<ChatEntity>
    func deletePost(id: String) -> Future<String>

    // MARK: Send data

    func deleteCard(topicID: String) -> Future<HomeModel>
    func setLanguage() -> Future<String>
    func sendPhoto(data: Data, isCertified: Bool) -> Future<[String]>
    func sendAvatar(data: Data) -> Future<String>

    func createNewClaim(model: NewClaimModel) -> Future<ClaimEntityLarge>
    func createNewChat(model: NewChatModel) -> Future<ChatModel>

    func myProxy(userID: String, add: Bool) -> Future<Bool>
    func mute(topicID: String, isMuted: Bool) -> Future<Bool>

    func sendRiskVote(teammateID: Int, risk: Double?) -> Future<TeammateVotingResult>
    
    func registerKey(facebookToken: String, signature: String, wallet: String) -> Future<Bool>
    func registerKey(socialToken: String, signature: String, wallet: String) -> Future<Bool>
    func registerKey(signature: String, userData: UserApplicationData) -> Future<Bool>

    func updateClaimVote(claimID: Int, vote: Float?, lastUpdated: Int64) -> Future<ClaimVoteUpdate>
    
    func requestSettings(current: TeamNotificationsType, teamID: Int) -> Future<SettingsEntity>
    func sendSettings(current: TeamNotificationsType, teamID: Int) -> Future<SettingsEntity>
    
    func requestPin(topicID: String) -> Future<PinEntity>
    func sendPin(topicID: String, pinType: PinType) -> Future<PinEntity>

    func setPostLike(postID: String, myLike: Int) -> Future<Bool>
    func setPostMarked(postID: String, isMarked: Bool) -> Future<Bool>
    func setViewMode(topicID: String, useMarksMode: Bool) -> Future<Bool> 

//    func performRequest(request: TeambrellaRequest)
    
    func getCars(string: String?) -> Future<[String]>
    func getCities(string: String?) -> Future<[String]>
    func getWelcome(teamID: Int?, inviteCode: String?) -> Future<WelcomeEntity>
}
