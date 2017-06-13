//
//  ClaimCellBuilder.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 07.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Kingfisher
import UIKit

struct ClaimCellBuilder {
    static func populate(cell: UICollectionViewCell, with claim: EnhancedClaimEntity, delegate: ClaimVC) {
        if let cell = cell as? ImageGalleryCell {
            populateImageGallery(cell: cell, with: claim)
            addObserversToImageGallery(cell: cell, delegate: delegate)
        } else if let cell = cell as? ClaimVoteCell {
            populateClaimVote(cell: cell, with: claim)
            addObserversToClaimVote(cell: cell, delegate: delegate)
        } else if let cell = cell as? ClaimDetailsCell {
            populateClaimDetails(cell: cell, with: claim)
        } else if let cell = cell as? ClaimOptionsCell {
            populateClaimOptions(cell: cell, with: claim)
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
    
    static func populateImageGallery(cell: ImageGalleryCell, with claim: EnhancedClaimEntity) {
        let imageURLStrings = claim.largePhotos.flatMap { service.server.urlString(string: $0) }
        print(imageURLStrings)
        service.server.updateTimestamp { timestamp, error in
            let key = Key(base58String: ServerService.Constant.fakePrivateKey,
                          timestamp: timestamp)
            let modifier = AnyModifier { request in
                var request = request
                request.addValue("\(key.timestamp)", forHTTPHeaderField: "t")
                request.addValue(key.publicKey, forHTTPHeaderField: "key")
                request.addValue(key.signature, forHTTPHeaderField: "sig")
                return request
            }
            cell.setupGallery(with: imageURLStrings, options: [.requestModifier(modifier)])
        }
        cell.avatarView.kf.setImage(with: URL(string: service.server.avatarURLstring(for: claim.avatar)))
        cell.titleLabel.text = "Team.ClaimCell.claimID_format".localized(claim.id)//"Claim \(claim.id)"
        cell.textLabel.text = claim.originalPostText
        cell.unreadCountLabel.text = "\(claim.unreadCount)"
        cell.timeLabel.text = "Team.ClaimCell.timePassed_format".localized(claim.minutesinceLastPost).uppercased()
    }
    
    static func populateClaimVote(cell: ClaimVoteCell, with claim: EnhancedClaimEntity) {
        cell.titleLabel.text = "Team.ClaimCell.voting".localized
        cell.remainingDaysLabel.text = "Team.ClaimCell.remainingMinutes_format".localized(claim.minutesRemaining)
        cell.pieChart.startAngle = 0
        cell.pieChart.endAngle = 130
        
        cell.yourVoteLabel.text = "Team.ClaimCell.yourVote".localized.uppercased()
        let myVote = String(format: "%.2f", claim.myVote * 100)
        cell.yourVotePercentValue.text = myVote
        
        if let proxyAvatar = claim.proxyAvatar {
            cell.proxyAvatar.kf.setImage(with: URL(string: service.server.avatarURLstring(for: proxyAvatar)))
            cell.byProxyLabel.text = "Team.ClaimCell.byProxy".localized.uppercased()
        } else {
            cell.proxyAvatar.isHidden = true
            cell.byProxyLabel.isHidden = true
        }
        
        cell.teamVoteLabel.text = "Team.ClaimCell.teamVote".localized.uppercased()
        let teamVote = "?"
        cell.teamVotePercentValue.text = teamVote
        
        cell.submitButton.setTitle("Team.ClaimCell.voteSubmitted", for: .normal)
        cell.resetButton.setTitle("Team.ClaimCell.resetVote".localized, for: .normal)
        
        let avatars = claim.otherAvatars.flatMap { URL(string: service.server.avatarURLstring(for: $0)) }
        let label: String?  =  claim.otherCount > 0 ? "\(claim.otherCount)" : nil
        cell.avatarsStack.set(images: avatars, label: label, max: 3)
        
        cell.slider.minimumValue = 0
        cell.slider.maximumValue = 1
        cell.slider.setValue(Float(claim.myVote), animated: true)
    }
    
    static func populateClaimDetails(cell: ClaimDetailsCell, with claim: EnhancedClaimEntity) {
        cell.titleLabel.text = "Team.ClaimCell.claimDetails".localized
        
        cell.claimAmountLabel.text = "Team.ClaimCell.claimAmount".localized
        let currency = "$"
        let claimAmount = String(format: "%.2f", claim.claimAmount)
        cell.claimAmountValueLabel.text = currency + claimAmount
        
        cell.estimatedExpencesLabel.text = "Team.ClaimCell.estimatedExpences".localized
        let estimatedExpenses = String(format: "%.2f", claim.estimatedExpences)
        cell.estimatedExpensesValueLabel.text = currency + estimatedExpenses
        
        cell.deductibleLabel.text = "Team.ClaimCell.deductible".localized
        let deductible = String(format: "%.2f", claim.deductible)
        cell.deductibleValueLabel.text = currency + deductible
        
        cell.coverageLabel.text = "Team.ClaimCell.coverage".localized
        let coverage = "\(Int((claim.coverage * 100).rounded()))"
        cell.coverageValueLabel.text = coverage + "%"
        
        cell.incidentDateLabel.text = "Team.ClaimCell.incidentDate".localized
        claim.incidentDate.map { cell.incidentDateValueLabel.text = DateFormatter.teambrellaShort.string(from: $0) }
    }
    
    static func populateClaimOptions(cell: ClaimOptionsCell, with claim: EnhancedClaimEntity) {
        
    }
    
}
