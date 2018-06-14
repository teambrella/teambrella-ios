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

import PKHUD
import QRCode
import UIKit
import XLPagerTabStrip

class WalletVC: UIViewController {
    struct Constant {
        static let headerCellHeight: CGFloat = 180
        static let fundingCellHeight: CGFloat = 227
        static let buttonsCellHeight: CGFloat = 163
        static let horizontalCellPadding: CGFloat = 16
    }
    
    var qrCode: UIImage?
    var dataSource: WalletDataSource = WalletDataSource()
    var walletID = ""
    var wallet: WalletEntity?
    
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HUD.show(.progress, onView: view)
        WalletCellBuilder.registerCells(in: collectionView)
        dataSource.onUpdate = { [weak self] in
            HUD.hide()
            self?.wallet = self?.dataSource.wallet
            self?.collectionView.reloadData()
            self?.collectionView.refreshControl?.endRefreshing()
        }

        dataSource.onError = { [weak self] error in
            HUD.hide()
            if let error = error as? TeambrellaError, error.kind == .walletNotCreated {
                self?.dataSource.emptyWallet()
            } else {
                service.error.present(error: error)
            }
        }
        addRefreshControl()
        prepareWalletAddress()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dataSource.loadData()
    }
    
    func addRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.bluishGray
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        collectionView.alwaysBounceVertical = true
    }
    
    @objc
    func refresh(sender: UIRefreshControl) {
        dataSource.loadData()
    }
    
    func prepareWalletAddress() {
        service.dao.freshKey { [weak self] key in
            let processor = EthereumProcessor(key: key)
            self?.walletID = processor.ethAddressString ?? ""
            self?.qrCode = self?.generateQRCode()
        }
    }
    
    @objc
    func tapFund(sender: UIButton) {
        service.router.presentWalletDetails(walletID: walletID)
        log("tap Fund", type: .userInteraction)
    }
    
    @objc
    func tapBarcode(sender: UIButton) {
        service.router.presentWalletDetails(walletID: walletID)
    }
    
    @objc
    func tapInfo(sender: UIButton) {
        log("tap Info", type: .userInteraction)
    }
    
    @objc
    func tapWithdraw(sender: UIButton) {
        guard let wallet = wallet else { return }
        
        service.router.presentWithdraw(balance: MEth(wallet.cryptoBalance), reserved: wallet.cryptoReserved)
    }
    
    func generateQRCode() -> UIImage? {
        guard var qrCode = QRCode(walletID) else { return nil }

        qrCode.size = CGSize(width: 79, height: 75) // Zeplin (04.2 wallet-1 & ...-1-a)
        return qrCode.image
    }
    
    @objc
    func tapTransactions(sender: UITapGestureRecognizer) {
        guard let session = service.session?.currentTeam?.teamID else { return }
        
        service.router.presentWalletTransactionsList(teamID: session,
                                                     balance: wallet?.cryptoBalance,
                                                     reserved: wallet?.cryptoReserved)
    }
    
    @objc
    func tapCosigners(sender: UITapGestureRecognizer) {
        log("tap co-signers", type: .userInteraction)
        guard let wallet = wallet else { return }
        
        service.router.presentWalletCosignersList(cosigners: wallet.cosigners)
    }
    
    @objc
    func tapBackupWallet(sender: UITapGestureRecognizer) {
        log("tap backup wallet", type: .userInteraction)
        let alertController = UIAlertController(title: "Me.WalletVC.actionsCell.backupWallet".localized,
                                   message: "", preferredStyle: .actionSheet)
        let qrCode = UIAlertAction(title: "QR code", style: .default, handler: nil)
        let passPhrase = UIAlertAction(title: "Pass Phrase", style: .default, handler: nil)
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(qrCode)
        alertController.addAction(passPhrase)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
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
            cell.button.removeTarget(self, action: nil, for: .allEvents)
            cell.button.addTarget(self, action: #selector(tapWithdraw), for: .touchUpInside)
        } else if let cell = cell as? WalletFundingCell {
            cell.fundWalletButton.addTarget(self, action: #selector(tapFund), for: .touchUpInside)
            cell.barcodeButton.addTarget(self, action: #selector(tapBarcode), for: .touchUpInside)
            cell.infoButton.addTarget(self, action: #selector(tapInfo), for: .touchUpInside)
            cell.barcodeButton.setImage(qrCode, for: .normal)
        }
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
