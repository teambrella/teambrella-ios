//
//  TeammateProfileVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 30.05.17.

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
import PKHUD
import ThoraxMath
import UIKit
import XLPagerTabStrip

final class TeammateProfileVC: UIViewController, Routable {
    struct Constant {
        static let socialCellHeight: CGFloat = 68
        static let votingHeaderTopOffset: CGFloat = 5
        static let votingHeaderShowTime: TimeInterval = 2
    }
    
    static var storyboardName: String = "Team"
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var compactUserInfoHeader: CompactUserInfoHeader!
    @IBOutlet var compactHeaderBottomConstraint: NSLayoutConstraint!
    
    var teammateID: String!
    var teamID: Int!
    
    var dataSource: TeammateProfileDataSource!
    var linearFunction: PiecewiseFunction?
    var isRiskScaleUpdateNeeded = true
    var isPeeking: Bool = false
    var scrollToVote: Bool = false
    var summaryViewNumberBarOffset: CGFloat = 50
    var lastScrollMoment = Date()
    
    var shouldAddGradientNavBar: Bool { return teammateID != nil }
    
    var votingRiskCell: VotingRiskCell? {
        let visibleCells = collectionView.visibleCells
        return visibleCells.filter { $0 is VotingRiskCell }.first as? VotingRiskCell
    }
    
    private var currentRiskVote: Double?
    
    //    var router: MainRouter!
    //    var session: Session!
    //    var currencyName: String!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let teammateID = teammateID, teammateID == service.session?.currentUserID {
            dataSource = TeammateProfileDataSource(id: teammateID, teamID: teamID, isMe: true)
        } else if let teammateID = teammateID {
            dataSource = TeammateProfileDataSource(id: teammateID, teamID: teamID, isMe: false)
        } else if let myID = service.session?.currentUserID {
            teamID = service.session?.currentTeam?.teamID ?? 0
            dataSource = TeammateProfileDataSource(id: myID, teamID: teamID, isMe: true)
        } else {
            fatalError("No valid info about teammate")
        }
        // addGradientNavBarIfNeeded()
        registerCells()
        HUD.show(.progress, onView: view)
        
        hideHeader(animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTitle()
        
        dataSource.loadEntireTeammate(completion: { [weak self] extendedTeammate in
            HUD.hide()
            guard let `self` = self else { return }
            
            self.prepareLinearFunction()
            self.setTitle()
            self.collectionView.reloadData()
            
            if self.scrollToVote, let index = self.dataSource.votingCellIndexPath {
                self.scrollToVote = false
                self.collectionView.scrollToItem(at: index, at: .top, animated: true)
            }
            }, failure: {  [weak self] error in
                self?.navigationController?.popViewController(animated: true)
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if view.frame.width == UIScreen.main.bounds.width {
            isPeeking = false
        }
        addGradientNavBarIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        title = "Main.back".localized
    }
    
    // MARK: Public
    
    func updateAmounts(in headerView: AmountUpdatable, with risk: Double) {
        guard let myRisk = dataSource.teammateLarge?.riskScale?.myRisk else { return }
        guard let heCoversMe = linearFunction?.value(at: risk) else { return }
        
        let theirAmount = heCoversMe
        headerView.leftNumberView.amountLabel.text = amountsFormat(amount: theirAmount)
        let myAmount = heCoversMe * myRisk / risk
        headerView.rightNumberView.amountLabel.text = amountsFormat(amount: myAmount)
    }
    
    func amountsFormat(amount: Double) -> String {
        if amount == 0.0 {
            return "0"
        } else if amount < 100.0 {
            return String(format: "%.2f", amount)
        } else {
            return String(format: "%.0f", amount)
        }
    }
    
    func updateAverages(cell: VotingOrVotedRiskCell, risk: Double) {
        func text(for label: UILabel, risk: Double) {
            
            if let averageRisk = dataSource.teammateLarge?.voting?.averageRisk
                ?? dataSource.teammateLarge?.voted?.averageRisk {
            guard averageRisk != 0 else { return }
            
            let delta = risk - averageRisk
            var text = "Team.VotingRiskVC.avg".localized + "\n"
            text += delta > 0.0 ? "+" : ""
            let percent = 100 * delta / averageRisk
            let amount = String(format: "%.0f", percent)
            label.text = text + amount + "%"
            }
        }
        
        text(for: cell.yourVoteBadgeLabel, risk: risk)
        if let teamRisk = dataSource.teammateLarge?.voting?.riskVoted {
            text(for: cell.teamVoteBadgeLabel, risk: teamRisk)
        } else if let teamRisk = dataSource.teammateLarge?.voted?.riskVoted {
            text(for: cell.teamVoteBadgeLabel, risk: teamRisk)
        }
    }
    
    func resetVote(cell: VotingRiskCell) {
        let vote = dataSource.teammateLarge?.voting?.myVote
        let proxyAvatar = dataSource.teammateLarge?.voting?.proxyAvatar
        let proxyName = dataSource.teammateLarge?.voting?.proxyName
        if let vote = vote,
            let proxyAvatar = proxyAvatar,
            let proxyName = proxyName {
            cell.scrollTo(risk: vote, silently: true, animated: false)
            cell.isProxyHidden = false
            cell.resetVoteButton.isHidden = true
            cell.proxyAvatarView.show(proxyAvatar)
            cell.proxyNameLabel.text = proxyName.uppercased()
        } else {
            cell.scrollToAverage(silently: true, animated: false)
            cell.isProxyHidden = true
            cell.resetVoteButton.isHidden = true
            cell.yourVoteValueLabel.text = "..."
            cell.yourVoteBadgeLabel.isHidden = true
        }
    }
    
    // MARK: Callbacks
    
    @objc
    func showClaims(sender: UIButton) {
        if let claimCount = dataSource.teammateLarge?.object.claimCount,
            claimCount == 1,
            let claimID = dataSource.teammateLarge?.object.singleClaimID {
            service.router.presentClaim(claimID: claimID)
        } else if let teammateID = dataSource.teammateLarge?.teammateID {
            service.router.presentClaims(teammateID: teammateID)
        }
    }
    
    @objc
    func tapFacebook() {
        DeveloperTools.notSupportedAlert(in: self)
    }
    
    @objc
    func tapTwitter() {
        DeveloperTools.notSupportedAlert(in: self)
    }
    
    @objc
    func tapEmail() {
        DeveloperTools.notSupportedAlert(in: self)
    }
    
    @objc
    func tapAddToProxy(sender: UIButton) {
        dataSource.addToProxy { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    @objc
    private func tapPrivateMessage(sender: UIButton) {
        log("tapped private message", type: .userInteraction)
        guard let teammateLarge = dataSource.teammateLarge else { return }
        
        let user = PrivateChatUser(teammateLarge: teammateLarge)
        service.router.presentChat(context: .privateChat(user), itemType: .privateChat)
    }
    
    // MARK: Private
    
    private var isGradientNavBarAdded = false
    
    private func addGradientNavBarIfNeeded() {
        guard !isGradientNavBarAdded else { return }
        
        if !isPeeking && shouldAddGradientNavBar {
            addGradientNavBar()
            isGradientNavBarAdded = true
            if !dataSource.isMe, let accessLevel = service.session?.currentTeam?.teamAccessLevel, accessLevel == .full {
                addPrivateMessageButton()
            }
            setTitle()
        }
    }
    
    private func registerCells() {
        collectionView.register(DiscussionCell.nib, forCellWithReuseIdentifier: TeammateProfileCellType.dialog.rawValue)
        collectionView.register(MeCell.nib, forCellWithReuseIdentifier: TeammateProfileCellType.me.rawValue)
        collectionView.register(VotingRiskCell.nib,
                                forCellWithReuseIdentifier: TeammateProfileCellType.voting.rawValue)
        collectionView.register(VotedRiskCell.nib,
                                forCellWithReuseIdentifier: TeammateProfileCellType.voted.rawValue)
        collectionView.register(TeammateSummaryView.nib,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                withReuseIdentifier: TeammateSummaryView.cellID)
    }
    
    private func setTitle() {
        title = dataSource.teammateLarge?.basic.name.short
    }
    
    private func prepareLinearFunction() {
        guard let risk = dataSource.teammateLarge?.riskScale else { return }
        
        let function = PiecewiseFunction((0.2, risk.coversIfMin), (1, risk.coversIfOne), (5, risk.coversIfMax))
        linearFunction = function
    }
    
    private func addPrivateMessageButton() {
        let barItem = UIBarButtonItem(image: #imageLiteral(resourceName: "inbox"), style: .plain, target: self, action: #selector(tapPrivateMessage))
        navigationItem.setRightBarButton(barItem, animated: true)
    }
    
    private func setupCompactInfoHeader() {
        let session = service.session
        let currencyName = session?.currentTeam?.currency ?? ""
        
        guard let teammate = dataSource.teammateLarge else { return }
        
        if let view = compactUserInfoHeader {
            if dataSource.isMe {
                view.radarView.color = .veryLightBlueThree
            }
            view.radarView.centerY = -view.bounds.midY
            ViewDecorator.shadow(for: view, opacity: 0.05, radius: 4)
            view.avatarView.showAvatar(string: teammate.basic.avatar)
            if let left = view.leftNumberView {
                let genderization = teammate.basic.gender == .male ? "Team.TeammateCell.HeWouldCoverMe".localized
                    : "Team.TeammateCell.SheWouldCoverMe".localized
                left.titleLabel.text = genderization
                let amount = teammate.basic.coversMeAmount
                left.amountLabel.text = amountsFormat(amount: amount)
                left.currencyLabel.text = currencyName
                left.isCurrencyVisible = true
                left.isPercentVisible = false
            }
            if let right = view.rightNumberView {
                let genderization = teammate.basic.gender == .male ? "Team.TeammateCell.wouldCoverHim".localized
                    : "Team.TeammateCell.wouldCoverHer".localized
                right.titleLabel.text = genderization
                let amount = teammate.basic.iCoverThemAmount
                right.amountLabel.text = amountsFormat(amount: amount)
                right.currencyLabel.text = currencyName
                right.isCurrencyVisible = true
                right.isPercentVisible = false
            }
            
            if let risk = currentRiskVote {
                updateAmounts(in: view, with: risk)
            }
        }
    }
    
    private func showHeader(offset: CGFloat) {
        if offset < Constant.votingHeaderTopOffset {
            view.layoutIfNeeded()
            self.compactHeaderBottomConstraint.constant = 60
            let animator = UIViewPropertyAnimator(duration: 1, curve: .easeOut) {
                self.view.layoutIfNeeded()
            }
            animator.startAnimation()
        }
    }
    
    private func hideHeader(animated: Bool) {
        view.layoutIfNeeded()
        compactHeaderBottomConstraint.constant = 0
        if animated {
            let animator = UIViewPropertyAnimator(duration: 1, curve: .easeIn) {
                self.view.layoutIfNeeded()
            }
            animator.startAnimation()
        }
    }

    private func makeACall() {
        guard let basic = dataSource.teammateLarge?.basic,
            let myName = service.session?.currentUserName else { return }

        service.sinch.call(userID: teammateID, name: myName.entire)
        service.router.showCall(in: self, to: basic.name.entire, avatar: basic.avatar, id: teammateID)
    }
}

// MARK: UICollectionViewDataSource
extension TeammateProfileVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.sections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.rows(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = dataSource.type(for: indexPath).rawValue
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                                   withReuseIdentifier: TeammateSummaryView.cellID,
                                                                   for: indexPath)
        }
        if kind == UICollectionElementKindSectionFooter {
            return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter,
                                                                   withReuseIdentifier: "footer",
                                                                   for: indexPath)
        }
        fatalError("Unknown supplementary view of kind: \(kind)")
    }
    
}

// MARK: UICollectionViewDelegate
extension TeammateProfileVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard let teammate = dataSource.teammateLarge else { return }
        
        TeammateCellBuilder.populate(cell: cell, with: teammate, controller: self)
    }
    
    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        at indexPath: IndexPath) {
        let session = service.session
        let currencyName = session?.currentTeam?.currency ?? ""
        
        guard let teammate = dataSource.teammateLarge else { return }
        
        if let view = view as? TeammateSummaryView {
            if dataSource.isMe {
                view.radarView.color = .veryLightBlueThree
            }
            view.title.text = teammate.basic.name.entire
            //let url = URL(string: service.server.avatarURLstring(for: teammate.basic.avatar))
            view.avatarView.present(avatarString: teammate.basic.avatar)
            view.avatarView.onTap = { [weak self] view in
                guard let `self` = self else { return }
                
                view.fullscreen(in: self, imageStrings: nil)
            }
            //cell.avatarView.kf.setImage(with: url)
            if let left = view.leftNumberView {
                left.isHidden = dataSource.isMe
                let votingGenderization = teammate.basic.gender == .male ? "Team.TeammateCell.HeWouldCoverMe".localized
                    : "Team.TeammateCell.SheWouldCoverMe".localized
                let genderization = teammate.basic.gender == .male ? "Team.TeammateCell.heCoversMe".localized
                    : "Team.TeammateCell.sheCoversMe".localized
                left.titleLabel.text = dataSource.isNewTeammate ? votingGenderization : genderization
                let amount = teammate.basic.coversMeAmount
                left.amountLabel.text = amountsFormat(amount: amount)
                left.currencyLabel.text = currencyName
                left.isCurrencyVisible = true
                left.isPercentVisible = false
            }
            if let right = view.rightNumberView {
                right.isHidden = dataSource.isMe
                let votingGenderization = teammate.basic.gender == .male ? "Team.TeammateCell.wouldCoverHim".localized
                    : "Team.TeammateCell.wouldCoverHer".localized
                let genderization = teammate.basic.gender == .male ? "Team.TeammateCell.coverHim".localized
                    : "Team.TeammateCell.coverHer".localized
                right.titleLabel.text = dataSource.isNewTeammate ? votingGenderization : genderization
                let amount = teammate.basic.iCoverThemAmount
                right.amountLabel.text = amountsFormat(amount: amount)
                right.currencyLabel.text = currencyName
                right.isCurrencyVisible = true
                right.isPercentVisible = false
            }
            if let city = teammate.basic.city {
                view.subtitle.text = city.uppercased()
            } else {
                view.subtitle.text = ""
            }
            if teammate.basic.isProxiedByMe, let myID = service.session?.currentUserID, teammate.basic.id != myID {
                view.infoLabel.isHidden = false
                view.infoLabel.text = "Team.TeammateCell.youAreProxy_format_s".localized(teammate.basic.name.entire)
            }
            if dataSource.isNewTeammate, let risk = currentRiskVote {
                updateAmounts(in: view, with: risk)
                setupCompactInfoHeader()
            }
        }
        if elementKind == UICollectionElementKindSectionFooter, let footer = view as? TeammateFooter {
            if let date = teammate.basic.dateJoined {
                let dateString = Formatter.teambrellaShort.string(from: date)
                footer.label.text = "Team.Teammate.Footer.MemberSince".localized(dateString)
            } else {
                footer.isHidden = true
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let identifier = dataSource.type(for: indexPath)
        if identifier == .dialog || identifier == .dialogCompact, let extendedTeammate = dataSource.teammateLarge {
            let context = ChatContext.teammate(extendedTeammate)
            service.router.presentChat(context: context, itemType: .teammate)
        }
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout
extension TeammateProfileVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let wdt = collectionView.bounds.width - 16 * 2
        switch dataSource.type(for: indexPath) {
        case .summary:
            return CGSize(width: collectionView.bounds.width, height: 210)
        case .object:
            /*guard let teammate = dataSource.extendedTeammate,
             teammate.object.claimCount > 0 else { return CGSize(width: wdt, height: 216) } */
            
            return CGSize(width: wdt, height: 296)
        case .stats:
            guard  dataSource.teammateLarge != nil,
                dataSource.isMe == true else { return CGSize(width: wdt, height: 368) }
            
            return CGSize(width: wdt, height: 311)
        case .contact:
            let base: CGFloat = 38
            let cellHeight: CGFloat = Constant.socialCellHeight
            return CGSize(width: wdt, height: base + CGFloat(dataSource.socialItems.count) * cellHeight)
        case .dialog:
            return isSmallIPhone ? CGSize(width: collectionView.bounds.width, height: 105)
                : CGSize(width: collectionView.bounds.width, height: 110)
        case .me:
            return CGSize(width: collectionView.bounds.width, height: 215)
        case .voting:
            return CGSize(width: wdt, height: 360)
        case .voted:
            return CGSize(width: wdt, height: 180)
        case .dialogCompact:
            return  CGSize(width: collectionView.bounds.width, height: 98)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard dataSource.teammateLarge != nil else { return CGSize.zero }
        
        return CGSize(width: collectionView.bounds.width, height: 210)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let teammate = dataSource.teammateLarge else { return CGSize(width: 0, height: 0) }
        
        if teammate.basic.dateJoined != nil {
            return CGSize(width: collectionView.bounds.width, height: 80)
        } else {
            return CGSize(width: collectionView.bounds.width, height: 20)
        }
    }
}

// MARK: UIScrollViewDelegate
extension TeammateProfileVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleViews = collectionView.visibleSupplementaryViews(ofKind: UICollectionElementKindSectionHeader)
        let summaryViews = visibleViews.filter { $0 is TeammateSummaryView }
        guard let summary = summaryViews.first as? TeammateSummaryView else { return }
        guard let numberView = summary.leftNumberView else { return }
        
        let rect = collectionView.convert(numberView.frame, to: collectionView.superview)
        summaryViewNumberBarOffset = rect.origin.y - collectionView.frame.origin.y
    }
}

// MARK: UITableViewDataSource
extension TeammateProfileVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.socialItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "ContactCellTableCell", for: indexPath)
    }
}

// MARK: UITableViewDelegate
extension TeammateProfileVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? ContactCellTableCell {
            let item = dataSource.socialItems[indexPath.row]
            cell.avatarView.image = item.icon
            cell.topLabel.text = item.name.uppercased()
            if item.type == .facebook {
                cell.bottomLabel.text = "https://m.facebook.com"
            } else if dataSource.isMyProxy && item.type == .call {
                cell.bottomLabel.text = "my proxy"
            } else {
                cell.bottomLabel.text = item.address
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = dataSource.socialItems[indexPath.row]
        if item.type == .facebook, let url = URL(string: item.address) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        if dataSource.isMyProxy && item.type == .call {
            makeACall()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.socialCellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
}

// MARK: IndicatorInfoProvider
extension TeammateProfileVC: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Me.ProfileVC.indicatorTitle".localized)
    }
    
}

// MARK: VotingRiskCellDelegate
extension TeammateProfileVC: VotingRiskCellDelegate {
    func votingRisk(cell: VotingRiskCell, changedRisk: Double) {
        currentRiskVote = changedRisk
        cell.yourVoteValueLabel.text = String(format: "%.2f", changedRisk)
        cell.middleAvatarLabel.text = String(format: "%.2f", changedRisk)
        updateAverages(cell: cell, risk: changedRisk)
        cell.showYourNoVote(risk: changedRisk)
        cell.colorizeCenterCell()
        let kind = UICollectionElementKindSectionHeader
        if let view = collectionView.visibleSupplementaryViews(ofKind: kind).first as? TeammateSummaryView {
            updateAmounts(in: view, with: changedRisk)
        }
        if let canVote = dataSource.teammateLarge?.voting?.canVote, canVote == true {
            if let header = compactUserInfoHeader {
                updateAmounts(in: header, with: changedRisk)
            }
        }
    }
    
    func votingRisk(cell: VotingRiskCell, stoppedOnRisk: Double) {
        var risk = stoppedOnRisk
        cell.yourVoteValueLabel.alpha = 0.5
        guard let teammateID = dataSource.teammateLarge?.teammateID else { return }
        
        if risk < 0.2 { risk = 0.2 }
        currentRiskVote = risk
        dataSource.sendRisk(userID: teammateID, risk: risk) { [weak self] votingResult in
            self?.collectionView.reloadData()
            guard let header = self?.compactUserInfoHeader else { return }
            
            self?.updateAmounts(in: header, with: stoppedOnRisk)
        }
    }
    
    func votingRisk(cell: VotingRiskCell, changedMiddleRowIndex: Int) {
        func setAvatar(avatarView: RoundImageView, label: UILabel, with teammate: RiskScaleTeammate?) {
            guard let teammate = teammate else {
                avatarView.isHidden = true
                avatarView.image = nil
                label.isHidden = true
                return
            }
            
            avatarView.isHidden = false
            label.isHidden = false
            avatarView.showAvatar(string: teammate.avatar,
                                  options: [.transition(.fade(0.5)), .forceTransition])
            label.text = String(format: "%.2f", teammate.risk)
            label.backgroundColor = .blueWithAHintOfPurple
        }
        guard let range = dataSource.teammateLarge?.riskScale?.ranges[changedMiddleRowIndex] else { return }
        
        if range.teammates.count > 1 {
            setAvatar(avatarView: cell.rightAvatar, label: cell.rightAvatarLabel, with: range.teammates.last)
        } else {
            cell.rightAvatar.isHidden = true
            cell.rightAvatarLabel.isHidden = true
        }
        setAvatar(avatarView: cell.leftAvatar, label: cell.leftAvatarLabel, with: range.teammates.first)
    }
    
    func votingRisk(cell: VotingOrVotedRiskCell, didTapButton button: UIButton) {
        if let cell = cell as? VotingRiskCell {
            switch button {
            case cell.resetVoteButton:
                guard let teammateID = dataSource.teammateLarge?.teammateID else { return }
                
                cell.yourVoteValueLabel.alpha = 0.5
                dataSource.sendRisk(userID: teammateID, risk: nil) { [weak self] json in
                    self?.collectionView.reloadData()
                    guard let header = self?.compactUserInfoHeader, let risk = self?.currentRiskVote else { return }
                    
                    self?.updateAmounts(in: header, with: risk)
                }
            case cell.othersButton:
                guard let ranges = dataSource.teammateLarge?.riskScale?.ranges else {
                    log("Can't present CompareTeamRisk controller. No ranges in extendedTeammate.", type: .error)
                    return
                }
                
                service.router.presentCompareTeamRisk(ranges: ranges)
            case cell.othersVotesButton:
                guard let teamID = service.session?.currentTeam?.teamID else { return }
                guard let teammateID = dataSource.teammateLarge?.teammateID else { return }
                
                service.router.presentOthersVoted(teamID: teamID, teammateID: teammateID, claimID: nil)
            default:
                log("VotingRiskCell unknown button pressed", type: [.error])
            }
        } else if cell is VotedRiskCell {
            guard let teamID = service.session?.currentTeam?.teamID,
                let teammateID = dataSource.teammateLarge?.teammateID,
                let voters = dataSource.teammateLarge?.voting?.votersCount
                ?? dataSource.teammateLarge?.voted?.votersCount else { return }
            
            if voters > 0 {
                service.router.presentOthersVoted(teamID: teamID, teammateID: teammateID, claimID: nil)
            }
        }
    }
    
    func votingRisk(cell: VotingRiskCell, didScroll: UIScrollView) {
        if let canVote = dataSource.teammateLarge?.voting?.canVote, canVote == true {
            showHeader(offset: summaryViewNumberBarOffset)
            lastScrollMoment = Date()
            DispatchQueue.main.asyncAfter(deadline: .now() + Constant.votingHeaderShowTime) {
                let now = Date()
                if now.timeIntervalSince1970 - self.lastScrollMoment.timeIntervalSince1970 >
                    Constant.votingHeaderShowTime - 1 {
                    self.hideHeader(animated: true)
                    self.lastScrollMoment = Date()
                }
            }
        }
    }
    
    func averageVotingRisk(cell: VotingRiskCell) -> Double {
        return dataSource.teammateLarge?.voting?.averageRisk ?? 0
    }
}
