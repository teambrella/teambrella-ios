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
        let imageURLStrings = claim.basic.largePhotos.map { URLBuilder().urlString(string: $0) }
        log("\(imageURLStrings)", type: .info)
        service.server.updateTimestamp { timestamp, error in
            let key =  Key(base58String: KeyStorage.shared.privateKey, timestamp: timestamp)
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
            cell.timeLabel.text = DateProcessor().stringIntervalOrDate(from: date)
        }
        ViewDecorator.shadow(for: cell, opacity: 0.1, radius: 8)
    }

    // swiftlint:disable:next function_body_length
    static func populateClaimVote(cell: ClaimVoteCell, with claim: ClaimEntityLarge, delegate: ClaimVC) {
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
            cell.slider.setValue(Float(myVote.value), animated: true)
        } else if let proxyVote = voting.proxyVote {
            cell.yourVotePercentValue.text = String.truncatedNumber(proxyVote.percentage)
            cell.yourVoteAmount.text = String.truncatedNumber(proxyVote.fiat(from: claim.basic.claimAmount).value)
            cell.slider.setValue(Float(proxyVote.value), animated: true)
            if let proxyAvatar = voting.proxyAvatar {
                cell.proxyAvatar.show(proxyAvatar)
                cell.byProxyLabel.text = "Team.ClaimCell.byProxy".localized.uppercased()
            }
        } else {
            cell.yourVotePercentValue.text = ". . ."
            cell.isYourVoteHidden = true
            cell.slider.setValue(cell.slider.minimumValue, animated: true)
        }
        cell.resetButton.isHidden = voting.myVote == nil
        cell.proxyAvatar.isHidden = voting.proxyAvatar == nil || voting.myVote != nil
        cell.byProxyLabel.isHidden = voting.proxyVote == nil || voting.myVote != nil
        
        cell.yourVoteLabel.text = "Team.ClaimCell.yourVote".localized.uppercased()
        cell.yourVotePercentValue.alpha = 1
        cell.yourVoteAmount.alpha = 1
        cell.yourVoteCurrency.text = service.currencyName 
        
        cell.teamVoteLabel.text = "Team.ClaimCell.teamVote".localized.uppercased()
        cell.teamVotePercentValue.text = String.truncatedNumber(voting.ratioVoted.percentage)
        cell.teamVoteAmount.text = String.truncatedNumber(voting.ratioVoted.fiat(from: claim.basic.claimAmount).value)
        cell.teamVoteCurrency.text = service.currencyName
        
        cell.resetButton.setTitle("Team.ClaimCell.resetVote".localized, for: .normal)
        cell.resetButton.removeTarget(delegate, action: nil, for: .allEvents)
        cell.resetButton.addTarget(delegate, action: #selector(ClaimVC.tapResetVote), for: .touchUpInside)
        
        let avatars = voting.otherAvatars.flatMap { $0.url }
        let maxAvatarsStackCount = 4
        let otherVotersCount = voting.otherCount - maxAvatarsStackCount + 1
        let label: String?  =  otherVotersCount > 0 ? "+\(otherVotersCount)" : nil
        cell.avatarsStack.set(images: avatars, label: label, max: maxAvatarsStackCount)
        
        cell.othersVotedButton.removeTarget(delegate, action: nil, for: .allEvents)
        cell.othersVotedButton.addTarget(delegate, action: #selector(ClaimVC.tapOthersVoted), for: .touchUpInside)
        ViewDecorator.shadow(for: cell, opacity: 0.1, radius: 8)
    }
    
    static func populateClaimDetails(cell: ClaimDetailsCell, with claim: ClaimEntityLarge) {
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
        let currency = service.currencySymbol
        cell.claimAmountValueLabel.text = currency + claimAmount
        cell.deductibleValueLabel.text = currency + deductible
        cell.estimatedExpensesValueLabel.text = currency + estimatedExpenses
        
    }
    
    static func populateClaimOptions(cell: ClaimOptionsCell, with claim: ClaimEntityLarge, delegate: ClaimVC) {
        cell.allVotesLabel.text = "Team.TeammateCell.allVotes".localized
        cell.tapAllVotesRecognizer.removeTarget(delegate, action: nil)
        cell.tapAllVotesRecognizer.addTarget(delegate, action: #selector(ClaimVC.tapOthersVoted))
        cell.cashFlowLabel.text = "Team.TeammateCell.cashFlow".localized
        cell.transactionsLabel.text = "Team.TeammateCell.transactions".localized
        cell.tapTransactionsRecognizer.removeTarget(delegate, action: nil)
        cell.tapTransactionsRecognizer.addTarget(delegate, action: #selector(ClaimVC.tapTransactions))
        ViewDecorator.shadow(for: cell, opacity: 0.1, radius: 8)
    }
    
}
