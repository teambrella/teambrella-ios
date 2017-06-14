//
//  TeammateCellBuilder.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 02.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Kingfisher
import UIKit

struct TeammateCellBuilder {
    static func populate(cell: UICollectionViewCell, with teammate: TeammateLike, delegate: Any? = nil) {
        if let cell = cell as? TeammateSummaryCell {
            populateSummary(cell: cell, with: teammate)
        } else if let cell = cell as? TeammateObjectCell {
          populateObject(cell: cell, with: teammate)
        } else if let cell = cell as? TeammateContactCell {
            populateContact(cell: cell, with: teammate, delegate: delegate)
        } else if let cell = cell as? DiscussionCell, let topic = teammate.extended?.topic {
            populateDiscussion(cell: cell, with: topic, avatar: teammate.avatar)
        } else if let cell = cell as? TeammateStatsCell, let stats = teammate.extended?.stats {
            populateStats(cell: cell, with: stats)
        }
    }
    
    private static func populateSummary(cell: TeammateSummaryCell, with teammate: TeammateLike) {
        cell.title.text = teammate.name
        let url = URL(string: service.server.avatarURLstring(for: teammate.avatar))
        cell.avatarView.kf.setImage(with: url)
        if let left = cell.leftNumberView {
            left.titleLabel.text = "Team.TeammateCell.coversMe".localized
            let amount = teammate.extended?.basic.coversMeAmount
            left.amountLabel.text = textFor(amount: amount)
        }
        if let right = cell.rightNumberView {
            right.titleLabel.text = "Team.TeammateCell.coverThem".localized
            let amount = teammate.extended?.basic.iCoverThemAmount
            right.amountLabel.text = textFor(amount: amount)
        }
        guard let extended = teammate.extended else { return }
        
        cell.subtitle.text = extended.basic.city
        if extended.basic.isProxiedByMe {
            cell.infoLabel.isHidden = false
            cell.infoLabel.text = "Team.TeammateCell.youAreProxy_format_s".localized(extended.basic.name)
        }
    }
    
    private static func populateObject(cell: TeammateObjectCell, with teammate: TeammateLike) {
        cell.nameLabel.text = "\(teammate.model), \(teammate.year)"
        
        cell.statusLabel.text = "Team.TeammateCell.covered".localized
        cell.detailsLabel.text = "Team.TeammateCell.collisionDeductible".localized
        if let left = cell.numberBar.left {
            left.titleLabel.text = "Team.TeammateCell.limit".localized
            left.amountLabel.text = textFor(amount: teammate.extended?.object.claimLimit)
        }
        if let middle = cell.numberBar.middle {
            middle.titleLabel.text = "Team.Teammates.net".localized
            middle.amountLabel.text = textFor(amount: teammate.extended?.basic.totallyPaidAmount)
        }
        if let right = cell.numberBar.right {
            right.titleLabel.text = "Team.TeammateCell.riskFactor"
            right.amountLabel.text = textFor(amount: teammate.risk)
            right.badgeLabel.text = "1x47xAVG"
            right.isBadgeVisible = true
            right.currencyLabel.text = nil
        }
        guard let object = teammate.extended?.object else { return }
        
        if let imageString = object.smallPhotos.first {
            cell.avatarView.kf.setImage(with: URL(string: service.server.avatarURLstring(for: imageString)))
        }
        cell.button.setTitle("Team.TeammateCell.buttonTitle_format_i".localized(object.claimCount) , for: .normal)
    }
    
    private static func populateStats(cell: TeammateStatsCell, with stats: TeammateStats) {
        cell.headerLabel.text = "Team.TeammateCell.votingStats".localized
        if let left = cell.numberBar.left {
            left.titleLabel.text = "Team.TeammateCell.weight".localized
            left.amountLabel.text = textFor(amount: stats.weight)
        }
        if let right = cell.numberBar.right {
            right.titleLabel.text = "Team.TeammateCell.proxyRank".localized
            right.amountLabel.text = textFor(amount: stats.proxyRank)
            right.isBadgeVisible = false
        }
        cell.decisionsLabel.text = "Team.TeammateCell.decisions".localized
        cell.decisionsBar.autoSet(value: stats.decisionFrequency)
        cell.decisionsBar.rightText = decisionsText(from: stats.decisionFrequency).uppercased()
        cell.discussionsLabel.text = "Team.TeammateCell.discussions".localized
        cell.discussionsBar.autoSet(value: stats.discussionFrequency)
        cell.discussionsBar.rightText = discussionsText(from: stats.discussionFrequency).uppercased()
        cell.frequencyLabel.text = "Team.TeammateCell.votingFrequency".localized
        cell.frequencyBar.autoSet(value: stats.votingFrequency)
        cell.frequencyBar.rightText = frequencyText(from: stats.votingFrequency).uppercased()
    }
    
    private static func populateDiscussion(cell: DiscussionCell, with stats: Topic, avatar: String) {
        cell.avatarView.kf.setImage(with: URL(string: service.server.avatarURLstring(for: avatar)))
        cell.titleLabel.text = "Team.TeammateCell.applicationDiscussion".localized
        switch stats.minutesSinceLastPost {
        case 0:
            cell.timeLabel.text = "Team.TeammateCell.timeLabel.justNow".localized
        case 1..<60:
            cell.timeLabel.text = "Team.TeammateCell.timeLabel.minutes_format_i".localized(stats.minutesSinceLastPost)
        case 60...(60 * 24):
            let hours = stats.minutesSinceLastPost / 60
            cell.timeLabel.text = "Team.TeammateCell.timeLabel.hours_format_i".localized(hours)
        default:
            cell.timeLabel.text = "Team.TeammateCell.timeLabel.longAgo".localized
        }
        let message = TextAdapter().parsedHTML(string: stats.originalPostText)
        cell.textLabel.text = message
        cell.unreadCountView.text = String(stats.unreadCount)
        cell.unreadCountView.isHidden = stats.unreadCount == 0
        let urls = stats.topPosterAvatars.flatMap { URL(string: service.server.avatarURLstring(for: $0)) }
        let morePersons = stats.posterCount - urls.count
        let text: String? = morePersons > 0 ? "+\(morePersons)" : nil
        cell.teammatesAvatarStack.set(images: urls, label: text, max: 4)
    }
    
    private static func populateContact(cell: TeammateContactCell, with teammate: TeammateLike, delegate: Any?) {
        guard let dataSource = delegate as? UITableViewDataSource else {
            fatalError("TeammateContactCell should have table view data source")
        }
        
        cell.headerLabel.text = "Team.TeammateCell.contact".localized
        let delegate = delegate as? UITableViewDelegate
        cell.tableView.delegate = delegate
        cell.tableView.dataSource = dataSource
        cell.tableView.reloadData()
    }
    
    private static func decisionsText(from value: Double) -> String {
        let value = Int(value * 100)
        switch value {
        case 0..<30: return "Team.Decisions.generous".localized
        case 30..<45: return "Team.Decisions.mild".localized
        case 45..<55: return "Team.Decisions.moderate".localized
        case 55..<70: return "Team.Decisions.severe".localized
        case 70...100: return "Team.Decisions.harsh".localized
        default: return "Team.unknown".localized
        }
    }
    
    private static func discussionsText(from value: Double) -> String {
        let value = Int(value * 100)
        switch value {
        case 0..<3: return "Team.Discussions.quiet".localized
        case 3..<10: return "Team.Discussions.reserved".localized
        case 10..<25: return "Team.Discussions.moderate".localized
        case 25..<50: return "Team.Discussions.sociable".localized
        case 50...100: return "Team.Discussions.chatty".localized
        default: return "Team.unknown".localized
        }
    }
    
    private static func frequencyText(from value: Double) -> String {
        let value = Int(value * 100)
        switch value {
        case 0: return "Team.Frequency.never".localized
        case 1..<5: return "Team.Frequency.rarely".localized
        case 5..<15: return "Team.Frequency.occasionally".localized
        case 15..<30: return "Team.Frequency.frequently".localized
        case 30..<60: return "Team.Frequency.often".localized
        case 60..<95: return "Team.Frequency.regularly".localized
        case 95...100: return "Team.Frequency.always".localized
        default: return "Team.unknown".localized
        }
    }
    
    private static func textFor(amount: Double?) -> String {
        guard let amount = amount else { return "?" }
        guard amount.truncatingRemainder(dividingBy: 1) > 0.01 else { return "\(Int(amount))" }
        
        return String(format: "%.2f", amount)
    }
    
}
