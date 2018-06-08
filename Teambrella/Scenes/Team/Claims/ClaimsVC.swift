//
//  ClaimsVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 25.05.17.

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

import PKHUD
import UIKit
import XLPagerTabStrip

/**
 Shows the list of all claims or the list of claims created by a teammate if the teammate is given
 */
class ClaimsVC: UIViewController, IndicatorInfoProvider, Routable {
    static var storyboardName: String = "Claims"
    
    @IBOutlet var objectView: RadarView!
    @IBOutlet var objectImageView: UIImageView!
    @IBOutlet var objectTitle: TitleLabel!
    @IBOutlet var objectSubtitle: StatusSubtitleLabel!
    @IBOutlet var reportButton: BorderedButton!
    
    @IBOutlet var collectionView: UICollectionView!
    var dataSource = ClaimsDataSource()
    
    var isFirstLoading = true
    // is pushed to navigation stack instead of being the first controller in XLPagerTabStrip
    var isPresentedInStack = false
    var teammateID: Int?
    
   // var router: MainRouter!
    
    weak var emptyVC: EmptyVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
        HUD.show(.progress, onView: view)
        registerCells()
        dataSource.teammateID = teammateID
        dataSource.onLoadHome = { [weak self] in
            self?.setupObject()
        }
        dataSource.onUpdate = { [weak self] in
            HUD.hide()
            guard let `self` = self else { return }
            
            self.collectionView.reloadData()
            self.showEmptyIfNeeded()
        }
        dataSource.onError = { error in
            HUD.hide()
        }
        dataSource.loadHomeData()
        
        setupObjectView()
        if isPresentedInStack {
            addGradientNavBar()
            if #available(iOS 11.0, *) {
                collectionView.contentInsetAdjustmentBehavior = .never
            } else {
                automaticallyAdjustsScrollViewInsets = false
            }
        }
    }
    
    private func setupObject() {
        guard let object = dataSource.claimItem else { return }
        
        objectImageView.show(object.photo)
        objectTitle.text = object.name.entire
        objectSubtitle.text = object.location
    }
    
    private func prepareView() {
        objectImageView.image = nil
        objectTitle.text = nil
        objectSubtitle.text = nil
        objectView.color = .veryLightBlueThree
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard isFirstLoading == false else {
            dataSource.loadData()
            isFirstLoading = false
            return
        }
        
        dataSource.updateSilently()
    }
    
    @IBAction func tapReportButton(_ sender: Any) {
        guard let context = dataSource.reportContext else { return }
        
        service.router.presentReport(context: context, delegate: self)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        }
    }
    
    func setupObjectView() {
        objectView.clipsToBounds = false
        ViewDecorator.shadow(for: objectView, opacity: 0.1, radius: 8)
        objectImageView.layer.masksToBounds = true
        objectImageView.layer.cornerRadius = 4
        reportButton.setTitle("Team.Claims.objectView.reportButton.title".localized, for: .normal)
    }
    
    func registerCells() {
        collectionView.register(InfoHeader.nib,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                withReuseIdentifier: InfoHeader.cellID)
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Team.ClaimsVC.indicatorTitle".localized)
    }
    
    func showEmptyIfNeeded() {
        if dataSource.isEmpty {
            if emptyVC == nil {
                emptyVC = EmptyVC.show(in: self)
                emptyVC?.backImageView.image = nil
                emptyVC?.setImage(image: #imageLiteral(resourceName: "iconTeam"))
                emptyVC?.setText(title: "Team.Claims.Empty.title".localized,
                                 subtitle: "Team.Claims.Empty.details".localized)
            }
        } else {
            emptyVC?.remove()
            emptyVC = nil
        }
    }
}

// MARK: UICollectionViewDataSource
extension ClaimsVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.sections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.cellsIn(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: dataSource.cellIdentifier(for: indexPath),
                                                  for: indexPath)
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                               withReuseIdentifier: InfoHeader.cellID, for: indexPath)
    }
}

// MARK: UICollectionViewDelegate
extension ClaimsVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        ClaimsCellBuilder.populate(cell: cell, with: dataSource[indexPath])
        let maxRow = dataSource.itemsInSection(section: indexPath.section)
        if let cell = cell as? ClaimsOpenCell {
            ViewDecorator.decorateCollectionView(cell: cell,
                                                 isFirst: indexPath.row == 0,
                                                 isLast: indexPath.row == maxRow - 1)
        }
        if let cell = cell as? ClaimsVotedCell {
            cell.cellSeparator.isHidden = indexPath.row == maxRow - 1
            ViewDecorator.decorateCollectionView(cell: cell,
                                                 isFirst: indexPath.row == 0,
                                                 isLast: indexPath.row == maxRow - 1)
        }
        if let cell = cell as? ClaimsPaidCell {
            cell.cellSeparator.isHidden = indexPath.row == maxRow - 1
            ViewDecorator.decorateCollectionView(cell: cell,
                                                 isFirst: indexPath.row == 0,
                                                 isLast: indexPath.row == maxRow - 1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        at indexPath: IndexPath) {
        if let view = view as? InfoHeader {
            view.leadingLabel.text = dataSource.headerText(for: indexPath)
            view.trailingLabel.text = ""
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let claim = dataSource[indexPath]
        service.router.presentClaim(claim: claim)
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension ClaimsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size: CGSize!
        switch dataSource.cellType(for: indexPath) {
        case .open: size = CGSize(width: collectionView.bounds.width - 32, height: 128)
        case .voted: size = CGSize(width: collectionView.bounds.width, height: 112)
        case .paid, .fullyPaid: size = CGSize(width: collectionView.bounds.width, height: 72)
        }
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: collectionView.bounds.width, height: 16)
        } else {
            return CGSize(width: collectionView.bounds.width, height: dataSource.showHeader(for: section) ? 50 : 0.01)
        }
    }
}

// MARK: UIViewControllerPreviewingDelegate
extension ClaimsVC: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                           commit viewControllerToCommit: UIViewController) {
        service.router.push(vc: viewControllerToCommit, animated: true)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                           viewControllerForLocation location: CGPoint) -> UIViewController? {
        let updatedLocation = view.convert(location, to: collectionView)
        guard let indexPath = collectionView?.indexPathForItem(at: updatedLocation) else { return nil }
        guard let cell = collectionView?.cellForItem(at: indexPath) else { return nil }
        
        let claim = dataSource[indexPath]
        guard let vc = service.router.getControllerClaim(claimID: claim.id) else { return nil }
        
        vc.preferredContentSize = CGSize(width: view.bounds.width * 0.8, height: view.bounds.height * 0.9)
        previewingContext.sourceRect = collectionView.convert(cell.frame, to: view)
        vc.isPeeking = true
        return vc
    }
}

// MARK: ReportDelegate
extension ClaimsVC: ReportDelegate {
    func report(controller: ReportVC, didSendReport data: Any) {
        service.router.navigator?.popViewController(animated: false)
        if let claim = data as? ClaimEntityLarge {
            service.router.presentClaim(claimID: claim.id)
        }
    }
}
