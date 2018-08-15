//
//  ClaimCellBuilder.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 07.06.17.

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

struct ClaimCellBuilder {
    static func populate(cell: UICollectionViewCell, with claim: ClaimEntityLarge, delegate: ClaimVC) {
        if let cell = cell as? ImageGalleryCell {
            populateImageGallery(cell: cell, with: claim)
            addObserversToImageGallery(cell: cell, delegate: delegate)
        } else if let cell = cell as? ClaimVoteCell {
            populateClaimVote(cell: cell, with: claim, delegate: delegate)
            addObserversToClaimVote(cell: cell, delegate: delegate)
        } else if let cell = cell as? ClaimDetailsCell {
            populateClaimDetails(cell: cell, with: claim)
        } else if let cell = cell as? ClaimOptionsCell {
            populateClaimOptions(cell: cell, with: claim, delegate: delegate)
        }
    }
    
    static func addObserversToImageGallery(cell: ImageGalleryCell, delegate: ClaimVC) {
        if cell.tapGalleryGesture == nil {
            let gestureRecognizer = UITapGestureRecognizer(target: delegate, action: #selector(ClaimVC.tapGallery))
            cell.tapGalleryGesture = gestureRecognizer
            cell.slideshow.addGestureRecognizer(gestureRecognizer)
        }
    }
    
    static func addObserversToClaimVote(cell: ClaimVoteCell, delegate: ClaimVC) {
        cell.slider.removeTarget(delegate, action: nil, for: .valueChanged)
        cell.slider.addTarget(delegate, action: #selector(ClaimVC.sliderMoved), for: .valueChanged)
    }
    
    static func populateImageGallery(cell: ImageGalleryCell, with claim: ClaimEntityLarge) {
        cell.accessibilityIdentifier = "imageGalleryCell"
        let imageURLStrings = claim.basic.largePhotos.map { URLBuilder().urlString(string: $0) }
        log("\(imageURLStrings)", type: .info)
        service.dao.freshKey { key in
            let modifier = AnyModifier { request in
                var request = request
                request.addValue("\(key.timestamp)", forHTTPHeaderField: "t")
                request.addValue(key.publicKey, forHTTPHeaderField: "key")
                request.addValue(key.signature, forHTTPHeaderField: "sig")
                return request
            }
            cell.setupGallery(with: imageURLStrings, options: [.requestModifier(modifier)])
        }
        cell.avatarView.kf.setImage(with: URL(string: URLBuilder().avatarURLstring(for: claim.basic.avatar)))
        cell.titleLabel.text = "Team.ClaimCell.claimID_format".localized(claim.id)
        cell.textLabel.text = claim.discussion.originalPostText.sane
        cell.unreadCountLabel.text = "\(claim.discussion.unreadCount)"
        cell.unreadCountLabel.isHidden = claim.discussion.unreadCount <= 0
        
        let urls = claim.discussion.topPosterAvatars.compactMap { URL(string: URLBuilder().avatarURLstring(for: $0)) }
        let morePersons = claim.discussion.posterCount - urls.count
        let text: String? = morePersons > 0 ? "+\(morePersons)" : nil
        cell.imagesStack.set(images: urls, label: text, max: 4)
        if urls.isEmpty {
            cell.imagesStack.isHidden = true
        }
        let minutesSinceLastPost = claim.discussion.minutesSinceLastPost
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
            cell.timeLabel.text = DateProcessor().yearFilter(from: date)
        }
        ViewDecorator.shadow(for: cell, opacity: 0.1, radius: 8)
    }
    
    // swiftlint:disable:next function_body_length
    static func populateClaimVote(cell: ClaimVoteCell, with claim: ClaimEntityLarge, delegate: ClaimVC) {
        let session = service.session

        guard let voting = claim.voting else {
            log("ClaimEntityLarge has no voting part. Can't populate ClaimVoteCell", type: .error)
            return
        }
        
        cell.titleLabel.text = "Team.ClaimCell.voting".localized.uppercased()
        var prefix = ""
        if voting.minutesRemaining < 60 {
            prefix = "Team.Claim.minutes_format".localized(voting.minutesRemaining)
        } else if voting.minutesRemaining < 60 * 24 {
            prefix = "Team.Claim.hours_format".localized(voting.minutesRemaining / 60)
        } else {
            prefix = "Team.Claim.days_format".localized(voting.minutesRemaining / (60 * 24))
        }
        cell.remainingDaysLabel.text = prefix.uppercased() + " " +
            DateProcessor().stringFromNow(minutes: -voting.minutesRemaining).uppercased()
        
        cell.pieChart.setupWith(remainingMinutes: voting.minutesRemaining)
        
        if let myVote = voting.myVote {
            cell.yourVotePercentValue.text = String.truncatedNumber(myVote.percentage)
            cell.yourVoteAmount.text = String.truncatedNumber(myVote.fiat(from: claim.basic.claimAmount).value)
            if voting.canVote {
                cell.slider.setValue(Float(myVote.value), animated: true)
            } else {
                cell.slider.isHidden = true
            }
            if let proxyName = voting.proxyName {
                cell.resetButton.isHidden = true
                if let proxyAvatar = voting.proxyAvatar {
                    cell.proxyAvatar.show(proxyAvatar)
                    cell.byProxyLabel.text = voting.canVote ? "Team.ClaimCell.byProxy".localized.uppercased()
                                                            : proxyName.entire.uppercased()
                }
            } else {
                cell.resetButton.isHidden = false
            }
        } else {
            cell.yourVotePercentValue.text = ". . ."
            cell.isYourVoteHidden = true
            if let teamVote = voting.ratioVoted {
                cell.slider.setValue(Float(teamVote.value), animated: true)
            } else {
                cell.slider.setValue(cell.slider.minimumValue, animated: true)
            }
            cell.resetButton.isHidden = true
            if voting.canVote == false {
                cell.slider.isHidden = true
            }
        }
        
        if voting.myVote != nil {
            if voting.proxyName != nil {
                cell.yourVoteLabel.text = voting.canVote ? "Team.ClaimCell.yourVote".localized.uppercased()
                    : "Team.ClaimCell.proxyVote".localized.uppercased()
            }
        } else {
            cell.yourVoteLabel.text = "Team.ClaimCell.yourVote".localized.uppercased()
        }
        
        cell.proxyAvatar.isHidden = voting.proxyAvatar == nil || voting.myVote == nil
        cell.byProxyLabel.isHidden = voting.proxyName == nil || voting.myVote == nil
        
        cell.yourVotePercentValue.alpha = 1
        cell.yourVoteAmount.alpha = 1
        cell.yourVoteCurrency.text = session?.currentTeam?.currency ?? ""
        
        cell.teamVoteLabel.text = "Team.ClaimCell.teamVote".localized.uppercased()
        if let teamVote = voting.ratioVoted {
            cell.teamVotePercentValue.text = String.truncatedNumber(teamVote.percentage)
            cell.teamVoteAmount.text = String.truncatedNumber(teamVote.fiat(from: claim.basic.claimAmount).value)
            cell.teamVoteCurrency.text = session?.currentTeam?.currency
        } else {
            cell.teamVotePercentValue.text = ". . ."
            cell.isTeamVoteHidden = true
        }
        
        cell.resetButton.setTitle("Team.ClaimCell.resetVote".localized, for: .normal)
        cell.resetButton.removeTarget(delegate, action: nil, for: .allEvents)
        cell.resetButton.addTarget(delegate, action: #selector(ClaimVC.tapResetVote), for: .touchUpInside)
        
        let avatars = voting.otherAvatars.compactMap { $0.url }
        let maxAvatarsStackCount = 4
        let otherVotersCount = voting.otherCount - maxAvatarsStackCount + 1
        let label: String?  =  otherVotersCount > 0 ? "+\(otherVotersCount)" : nil
        cell.avatarsStack.set(images: avatars, label: label, max: maxAvatarsStackCount)
        
        cell.othersVotedButton.removeTarget(delegate, action: nil, for: .allEvents)
        cell.othersVotedButton.addTarget(delegate, action: #selector(ClaimVC.tapOthersVoted), for: .touchUpInside)
        ViewDecorator.shadow(for: cell, opacity: 0.1, radius: 8)
    }
    
    static func populateClaimDetails(cell: ClaimDetailsCell, with claim: ClaimEntityLarge) {
        let session = service.session
        
        cell.titleLabel.text = "Team.ClaimCell.claimDetails".localized
        
        cell.coverageLabel.text = "Team.ClaimCell.coverage".localized
        let coverage = "\(Int((claim.basic.coverage * 100).rounded()))"
        cell.coverageValueLabel.text = coverage + "%"
        
        cell.incidentDateLabel.text = "Team.ClaimCell.incidentDate".localized
        cell.incidentDateValueLabel.text = DateFormatter.teambrellaShort.string(from: claim.basic.incidentDate)
        ViewDecorator.shadow(for: cell, opacity: 0.1, radius: 8)
        
        cell.claimAmountLabel.text = "Team.ClaimCell.claimAmount".localized
        let claimAmount = String(format: "%.2f", claim.basic.claimAmount.value)
        cell.deductibleLabel.text = "Team.ClaimCell.deductible".localized
        let deductible = String(format: "%.2f", claim.basic.deductible)
        cell.estimatedExpencesLabel.text = "Team.ClaimCell.estimatedExpences".localized
        let estimatedExpenses = String(format: "%.2f", claim.basic.estimatedExpenses)
        let currency = session?.currentTeam?.currencySymbol ?? ""
        cell.claimAmountValueLabel.text = currency + claimAmount
        cell.deductibleValueLabel.text = currency + deductible
        cell.estimatedExpensesValueLabel.text = currency + estimatedExpenses
        
    }
    
    static func populateClaimOptions(cell: ClaimOptionsCell, with claim: ClaimEntityLarge, delegate: ClaimVC) {
        cell.allVotesLabel.text = "Team.TeammateCell.allVotes".localized
        cell.tapAllVotesRecognizer.removeTarget(delegate, action: nil)
        cell.tapAllVotesRecognizer.addTarget(delegate, action: #selector(ClaimVC.tapOthersVoted))
//        cell.cashFlowLabel.text = "Team.TeammateCell.cashFlow".localized
        cell.transactionsLabel.text = "Team.TeammateCell.transactions".localized
        cell.tapTransactionsRecognizer.removeTarget(delegate, action: nil)
        cell.tapTransactionsRecognizer.addTarget(delegate, action: #selector(ClaimVC.tapTransactions))
        ViewDecorator.shadow(for: cell, opacity: 0.1, radius: 8)
    }
    
}
