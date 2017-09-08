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

class ClaimVC: UIViewController, Routable {
    
    static var storyboardName = "Claims"
    
    var claimID: String?
    let dataSource = ClaimDataSource()
    
    var navigationTopLabel: UILabel?
    var navigationBottomLabel: UILabel?
    
    var lastUpdatedVote: Date?
    
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let claimID = claimID else { return }
        
        addGradientNavBar()
        setupCells()
        dataSource.onUpdate = { [weak self] in
            self?.reloadData()
        }
        dataSource.loadData(claimID: claimID)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        clearNavigationBar()
    }
    
    func reloadData() {
        collectionView.reloadData()
        manageNavigationBar()
    }
    
    func clearNavigationBar() {
        navigationTopLabel?.removeFromSuperview()
        navigationTopLabel = nil
        navigationBottomLabel?.removeFromSuperview()
        navigationBottomLabel = nil
    }
    
    func manageNavigationBar() {
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
            firstLabel.text = dataSource.claim?.model ?? ""
            firstLabel.sizeToFit()
            firstLabel.center = CGPoint(x: navigationBar.bounds.midX,
                                        y: navigationBar.bounds.midY - firstLabel.frame.height / 2)
            navigationTopLabel = firstLabel
            navigationBar.addSubview(firstLabel)
            guard let enhancedClaim = dataSource.claim, let date = enhancedClaim.incidentDate else { return }
            
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
    
    private func setupCells() {
        collectionView.register(ImageGalleryCell.nib, forCellWithReuseIdentifier: ImageGalleryCell.cellID)
        collectionView.register(ClaimVoteCell.nib, forCellWithReuseIdentifier: ClaimVoteCell.cellID)
        collectionView.register(ClaimDetailsCell.nib, forCellWithReuseIdentifier: ClaimDetailsCell.cellID)
        collectionView.register(ClaimOptionsCell.nib, forCellWithReuseIdentifier: ClaimOptionsCell.cellID)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
    
    func updateVotingCell() {
        let cells = collectionView.visibleCells.flatMap { $0 as? ClaimVoteCell }
        guard let cell = cells.first else { return }
        
        cell.yourVotePercentValue.text = String.truncatedNumber(cell.slider.value * 100)
        if let amount = dataSource.claim?.claimAmount {
            cell.yourVoteAmount.text = String.truncatedNumber(cell.slider.value * Float(amount))
        }
        cell.yourVotePercentValue.alpha = 0.5
        cell.yourVoteAmount.alpha = 0.5
    }
    
    @objc
    func tapTransactions(sender: UITapGestureRecognizer) {
        print("\ntap Transactions\n")
        guard let session = service.session?.currentTeam?.teamID, let claimID = self.claimID else { return }
        
        guard let id = Int(claimID) else { return }
        
        service.router.presentClaimTransactionsList(teamID: session, claimID: id)
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
            service.router.presentChat(context: context)
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
        case ImageGalleryCell.cellID: return CGSize(width: collectionView.bounds.width, height: 111 + 184)
        case ClaimVoteCell.cellID: return CGSize(width: collectionView.bounds.width - offset * 2, height: 332)
        case ClaimDetailsCell.cellID: return CGSize(width: collectionView.bounds.width - offset * 2, height: 293)
        case ClaimOptionsCell.cellID: return CGSize(width: collectionView.bounds.width, height: 168)
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
