//
//  MembersVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 25.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import PKHUD
import UIKit
import XLPagerTabStrip

class MembersVC: UIViewController, IndicatorInfoProvider {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var searchView: UIView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var searchViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var inviteFriendButton: BorderedButton!
    
    let dataSource = MembersDatasource(orderByRisk: false)
    var searchController: UISearchController!
    fileprivate var previousScrollOffset: CGFloat = 0
    fileprivate var searchbarIsShown = true
    
    lazy var router: MembersRouter = MembersRouter()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchController()
        dataSource.onUpdate = { [weak self] in
            HUD.hide()
            self?.collectionView.reloadData()
            self?.activityIndicator.stopAnimating()
        }
        
        dataSource.onError = { [weak self] error in
            HUD.hide()
            guard let error = error as? TeambrellaError else { return }
            
            let controller = UIAlertController(title: "Error", message: error.description, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            controller.addAction(cancel)
            self?.present(controller, animated: true, completion: nil)
            self?.activityIndicator.stopAnimating()
        }
        
        activityIndicator.startAnimating()
        
        HUD.show(.progress, onView: view)
        dataSource.loadData()
        title = "Team.team".localized
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Team.MembersVC.indicatorTitle".localized)
    }
    
    private func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Team.MembersVC.searchHere".localized
        searchBar.placeholder = "Team.MembersVC.searchHere".localized
            
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        
        searchBar.backgroundImage = UIImage()
        inviteFriendButton.setTitle("Team.MembersVC.inviteAFriend".localized, for: .normal)
        
    }
    
    fileprivate func showSearchBar(show: Bool, animated: Bool) {
        guard show != searchbarIsShown else { return }
        
        searchViewTopConstraint.constant = show
            ? 0
            : -searchView.frame.height
        collectionView.contentInset.top = show ? searchView.frame.height : 0
        searchbarIsShown = show
        if !show {
            view.endEditing(true)
        }
        if animated {
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        } else {
            view.setNeedsLayout()
        }
    }
    
    @IBAction func tapSort(_ sender: UIButton) {
        service.router.showFilter(in: self, delegate: self, currentSort: dataSource.sortType)
    }
    
}

// MARK: UICollectionViewDataSource
extension MembersVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.sections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.itemsInSection(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell!
        switch dataSource.type(indexPath: indexPath) {
        case .new:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CandidateCell",
                                                      for: indexPath)
            if cell is TeammateCandidateCell {
                
            }
        case .teammate:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TeammateCell",
                                                      for: indexPath)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                                   withReuseIdentifier: "TeammatesHeader",
                                                                   for: indexPath)
        return view
    }
    
}

// MARK: UICollectionViewDelegate
extension MembersVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        let teammate = dataSource[indexPath]
        MembersCellBuilder.populate(cell: cell, with: teammate)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        at indexPath: IndexPath) {
        if let view = view as? TeammateHeaderView {
            view.titleLabel.text = dataSource.headerTitle(indexPath: indexPath)
            view.subtitleLabel.text = dataSource.headerSubtitle(indexPath: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("tap item at \(indexPath)")
        router.presentMemberProfile(teammate: dataSource[indexPath])
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout
extension MembersVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 72)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 56)
    }
}

// MARK: UISearchResultsUpdating
extension MembersVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

// MARK: UISearchBarDelegate
extension MembersVC: UISearchBarDelegate {
    
}

// MARK: UIScrollViewDelegate
extension MembersVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let velocity = currentOffset - previousScrollOffset
        previousScrollOffset = currentOffset
        
        if velocity > 10 {
            showSearchBar(show: false, animated: true)
        }
        if velocity < -10 {
            showSearchBar(show: true, animated: true)
        }
    }
}

// MARK: SortControllerDelegate
extension MembersVC: SortControllerDelegate {
    func sort(controller: SortVC, didSelect type: SortVC.SortType) {
        dataSource.sort(type: type)
    }
}
