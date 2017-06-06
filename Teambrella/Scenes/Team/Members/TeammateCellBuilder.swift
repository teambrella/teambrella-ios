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
    static func populate(cell: UICollectionViewCell, with teammate: TeammateLike, delegate: Any? = nil) -> Any? {
        if let cell = cell as? TeammateSummaryCell {
            populateSummary(cell: cell, with: teammate)
        } else if let cell = cell as? TeammateObjectCell {
            return populateObject(cell: cell, with: teammate)
        } else if let cell = cell as? TeammateContactCell {
            populateContact(cell: cell, with: teammate, delegate: delegate)
        } else if let cell = cell as? DiscussionCell, let topic = teammate.extended?.topic {
            populateDiscussion(cell: cell, with: topic, avatar: teammate.avatar)
        } else if let cell = cell as? TeammateStatsCell, let stats = teammate.extended?.stats {
            populateStats(cell: cell, with: stats)
        }
        return nil
    }
    
    private static func populateSummary(cell: TeammateSummaryCell, with teammate: TeammateLike) {
        cell.title.text = teammate.name
        let url = URL(string: service.server.avatarURLstring(for: teammate.avatar))
        cell.avatarView.kf.setImage(with: url)
        if let left = cell.leftNumberView {
            left.titleLabel.text = "COVERS ME"
            let amount = teammate.extended?.basic.coversMeAmount
            left.amountLabel.text = textFor(amount: amount)
        }
        if let right = cell.rightNumberView {
            right.titleLabel.text = "COVER THEM"
            let amount = teammate.extended?.basic.iCoverThemAmount
            right.amountLabel.text = textFor(amount: amount)
        }
        guard let extended = teammate.extended else { return }
        
        cell.subtitle.text = extended.basic.city
        if extended.basic.isProxiedByMe {
            cell.infoLabel.isHidden = false
            cell.infoLabel.text = "You are proxy for \(extended.basic.name)"
        }
    }
    
    private static func populateObject(cell: TeammateObjectCell, with teammate: TeammateLike) -> Any? {
        cell.nameLabel.text = "\(teammate.model), \(teammate.year)"
        
        cell.statusLabel.text = "COVERED"
        cell.detailsLabel.text = "Collision Deductible"
        if let left = cell.numberBar.left {
            left.titleLabel.text = "LIMIT"
            left.amountLabel.text = textFor(amount: teammate.extended?.object.claimLimit)
        }
        if let middle = cell.numberBar.middle {
            middle.titleLabel.text = "NET"
            middle.amountLabel.text = textFor(amount: teammate.extended?.basic.totallyPaidAmount)
        }
        if let right = cell.numberBar.right {
            right.titleLabel.text = "RISK FACTOR"
            right.amountLabel.text = textFor(amount: teammate.risk)
            right.badgeLabel.text = "1x47xAVG"
            right.isBadgeVisible = true
            right.currencyLabel.text = nil
        }
        guard let object = teammate.extended?.object else { return cell.button}
        
        if let imageString = object.smallPhotos.first {
            cell.avatarView.kf.setImage(with: URL(string: service.server.avatarURLstring(for: imageString)))
        }
        return cell.button
    }
    
    private static func populateStats(cell: TeammateStatsCell, with stats: TeammateStats) {
        cell.headerLabel.text = "VOTING STATS"
        if let left = cell.numberBar.left {
            left.titleLabel.text = "WEIGHT"
            left.amountLabel.text = textFor(amount: stats.weight)
        }
        if let right = cell.numberBar.right {
            right.titleLabel.text = "PROXY RANK"
            right.amountLabel.text = textFor(amount: stats.proxyRank)
            right.isBadgeVisible = false
        }
        cell.decisionsLabel.text = "Decisions"
        cell.decisionsBar.autoSet(value: stats.decisionFrequency)
        cell.decisionsBar.rightText = decisionsText(from: stats.decisionFrequency).uppercased()
        cell.discussionsLabel.text = "Discussions"
        cell.discussionsBar.autoSet(value: stats.discussionFrequency)
        cell.discussionsBar.rightText = discussionsText(from: stats.discussionFrequency).uppercased()
        cell.frequencyLabel.text = "Voting Frequency"
        cell.frequencyBar.autoSet(value: stats.votingFrequency)
        cell.frequencyBar.rightText = frequencyText(from: stats.votingFrequency).uppercased()
    }
    
    private static func populateDiscussion(cell: DiscussionCell, with stats: Topic, avatar: String) {
        cell.avatarView.kf.setImage(with: URL(string: service.server.avatarURLstring(for: avatar)))
        cell.titleLabel.text = "Application Discussion"
        switch stats.minutesSinceLastPost {
        case 0:
            cell.timeLabel.text = "JUST NOW"
        case 1..<60:
            cell.timeLabel.text = "\(stats.minutesSinceLastPost) MIN AGO"
        case 60...(60 * 24):
            cell.timeLabel.text = "\(stats.minutesSinceLastPost / 60) HR AGO"
        default:
            cell.timeLabel.text = "LONG AGO"
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
        
        cell.headerLabel.text = "CONTACT"
        let delegate = delegate as? UITableViewDelegate
        cell.tableView.delegate = delegate
        cell.tableView.dataSource = dataSource
        cell.tableView.reloadData()
    }
    
    private static func decisionsText(from value: Double) -> String {
        let value = Int(value * 100)
        switch value {
        case 0..<30: return "generous"
        case 30..<45: return "mild"
        case 45..<55: return "moderate"
        case 55..<70: return "severe"
        case 70...100: return "harsh"
        default: return "unknown"
        }
    }
    
    private static func discussionsText(from value: Double) -> String {
        let value = Int(value * 100)
        switch value {
        case 0..<3: return "quiet"
        case 3..<10: return "reserved"
        case 10..<25: return "moderate"
        case 25..<50: return "sociable"
        case 50...100: return "chatty"
        default: return "unknown"
        }
    }
    
    private static func frequencyText(from value: Double) -> String {
        let value = Int(value * 100)
        switch value {
        case 0: return "never"
        case 1..<5: return "rarely"
        case 5..<15: return "occasionally"
        case 15..<30: return "frequently"
        case 30..<60: return "often"
        case 60..<95: return "regularly"
        case 95...100: return "always"
        default: return "unknown"
        }
    }
    
    private static func textFor(amount: Double?) -> String {
        guard let amount = amount else { return "?" }
        guard amount.truncatingRemainder(dividingBy: 1) > 0.01 else { return "\(Int(amount))" }
        
        return String(format: "%.2f", amount)
    }
    
}
