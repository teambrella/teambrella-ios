//
//  ClaimCellBuilder.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 07.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit
import Kingfisher

struct ClaimCellBuilder {
    static func populate(cell: UICollectionViewCell, with claim: EnhancedClaimEntity) {
        if let cell = cell as? ImageGalleryCell {
            let imageURLStrings = claim.largePhotos.flatMap { service.server.urlString(string: $0) }
            print(imageURLStrings)
            cell.setupGallery(with: imageURLStrings)
            cell.avatarView.kf.setImage(with: URL(string: service.server.avatarURLstring(for: claim.avatar)))
            cell.titleLabel.text = "Claim \(claim.topicID)"
            cell.textLabel.text = claim.originalPostText
            cell.unreadCountLabel.text = "\(claim.unreadCount)"
            cell.timeLabel.text = "\(claim.minutesinceLastPost) MIN AGO"
        } else if let cell = cell as? ClaimVoteCell {
            cell.titleLabel.text = "VOTING"
            cell.remainingDaysLabel.text = "\(claim.minutesRemaining) MIN"
            cell.pieChart.startAngle = 0
            cell.pieChart.endAngle = 130
            
            cell.yourVoteLabel.text = "YOUR VOTE"
            let myVote = String(format: "%.2f", claim.myVote * 100)
            cell.yourVotePercentValue.text = myVote
            
            if let proxyAvatar = claim.proxyAvatar {
                cell.proxyAvatar.kf.setImage(with: URL(string: service.server.avatarURLstring(for: proxyAvatar)))
                cell.byProxyLabel.text = "BY PROXY"
            } else {
                cell.proxyAvatar.isHidden = true
                cell.byProxyLabel.isHidden = true
            }
            
            cell.teamVoteLabel.text = "TEAM VOTE"
            let teamVote = "?"
            cell.teamVotePercentValue.text = teamVote
            
            cell.submitButton.setTitle("Vote Submitted", for: .normal)
            cell.resetButton.setTitle("Reset vote", for: .normal)
            
            let avatars = claim.otherAvatars.flatMap { URL(string: service.server.avatarURLstring(for: $0)) }
            let label: String?  =  claim.otherCount > 0 ? "\(claim.otherCount)" : nil
            cell.avatarsStack.set(images: avatars, label: label, max: 3)
            
        } else if let cell = cell as? ClaimDetailsCell {
            cell.titleLabel.text = "CLAIM DETAILS"
            
            cell.claimAmountLabel.text = "Claim Amount"
            let currency = "$"
            let claimAmount = String(format: "%.2f", claim.claimAmount)
            cell.claimAmountValueLabel.text = currency + claimAmount
            
            cell.estimatedExpencesLabel.text = "Estimated expenses"
            let estimatedExpenses = String(format: "%.2f", claim.estimatedExpences)
            cell.estimatedExpensesValueLabel.text = currency + estimatedExpenses
            
            cell.deductibleLabel.text = "Deductible"
            let deductible = String(format: "%.2f", claim.deductible)
            cell.deductibleValueLabel.text = currency + deductible
            
            cell.coverageLabel.text = "Coverage"
            let coverage = "\(Int(claim.coverage * 100))"
            cell.coverageValueLabel.text = coverage + "%"
            
            cell.incidentDateLabel.text = "Incident date"
            claim.incidentDate.map { cell.incidentDateValueLabel.text = String(describing: $0) }
        } else if let cell = cell as? ClaimOptionsCell {
            
        }
    }

}
