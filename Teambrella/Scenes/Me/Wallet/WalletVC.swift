//
//  WalletVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import QRCode
import UIKit
import XLPagerTabStrip

class WalletVC: UIViewController {
    struct Constant {
        static let headerCellHeight: CGFloat = 247
        static let fundingCellHeight: CGFloat = 279
        static let buttonsCellHeight: CGFloat = 163
        static let horizontalCellPadding: CGFloat = 16
    }
    
    var qrCode: UIImage?
    var dataSource: WalletDataSource = WalletDataSource()
    let walletID = "13CAnApBYfERwCvpp4KSypHg7BQ5BXwg3x".uppercased()
    
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        WalletCellBuilder.registerCells(in: collectionView)
        qrCode = generateQRCode()
        dataSource.onUpdate = { [weak self] in
            self?.collectionView.reloadData()
        }
        dataSource.loadData()
        
    }
    
    func tapFund(sender: UIButton) {
        MeRouter().presentWalletDetails(walletID: walletID)
        print("tap Fund")
    }
    
    func tapBarcode(sender: UIButton) {
        MeRouter().presentWalletDetails(walletID: walletID)
        print("tap Barcode")
    }
    
    func tapInfo(sender: UIButton) {
        print("tap Info")
    }
    
    func tapWithdraw(sender: UIButton) {
        print("tap Withdraw")
    }
    
    func generateQRCode() -> UIImage? {
        guard var qrCode = QRCode(walletID) else { return nil }
        
        qrCode.size = CGSize(width: 79, height: 75) // Zeplin (04.2 wallet-1 & ...-1-a)
        return qrCode.image
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
            cell.barcodeButton.setImage(qrCode, for: .normal)
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
