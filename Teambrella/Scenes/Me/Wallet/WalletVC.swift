//
//  WalletVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class WalletVC: UIViewController {
    struct Constant {
        static let headerCellHeight: CGFloat = 247
        static let fundingCellHeight: CGFloat = 279
        static let buttonsCellHeight: CGFloat = 163
        static let horizontalCellPadding: CGFloat = 16
    }
    
    var dataSource: WalletDataSource = WalletDataSource()
    
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        WalletCellBuilder.registerCells(in: collectionView)
    }
    
    func tapFund(sender: UIButton) {
        MeRouter().presentWalletDetails()
    }
    
    func tapBarcode(sender: UIButton) {
        print("tap Barcode")
    }
    
    func tapInfo(sender: UIButton) {
        print("tap Info")
    }
    
    func tapWithdraw(sender: UIButton) {
        print("tap Withdraw")
    }
}

extension WalletVC: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Me.WalletVC.indicatorTitle".localized)
    }
}

// MARK: UICollectionViewDataSource
extension WalletVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return WalletCellBuilder.dequeueCell(in: collectionView, indexPath: indexPath, for: dataSource[indexPath])
    }
    
}

// MARK: UICollectionViewDelegate
extension WalletVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        WalletCellBuilder.populate(cell: cell, with: dataSource[indexPath])
        if let cell = cell as? WalletHeaderCell {
            cell.button.addTarget(self, action: #selector(tapWithdraw), for: .touchUpInside)
        } else if let cell = cell as? WalletFundingCell {
            cell.fundWalletButton.addTarget(self, action: #selector(tapFund), for: .touchUpInside)
            cell.barcodeButton.addTarget(self, action: #selector(tapBarcode), for: .touchUpInside)
            cell.infoButton.addTarget(self, action: #selector(tapInfo), for: .touchUpInside)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        at indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout
extension WalletVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.row {
        case 0:
            return CGSize(width: collectionView.bounds.width, height: Constant.headerCellHeight)
        case 1:
            return CGSize(width: collectionView.bounds.width - Constant.horizontalCellPadding * 2,
                          height: Constant.fundingCellHeight)
        case 2:
            return CGSize(width: collectionView.bounds.width, height: Constant.buttonsCellHeight)
        default:
            return CGSize.zero
        }
    }
    
}
