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
            populateVoting(cell: cell, with: teammate, controller: controller)
        case let cell as VotedRiskCell:
            populateVoted(cell: cell, with: teammate, controller: controller)
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
        cell.avatar.show(teammate.basic.avatar)
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
    
    // swiftlint:disable:next function_body_length
    private static func setVote(votingCell: VotingOrVotedRiskCell,
                                voting: TeammateLarge.VotingInfo,
                                controller: TeammateProfileVC) {
        var votingCell = votingCell
        let maxAvatarsStackCount = 4
        let otherVotersCount = voting.votersCount - maxAvatarsStackCount + 1
        let label: String? = otherVotersCount > 0 ? "+" + String(otherVotersCount) : nil
        votingCell.teammatesAvatarStack.setAvatars(images: voting.votersAvatars, label: label,
                                                   max: maxAvatarsStackCount)
        if let risk = voting.riskVoted {
            votingCell.teamVoteValueLabel.text = String(format: "%.2f", risk)
            votingCell.showTeamNoVote(risk: risk)
        } else {
            votingCell.teamVoteValueLabel.text = ". . ."
            votingCell.showTeamNoVote(risk: nil)
        }
        if let myVote = voting.myVote {
            setMyVote(votingCell: votingCell,
                      myVote: myVote,
                      proxyName: voting.proxyName,
                      proxyAvatar: voting.proxyAvatar,
                      canVote: voting.canVote)
        } else {
            if let cell = votingCell as? VotingRiskCell {
                cell.resetVoteButton.isHidden = true
                controller.resetVote(cell: cell)
            }
            votingCell.isProxyHidden = true
            votingCell.yourVoteValueLabel.alpha = 1
            votingCell.yourVoteValueLabel.text = ". . ."
            votingCell.showYourNoVote(risk: nil)
        }
        if let cell = votingCell as? VotingRiskCell {
            controller.updateAverages(cell: cell, risk: cell.currentRisk)
        } else if let cell = votingCell as? VotedRiskCell, let risk = voting.riskVoted {
            cell.setCurrentRisk(risk: risk)
            controller.updateAverages(cell: cell, risk: cell.currentRisk)
        }
        if voting.remainingMinutes > 0 {
            votingCell.timeLabel.text = DateProcessor().stringFinishesIn(minutesRemaining: voting.remainingMinutes)
            votingCell.pieChart.isHidden = false
            votingCell.pieChart.setupWith(remainingMinutes: voting.remainingMinutes)
        } else {
            votingCell.timeLabel.text = "Team.ClaimCell.voting.ended".localized.uppercased() +
                DateProcessor().stringAgo(passedMinutes: -voting.remainingMinutes).uppercased()
            votingCell.titleLabel.text = "Team.ClaimCell.voting".localized.uppercased()
            if let cell = votingCell as? VotedRiskCell {
                cell.pieChartLeadingConstraint.isActive = false
            }
            votingCell.pieChart.isHidden = true
        }
    }
    
    private static func setMyVote(votingCell: VotingOrVotedRiskCell,
                                  myVote: Double,
                                  proxyName: String?,
                                  proxyAvatar: Avatar?,
                                  canVote: Bool) {
        var votingCell = votingCell
        if proxyName != nil {
            votingCell.isProxyHidden = false
            if let cell = votingCell as? VotingRiskCell {
                cell.resetVoteButton.isHidden = true
                cell.layoutIfNeeded()
                cell.scrollTo(risk: myVote, silently: true, animated: false)
            }
            
            if let avatar = proxyAvatar {
                votingCell.proxyAvatarView.show(avatar)
            }
            votingCell.yourVoteValueLabel.alpha = 1
            votingCell.yourVoteValueLabel.text = String(format: "%.2f", myVote)
            votingCell.showYourNoVote(risk: myVote)
        } else {
            if let cell = votingCell as? VotingRiskCell {
                cell.layoutIfNeeded()
                cell.resetVoteButton.isHidden = false
                cell.scrollTo(risk: myVote, silently: true, animated: false)
            }
            votingCell.yourVoteValueLabel.alpha = 1
            votingCell.yourVoteValueLabel.text = String(format: "%.2f", myVote)
            votingCell.showYourNoVote(risk: myVote)
        }
        
        if let cell = votingCell as? VotingRiskCell {
            if proxyName != nil {
                cell.yourVoteHeaderLabel.text = "Team.VotingRiskVC.numberBar.right".localized
                cell.proxyNameLabel.text = "Team.ClaimCell.byProxy".localized.uppercased()
            } else {
                cell.yourVoteHeaderLabel.text = "Team.VotingRiskVC.numberBar.right".localized
                cell.isProxyHidden = true
            }
        } else if let cell = votingCell as? VotedRiskCell {
            if proxyName != nil {
                votingCell.yourVoteHeaderLabel.text = canVote ? "Team.VotingRiskVC.numberBar.right".localized
                : "Team.VotingRiskVC.numberBar.right.proxy".localized
                if let proxy = proxyName {
                    votingCell.proxyNameLabel.text = proxy.uppercased()
                } else {
                    cell.proxyNameLabel.text = "Team.ClaimCell.byProxy".localized.uppercased()
                }
            } else {
                cell.yourVoteHeaderLabel.text = "Team.VotingRiskVC.numberBar.right".localized
                cell.isProxyHidden = true
            }
        }
    }
    
    private static func populateVoted(cell: VotedRiskCell,
                                      with teammate: TeammateLarge,
                                      controller: TeammateProfileVC) {
        cell.delegate = controller
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        cell.pieChart.isHidden = teammate.voted == nil ? false : true
        
        if let voting = teammate.voting {
            setVote(votingCell: cell, voting: voting, controller: controller)
        } else if let voted = teammate.voted {
            setVote(votingCell: cell, voting: voted, controller: controller)
        }
    }
    
    private static func populateVoting(cell: VotingRiskCell,
                                       with teammate: TeammateLarge,
                                       controller: TeammateProfileVC) {
        cell.delegate = controller
        if let riskScale = teammate.riskScale, controller.isRiskScaleUpdateNeeded == true {
            cell.updateWithRiskScale(riskScale: riskScale)
            controller.isRiskScaleUpdateNeeded = false
        }
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        cell.middleAvatar.show(teammate.basic.avatar)
        
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
        let session = service.session
        
        let type: CoverageType = service.session?.currentTeam?.coverageType ?? .other
        let localizer = CoverageLocalizer(type: type)
        if let me = service.session?.currentUserID, me == teammate.basic.id {
            cell.titleLabel.text = localizer.myCoveredObject()
        } else {
            let owner = teammate.basic.gender == .male ?
                "General.posessiveFormat.his".localized(teammate.basic.name.first.uppercased()) :
                "General.posessiveFormat.her".localized(teammate.basic.name.first.uppercased())
            cell.titleLabel.text = "General.unitedFormat".localized(owner, localizer.coveredObject)
        }
        
        let yearString = CoverageLocalizer(type: type).yearsString(year: teammate.object.year)
        cell.nameLabel.text = "\(teammate.object.model), \(yearString)"
        
        cell.statusLabel.text = "Team.TeammateCell.covered".localized
        cell.detailsLabel.text = localizer.coverageType
        
        cell.numberBar.stackView.spacing = isSmallIPhone ? CGFloat(1) : CGFloat(2)
        if let left = cell.numberBar.left {
            left.titleLabel.text = "Team.TeammateCell.limit".localized
            left.amountLabel.text = ValueToTextConverter.textFor(amount: teammate.object.claimLimit)
            left.currencyLabel.font = UIFont.teambrellaBold(size: 10)
            left.currencyLabel.text = session?.currentTeam?.currency ?? ""
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
            middle.currencyLabel.font = UIFont.teambrellaBold(size: 10)
            middle.currencyLabel.text = session?.currentTeam?.currency ?? ""
            middle.isCurrencyVisible = true
            middle.isPercentVisible = false
            middle.isBadgeVisible = false
        }
        if let right = cell.numberBar.right {
            
            right.titleLabel.text = "Team.TeammateCell.risk".localized
            right.amountLabel.text = String(format: "%.1f", teammate.basic.risk)
            let avg = String.truncatedNumber(abs(teammate.basic.risk - teammate.basic.averageRisk) * 100)
            
            if teammate.basic.risk - teammate.basic.averageRisk == 0 {
                right.badgeLabel.text = "Team.VotingRiskVC.avg".localized
                right.badgeLabel.leftInset = CGFloat(4)
                right.badgeLabel.rightInset = CGFloat(4)
            } else {
                let sign = (teammate.basic.risk - teammate.basic.averageRisk) * 100 > 0 ? "+" : "-"
                right.badgeLabel.text = "Team.VotingRiskVC.avg".localized + " \(sign)\(avg)%"
            }
            right.isBadgeVisible = true
            right.currencyLabel.text = nil
            right.isCurrencyVisible = false
            right.isPercentVisible = false
            right.badgeLabel.rightInset = isSmallIPhone ? CGFloat(2) : CGFloat(4)
            right.badgeLabel.leftInset = isSmallIPhone ? CGFloat(2) : CGFloat(4)
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
        
        cell.addButton.removeTarget(nil, action: nil, for: .allEvents)
        cell.addButton.addTarget(controller, action: #selector(TeammateProfileVC.tapAddToProxy), for: .touchUpInside)
    }
    
    private static func populateDiscussion(cell: DiscussionCell, with stats: TopicEntity, avatar: Avatar) {
        cell.avatarView.kf.setImage(with: avatar.url)
        cell.titleLabel.text = "Team.TeammateCell.applicationDiscussion".localized
        let minutesSinceLastPost = stats.minutesSinceLastPost
        switch minutesSinceLastPost {
        case 0:
            cell.timeLabel.text = "Team.TeammateCell.timeLabel.justNow".localized
        case 1..<60:
            cell.timeLabel.text = "Team.Ago.minutes_format".localized(minutesSinceLastPost)
        case 60..<(60 * 24):
            cell.timeLabel.text = "Team.Ago.hours_format".localized(minutesSinceLastPost / 60)
        case 1440...10080: // 60 * 24...60 * 24 * 7
            cell.timeLabel.text = "Team.Ago.days_format".localized(minutesSinceLastPost / (60 * 24))
        default:
            let date = Date().addingTimeInterval(TimeInterval(-minutesSinceLastPost * 60))
            cell.timeLabel.text = DateProcessor().yearFilter(from: date)
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
                                                  avatar: Avatar) {
        cell.avatarView.show(avatar)
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
