//
/* Copyright(C) 2017 Teambrella, Inc.
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

import UIKit
import PKHUD

class WithdrawVC: UIViewController, CodeCaptureDelegate {

    @IBOutlet var backView: UIView!
    @IBOutlet var collectionView: UICollectionView!
    
    let dataSource = WithdrawDataSource(teamID: service.session?.currentTeam?.teamID ?? 0)
    fileprivate var previousScrollOffset: CGFloat = 0
    
    var isFirstLoading = true
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HUD.show(.progress, onView: view)
        //ask this
        collectionView.register(WithdrawDetailsCell.nib, forCellWithReuseIdentifier: WithdrawDetailsCell.cellID)

        dataSource.onUpdate = { [weak self] in
            HUD.hide()
            self?.collectionView.reloadData()
        }
        
        dataSource.onError = { [weak self] error in
            HUD.hide()
            guard let error = error as? TeambrellaError else { return }
            
            let controller = UIAlertController(title: "Error", message: error.description, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            controller.addAction(cancel)
            self?.present(controller, animated: true, completion: nil)
        }
        
        dataSource.loadData()
        title = "Me.Wallet.Withdraw".localized
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard isFirstLoading == false else {
            isFirstLoading = false
            return
        }
        
        //dataSource.updateSilently()
    }
    
    func codeCapture(controller: CodeCaptureVC, didCapture: String, type: QRCodeType) {
        
    }
    
    func codeCaptureWillClose(controller: CodeCaptureVC) {
        
    }

}

// MARK: UICollectionViewDataSource
extension WithdrawVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.sections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.rows(in: section)
    }
    
//    func collectionView(_ collectionView: UICollectionView,
//                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell: UICollectionViewCell!
//        /////fixIt
//        switch dataSource.type(indexPath: indexPath) {
//        case .new:
//            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CandidateCell",
//                                                      for: indexPath)
//        case .teammate:
//            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TeammateCell",
//                                                      for: indexPath)
//        }
//        return cell
//    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                                   withReuseIdentifier: "WithdrawHeader",
                                                                   for: indexPath)
        return view
    }
    
}

// MARK: UICollectionViewDelegate
extension WithdrawVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard let model = dataSource[indexPath] else { return }
        
        WithdrawCellBuilder.populate(cell: cell, with: model)
        
        let maxRow = dataSource.rows(in: indexPath.section)
        if let cell = cell as? WithdrawCell {
            cell.separator.isHidden = indexPath.row == maxRow - 1
            ViewDecorator.decorateCollectionView(cell: cell,
                                                 isFirst: indexPath.row == 0,
                                                 isLast: indexPath.row == maxRow - 1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        at indexPath: IndexPath) {
        if let view = view as? WithdrawHeader {
//            view.leadingLabel.text = dataSource.headerTitle(indexPath: indexPath)
//            view.trailingLabel.text = dataSource.headerSubtitle(indexPath: indexPath)
        }
    }

}

// MARK: UICollectionViewDelegateFlowLayout
extension WithdrawVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 72)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return section == 0 ? CGSize(width: collectionView.bounds.width, height: 0) :
            CGSize(width: collectionView.bounds.width, height: 56)
    }
}

// MARK: UIScrollViewDelegate
extension WithdrawVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        /*
         let currentOffset = scrollView.contentOffset.y
         let velocity = currentOffset - previousScrollOffset
         previousScrollOffset = currentOffset
         
         if velocity > 10 {
         showSearchBar(show: false, animated: true)
         }
         if velocity < -10 {
         showSearchBar(show: true, animated: true)
         }
         */
    }
}
