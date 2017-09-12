//
//  WalletVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.

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
    
    @objc
    func tapFund(sender: UIButton) {
        service.router.presentWalletDetails(walletID: walletID)
        print("tap Fund")
    }
    
    @objc
    func tapBarcode(sender: UIButton) {
        service.router.presentWalletDetails(walletID: walletID)
        print("tap Barcode")
    }
    
    @objc
    func tapInfo(sender: UIButton) {
        print("tap Info")
    }
    
    @objc
    func tapWithdraw(sender: UIButton) {
        print("tap Withdraw")
    }
    
    func generateQRCode() -> UIImage? {
        guard var qrCode = QRCode(walletID) else { return nil }
        
        qrCode.size = CGSize(width: 79, height: 75) // Zeplin (04.2 wallet-1 & ...-1-a)
        return qrCode.image
    }
    
    @objc
    func tapTransactions(sender: UITapGestureRecognizer) {
        guard let session = service.session?.currentTeam?.teamID else { return }
        
        service.router.presentWalletTransactionsList(teamID: session)
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
        WalletCellBuilder.populate(cell: cell, with: dataSource[indexPath], delegate: self)
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
