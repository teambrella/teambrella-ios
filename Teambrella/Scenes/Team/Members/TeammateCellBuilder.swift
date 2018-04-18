//
//  TeammateCellBuilder.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 02.06.17.

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

import Kingfisher
import UIKit

struct TeammateCellBuilder {
    static func populate(cell: UICollectionViewCell,
                         with teammate: TeammateLarge,
                         controller: TeammateProfileVC) {
        switch cell {
        case let cell as TeammateObjectCell:
            populateObject(cell: cell, with: teammate, controller: controller)
        case let cell as TeammateContactCell:
            populateContact(cell: cell, with: teammate, controller: controller)
        case let cell as DiscussionCell:
            populateDiscussion(cell: cell, with: teammate.topic, avatar: teammate.basic.avatar)
        case let cell as TeammateStatsCell:
            populateStats(cell: cell, with: teammate, controller: controller)
        case let cell as VotingRiskCell:
            populateVote(cell: cell, with: teammate, controller: controller)
        case let cell as DiscussionCompactCell:
            populateCompactDiscussion(cell: cell, with: teammate.topic, avatar: teammate.basic.avatar)
        case let cell as MeCell:
            populateMeCell(cell: cell, with: teammate, controller: controller)
        default:
            break
        }
    }
    
    private static func populateMeCell(cell: MeCell,
                                       with teammate: TeammateLarge,
                                       controller: TeammateProfileVC?) {
        cell.avatar.showAvatar(string: teammate.basic.avatar)
        cell.nameLabel.text = teammate.basic.name.entire
        if let city = teammate.basic.city {
            cell.infoLabel.text = city.uppercased()
        } else {
            cell.infoLabel.text = ""
        }
    }
    
    private static func populateSummary(cell: TeammateSummaryCell,
                                        with teammate: TeammateLarge,
                                        controller: UIViewController) {
        /*
         cell.title.text = teammate.basic.name.entire
         //let url = URL(string: service.server.avatarURLstring(for: teammate.basic.avatar))
         cell.avatarView.present(avatarString: teammate.basic.avatar)
         cell.avatarView.onTap = { [weak controller] view in
         view.fullscreen(in: controller, imageStrings: nil)
         }
         //cell.avatarView.kf.setImage(with: url)
         if let left = cell.leftNumberView {
         left.titleLabel.text = "Team.TeammateCell.coversMe".localized
         let amount = teammate.basic.coversMeAmount
         left.amountLabel.text = ValueToTextConverter.textFor(amount: amount)
         left.currencyLabel.text = service.currencyName
         }
         if let right = cell.rightNumberView {
         right.titleLabel.text = "Team.TeammateCell.coverThem".localized
         let amount = teammate.basic.iCoverThemAmount
         right.amountLabel.text = ValueToTextConverter.textFor(amount: amount)
         right.currencyLabel.text = service.currencyName
         }
         
         cell.subtitle.text = teammate.basic.city.uppercased()
         if teammate.basic.isProxiedByMe, let myID = service.session?.currentUserID, teammate.basic.id != myID {
         cell.infoLabel.isHidden = false
         cell.infoLabel.text = "Team.TeammateCell.youAreProxy_format_s".localized(teammate.basic.name.entire)
         }
         */
    }
    
    private static func setVote(votingCell: VotingRiskCell,
                                voting: TeammateLarge.VotingInfo,
                                controller: TeammateProfileVC) {
        let maxAvatarsStackCount = 4
        let otherVotersCount = voting.votersCount - maxAvatarsStackCount + 1
        let label: String? = otherVotersCount > 0 ? "+" + String(otherVotersCount) : nil
        votingCell.teammatesAvatarStack.setAvatars(images: voting.votersAvatars, label: label,
                                                   max: maxAvatarsStackCount)
        if let risk = voting.riskVoted {
            votingCell.teamVoteValueLabel.text = String(format: "%.2f", risk)
            votingCell.showTeamNoVote(risk: risk)
        } else {
            votingCell.teamVoteValueLabel.text = "..."
            votingCell.showTeamNoVote(risk: nil)
        }
        if let myVote = voting.myVote {
            if voting.proxyName != nil {
                votingCell.isProxyHidden = false
                votingCell.resetVoteButton.isHidden = true
                votingCell.layoutIfNeeded()
                votingCell.yourVoteValueLabel.alpha = 1
                votingCell.yourVoteValueLabel.text = String(format: "%.2f", myVote)
                votingCell.scrollTo(risk: myVote, silently: true, animated: false)
                votingCell.showYourNoVote(risk: myVote)
                if let avatar = voting.proxyAvatar {
                    votingCell.proxyAvatarView.show(avatar)
                }
                votingCell.proxyNameLabel.text = voting.proxyName?.uppercased()
            } else {
                votingCell.layoutIfNeeded()
                votingCell.yourVoteValueLabel.alpha = 1
                votingCell.yourVoteValueLabel.text = String(format: "%.2f", myVote)
                votingCell.scrollTo(risk: myVote, silently: true, animated: false)
                votingCell.showYourNoVote(risk: myVote)
                votingCell.isProxyHidden = true
                votingCell.resetVoteButton.isHidden = false
            }
        } else {
            votingCell.resetVoteButton.isHidden = true
            controller.resetVote(cell: votingCell)
            votingCell.showYourNoVote(risk: nil)
        }
        controller.updateAverages(cell: votingCell, risk: votingCell.currentRisk)
        var prefix = ""
        if voting.remainingMinutes < 60 {
            prefix = "Team.Claim.minutes_format".localized(voting.remainingMinutes)
        } else if voting.remainingMinutes < 60 * 24 {
            prefix = "Team.Claim.hours_format".localized(voting.remainingMinutes / 60)
        } else {
            prefix = "Team.Claim.days_format".localized(voting.remainingMinutes / (60 * 24))
        }
        votingCell.timeLabel.text = prefix.uppercased() + " " +
            DateProcessor().stringFromNow(minutes: -voting.remainingMinutes).uppercased()
    }
    
    private static func populateVote(cell: VotingRiskCell,
                                     with teammate: TeammateLarge,
                                     controller: TeammateProfileVC) {
        cell.delegate = controller
        if let riskScale = teammate.riskScale, controller.isRiskScaleUpdateNeeded == true {
            cell.updateWithRiskScale(riskScale: riskScale)
            controller.isRiskScaleUpdateNeeded = false
        }
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        cell.middleAvatar.showAvatar(string: teammate.basic.avatar)
        
        if SimpleStorage().bool(forKey: .swipeHelperWasShown) {
            cell.swipeToVoteView.isHidden = true
        } else {
            cell.swipeToVoteView.isHidden = false
            cell.swipeToVoteView.onInteraction = {
                SimpleStorage().store(bool: true, forKey: .swipeHelperWasShown)
            }
        }
        
        if let voting = teammate.voting {
            setVote(votingCell: cell, voting: voting, controller: controller)
        }
    }
    
    // swiftlint:disable:next function_body_length
    private static func populateObject(cell: TeammateObjectCell,
                                       with teammate: TeammateLarge,
                                       controller: TeammateProfileVC) {
        let type: CoverageType = service.session?.currentTeam?.coverageType ?? .other
        let owner: String
        if let me = service.session?.currentUserID, me == teammate.basic.id {
            if type == CoverageType.petCat || type == CoverageType.petDog {
                owner = "General.posessiveFormat.my.female".localized
            } else {
                owner = "General.posessiveFormat.my.male".localized
            }
            cell.titleLabel.text = "General.unitedFormat.my".localized(owner, type.localizedCoverageObject)
        } else {
            owner = teammate.basic.gender == .male ?
                "General.posessiveFormat.his".localized(teammate.basic.name.first.uppercased()) :
                "General.posessiveFormat.her".localized(teammate.basic.name.first.uppercased())
            cell.titleLabel.text = "General.unitedFormat".localized(owner, type.localizedCoverageObject)
        }

        cell.nameLabel.text = "\(teammate.object.model), \(teammate.object.year.localizedString(for: type))"
        
        cell.statusLabel.text = "Team.TeammateCell.covered".localized
        cell.detailsLabel.text = teammate.teamPart?.coverageType.localizedCoverageType
        if let left = cell.numberBar.left {
            left.titleLabel.text = "Team.TeammateCell.limit".localized
            left.amountLabel.text = ValueToTextConverter.textFor(amount: teammate.object.claimLimit)
            left.currencyLabel.text = service.currencyName
            left.isCurrencyVisible = true
            left.isPercentVisible = false
            left.isBadgeVisible = false
        }
        if let middle = cell.numberBar.middle { // math abs!!!
            middle.titleLabel.text = "Team.Teammates.net".localized
            let test = teammate.basic.totallyPaidAmount > 0.0 ?
                Int(teammate.basic.totallyPaidAmount + 0.5) :
                Int(teammate.basic.totallyPaidAmount - 0.5)
            middle.amountLabel.text = String(test)
            middle.currencyLabel.text = service.currencyName
            middle.isCurrencyVisible = true
            middle.isPercentVisible = false
            middle.isBadgeVisible = false
        }
        if let right = cell.numberBar.right {
            right.titleLabel.text = "Team.TeammateCell.risk".localized
            right.amountLabel.text = String(format: "%.2f", teammate.basic.risk)
            let avg = String.truncatedNumber(teammate.basic.averageRisk)
            right.badgeLabel.text = avg + " AVG"
            right.isBadgeVisible = true
            right.currencyLabel.text = nil
            right.isCurrencyVisible = false
            right.isPercentVisible = false
        }
        
        if let imageString = teammate.object.largePhotos.first {
            cell.avatarView.present(imageString: imageString)
            cell.avatarView.onTap = { [weak controller] view in
                guard let vc = controller else { return }
                
                view.fullscreen(in: vc, imageStrings: teammate.object.largePhotos)
            }
            //cell.avatarView.showImage(string: imageString)
        }
        cell.button.setTitle("Team.TeammateCell.buttonTitle_format_i".localized(teammate.object.claimCount),
                             for: .normal)
        
        let hasClaims = teammate.object.claimCount > 0
        cell.button.isEnabled = hasClaims ? true : false
        
        cell.button.removeTarget(nil, action: nil, for: .allEvents)
        cell.button.addTarget(controller, action: #selector(TeammateProfileVC.showClaims), for: .touchUpInside)
    }
    
    private static func populateStats(cell: TeammateStatsCell,
                                      with teammate: TeammateLarge,
                                      controller: TeammateProfileVC) {
        let stats = teammate.stats
        cell.headerLabel.text = "Team.TeammateCell.votingStats".localized
        
        cell.weightTitleLabel.text = "Team.TeammateCell.weight".localized
        if stats.weight < 1.0 {
            cell.weightValueLabel.text = String(format: "%.2f", stats.weight)
        } else if stats.weight < 10.0 {
            cell.weightValueLabel.text = String(format: "%.1f", stats.weight)
        } else {
            cell.weightValueLabel.text = String(Int(stats.weight))
        }
        
        cell.proxyRankTitleLabel.text = "Team.TeammateCell.proxyRank".localized
        cell.proxyRankValueLabel.text = String(format: "%.1f", stats.proxyRank)
        /*
         if let left = cell.numberBar.left {
         left.amountLabel.textAlignment = .center
         left.titleLabel.text = "Team.TeammateCell.weight".localized
         left.amountLabel.text = ValueToTextConverter.textFor(amount: stats.weight)
         left.currencyLabel.text = nil
         }
         if let right = cell.numberBar.right {
         right.amountLabel.textAlignment = .center
         right.titleLabel.text = "Team.TeammateCell.proxyRank".localized
         right.amountLabel.text = ValueToTextConverter.textFor(amount: stats.proxyRank)
         right.isBadgeVisible = false
         right.currencyLabel.text = nil
         }
         */
        cell.decisionsLabel.text = "Team.TeammateCell.decisions".localized
        cell.decisionsBar.autoSet(value: stats.decisionFrequency)
        cell.decisionsBar.rightText = ValueToTextConverter.decisionsText(from: stats.decisionFrequency).uppercased()
        cell.discussionsLabel.text = "Team.TeammateCell.discussions".localized
        cell.discussionsBar.autoSet(value: stats.discussionFrequency)
        cell.discussionsBar.rightText = ValueToTextConverter
            .discussionsText(from: stats.discussionFrequency).uppercased()
        cell.frequencyLabel.text = "Team.TeammateCell.votingFrequency".localized
        cell.frequencyBar.autoSet(value: stats.votingFrequency)
        cell.frequencyBar.rightText = ValueToTextConverter.frequencyText(from: stats.votingFrequency).uppercased()
        
        let buttonTitle = teammate.basic.isMyProxy
            ? "Team.TeammateCell.removeFromMyProxyVoters".localized
            : "Team.TeammateCell.addToMyProxyVoters".localized
        cell.addButton.setTitle(buttonTitle, for: .normal)
        if let me = service.session?.currentUserID, me == teammate.basic.id {
            cell.addButton.isHidden = true
        } else {
            cell.addButton.isHidden = false
        }
        
        cell.addButton.removeTarget(controller, action: nil, for: .allEvents)
        cell.addButton.addTarget(self, action: #selector(TeammateProfileVC.tapAddToProxy), for: .touchUpInside)
    }
    
    private static func populateDiscussion(cell: DiscussionCell, with stats: TopicEntity, avatar: String) {
        cell.avatarView.kf.setImage(with: URL(string: URLBuilder().avatarURLstring(for: avatar)))
        cell.titleLabel.text = "Team.TeammateCell.applicationDiscussion".localized
        let minutesSinceLastPost = stats.minutesSinceLastPost
        switch minutesSinceLastPost {
        case 0:
            cell.timeLabel.text = "Team.TeammateCell.timeLabel.justNow".localized
        case 1..<60:
            cell.timeLabel.text = "Team.Ago.minutes_format".localized(minutesSinceLastPost)
        case 60..<(60 * 24):
            cell.timeLabel.text = "Team.Ago.hours_format".localized(minutesSinceLastPost / 60)
        case (60 * 24)...(60*24*7):
            cell.timeLabel.text = "Team.Ago.days_format".localized(minutesSinceLastPost / (60 * 24))
        default:
            let date = Date().addingTimeInterval(TimeInterval(-minutesSinceLastPost * 60))
            cell.timeLabel.text = DateProcessor().stringIntervalOrDate(from: date)
        }
        let message = stats.originalPostText.sane
        cell.textLabel.text = message
        cell.unreadCountView.text = String(stats.unreadCount)
        cell.unreadCountView.isHidden = stats.unreadCount == 0
        let urls = stats.topPosterAvatars.compactMap { URL(string: URLBuilder().avatarURLstring(for: $0)) }
        let morePersons = stats.posterCount - urls.count
        let text: String? = morePersons > 0 ? "+\(morePersons)" : nil
        cell.teammatesAvatarStack.set(images: urls, label: text, max: 4)
        if urls.isEmpty {
            cell.teammatesAvatarStack.isHidden = true
        }
    }
    
    private static func populateCompactDiscussion(cell: DiscussionCompactCell,
                                                  with stats: TopicEntity,
                                                  avatar: String) {
        cell.avatarView.showAvatar(string: avatar)
        cell.titleLabel.text = "Team.TeammateCell.applicationDiscussion".localized
        cell.timeLabel.text = DateProcessor().stringFromNow(seconds: stats.minutesSinceLastPost).uppercased()
        let message = stats.originalPostText.sane
        cell.textLabel.text = message
        cell.unreadCountView.text = String(stats.unreadCount)
        cell.unreadCountView.isHidden = stats.unreadCount == 0
    }
    
    private static func populateContact(cell: TeammateContactCell,
                                        with teammate: TeammateLarge,
                                        controller: TeammateProfileVC) {
        cell.headerLabel.text = "Team.TeammateCell.contact".localized
        cell.tableView.delegate = controller
        cell.tableView.dataSource = controller
        cell.tableView.reloadData()
    }
    
}
