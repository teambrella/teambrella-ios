//
//  ClaimVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 06.06.17.

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

import ImageSlideshow
import UIKit

final class ClaimVC: UIViewController, Routable {
    
    static var storyboardName = "Claims"
    
    var claimID: Int?
    let dataSource = ClaimDataSource()
    
    var navigationTopLabel: UILabel?
    var navigationBottomLabel: UILabel?
    
    var lastUpdatedVote: Date?
    var isPeeking: Bool = false
    var isNavBarAdded: Bool = false
    var isScrollToVoteNeeded: Bool = false
    
    var session: Session!
    var router: MainRouter!
    
    var teammateAvatarButton = UIButton()
    
    @IBOutlet var collectionView: UICollectionView!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let claimID = claimID else { return }
        
        addGradientNavBarIfNeeded()
        setupCells()
        dataSource.onUpdate = { [weak self] in
            guard let `self` = self else { return }
            
            self.reloadData()
            if self.isScrollToVoteNeeded {
                self.isScrollToVoteNeeded = false
                if let index = self.dataSource.voteCellIndexPath {
                    self.collectionView.scrollToItem(at: index, at: .top, animated: true)
                }
            }
        }
        dataSource.loadData(claimID: claimID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        manageNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        clearNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if view.frame.width == UIScreen.main.bounds.width {
            isPeeking = false
        }
        addGradientNavBarIfNeeded()
        addTeammateAvatarButtonIfNeeded()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Callbacks
    
    @objc
    func tapGallery(sender: UITapGestureRecognizer) {
        guard let gallery = sender.view as? ImageSlideshow else { return }
        
        gallery.presentFullScreenController(from: self)
    }
    
    @objc
    func sliderMoved(slider: UISlider) {
        updateVotingCell()
        lastUpdatedVote = Date()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { [weak self] in
            if let lastUpdate = self?.lastUpdatedVote {
                let difference = Date().timeIntervalSince(lastUpdate)
                if difference > 0.99 {
                    self?.lastUpdatedVote = nil
                    self?.dataSource.updateVoteOnServer(vote: slider.value)
                }
            }
            
        })
    }
    
    @objc
    func tapTransactions(sender: UITapGestureRecognizer) {
        log("\ntap Transactions\n", type: .userInteraction)
        guard let session = session.currentTeam?.teamID, let claimID = self.claimID else { return }
        
        router.presentClaimTransactionsList(teamID: session, claimID: claimID, userID: dataSource.userID)
    }
    
    @objc
    func tapResetVote(sender: UIButton) {
        self.dataSource.updateVoteOnServer(vote: nil)
    }
    
    @objc
    func tapOthersVoted(sender: UIButton) {
        guard let teamID = session.currentTeam?.teamID else { return }
        guard let claimID = dataSource.claim?.id else { return }
        
        router.presentOthersVoted(teamID: teamID, teammateID: nil, claimID: claimID)
    }
    
    @objc
    func tapTeammateAvatarButton(sender: UIButton) {
        guard let teammateID = dataSource.claim?.basic.userID else {
            log("Tap teammateAvatar. No teammate found!", type: .userInteraction)
            return
        }
        
        router.presentMemberProfile(teammateID: teammateID)
    }
    
    // MARK: Private
    
    private func updateVotingCell() {
        let cells = collectionView.visibleCells.compactMap { $0 as? ClaimVoteCell }
        guard let cell = cells.first else { return }
        
        cell.isYourVoteHidden = false
        cell.isTeamVoteHidden = false
        cell.yourVotePercentValue.text = String.truncatedNumber(cell.slider.value * 100)
        if let amount = dataSource.claim?.basic.claimAmount {
            let claimVote = ClaimVote(cell.slider.value)
            cell.yourVoteAmount.text = String.truncatedNumber(claimVote.fiat(from: amount).value)
        }
        cell.yourVotePercentValue.alpha = 0.5
        cell.yourVoteAmount.alpha = 0.5
    }
    
    private func addGradientNavBarIfNeeded() {
        if !isPeeking && !isNavBarAdded {
            addGradientNavBar()
            manageNavigationBar()
            isNavBarAdded = true
        }
    }
    
    private func setupCells() {
        collectionView.register(ImageGalleryCell.nib, forCellWithReuseIdentifier: ImageGalleryCell.cellID)
        collectionView.register(ClaimVoteCell.nib, forCellWithReuseIdentifier: ClaimVoteCell.cellID)
        collectionView.register(ClaimDetailsCell.nib, forCellWithReuseIdentifier: ClaimDetailsCell.cellID)
        collectionView.register(ClaimOptionsCell.nib, forCellWithReuseIdentifier: ClaimOptionsCell.cellID)
    }
    
    private func reloadData() {
        collectionView.reloadData()
        manageNavigationBar()
    }
    
    private func clearNavigationBar() {
        navigationTopLabel?.removeFromSuperview()
        navigationTopLabel = nil
        navigationBottomLabel?.removeFromSuperview()
        navigationBottomLabel = nil
    }
    
    private func manageNavigationBar() {
        clearNavigationBar()
        
        if let navigationBar = self.navigationController?.navigationBar {
            let firstFrame = CGRect(x: 0,
                                    y: 0, width: navigationBar.frame.width,
                                    height: navigationBar.frame.height / 2)
            let secondFrame = CGRect(x: 0,
                                     y: firstFrame.maxY,
                                     width: navigationBar.frame.width,
                                     height: navigationBar.frame.height / 2)
            
            let firstLabel = UILabel(frame: firstFrame)
            firstLabel.textAlignment = .center
            firstLabel.textColor = .white
            firstLabel.font = UIFont.teambrellaBold(size: 17)
            firstLabel.text = dataSource.claim?.basic.model ?? ""
            firstLabel.sizeToFit()
            firstLabel.center = CGPoint(x: navigationBar.bounds.midX,
                                        y: navigationBar.bounds.midY - firstLabel.frame.height / 2)
            navigationTopLabel = firstLabel
            navigationBar.addSubview(firstLabel)
            guard let claim = dataSource.claim else { return }

            let date = claim.basic.incidentDate
            let secondLabel = UILabel(frame: secondFrame)
            secondLabel.textAlignment = .center
            secondLabel.textColor = .white50
            secondLabel.font = UIFont.teambrella(size: 12)
            secondLabel.text = DateFormatter.teambrellaShort.string(from: date)
            secondLabel.sizeToFit()
            secondLabel.center = CGPoint(x: navigationBar.bounds.midX,
                                         y: navigationBar.bounds.midY + secondLabel.frame.height / 2)
            navigationBottomLabel = secondLabel
            
            navigationBar.addSubview(secondLabel)
        }
    }
    
    private func addTeammateAvatarButtonIfNeeded() {
        guard self.navigationItem.rightBarButtonItem == nil else { return }

        let teammateAvatarButton = UIButton()
        teammateAvatarButton.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        let barItem = UIBarButtonItem(customView: teammateAvatarButton)
        teammateAvatarButton.addTarget(self, action: #selector(tapTeammateAvatarButton), for: .touchUpInside)
        self.teammateAvatarButton = teammateAvatarButton
        guard let avatar = dataSource.claim?.basic.avatar else {
            log("No teammateAvatar found!", type: .error)
            return
        }

        UIImage.fetchAvatar(string: avatar,
                            width: 36,
                            cornerRadius: 36 / 2) { image, error  in
                                guard error == nil else { return }
                                guard let image = image, let cgImage = image.cgImage else { return }

                                let scaled = UIImage(cgImage: cgImage,
                                                     scale: UIScreen.main.nativeScale,
                                                     orientation: image.imageOrientation)
                                self.teammateAvatarButton.setImage(scaled, for: .normal)
                                self.teammateAvatarButton.imageView?.contentMode = .scaleAspectFill
                                self.teammateAvatarButton.imageView?.clipsToBounds = true
                                self.navigationItem.setRightBarButton(barItem, animated: true)
        }
    }
    
}

// MARK: UICollectionViewDataSource
extension ClaimVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.sections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.rows(for: section)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: dataSource.cellID(for: indexPath),
                                                  for: indexPath)
    }
    
    //    func collectionView(_ collectionView: UICollectionView,
    //                        viewForSupplementaryElementOfKind kind: String,
    //                        at indexPath: IndexPath) -> UICollectionReusableView {
    //
    //        return view
    //    }
    
}

// MARK: UICollectionViewDelegate
extension ClaimVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard let claim = dataSource.claim else { return }
        
        ClaimCellBuilder.populate(cell: cell, with: claim, delegate: self)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        at indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.cellForItem(at: indexPath) is ImageGalleryCell, let claim = dataSource.claim {
            let context = ChatContext.claim(claim)
            router.presentChat(context: context, itemType: .claim)
        }
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout
extension ClaimVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let offset: CGFloat = 16
        switch dataSource.cellID(for: indexPath) {
        case ImageGalleryCell.cellID: return CGSize(width: collectionView.bounds.width, height: 120 + 184)
        case ClaimVoteCell.cellID:
            let canVote = dataSource.claim?.voting?.canVote
            return canVote == true ? CGSize(width: collectionView.bounds.width - offset * 2, height: 250)
                                   : CGSize(width: collectionView.bounds.width - offset * 2, height: 200)
        case ClaimDetailsCell.cellID: return CGSize(width: collectionView.bounds.width - offset * 2, height: 283)
        case ClaimOptionsCell.cellID: return CGSize(width: collectionView.bounds.width, height: 112)
        default: break
        }
        return CGSize(width: collectionView.bounds.width, height: 1)
    }
    
    //    func collectionView(_ collectionView: UICollectionView,
    //                        layout collectionViewLayout: UICollectionViewLayout,
    //                        referenceSizeForHeaderInSection section: Int) -> CGSize {
    //        return CGSize(width: collectionView.bounds.width, height: 100)
    //    }
}
