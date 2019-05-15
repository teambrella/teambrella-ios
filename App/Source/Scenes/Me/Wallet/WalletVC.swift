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
import SafariServices

final class WalletVC: UIViewController {
    struct Constant {
        static let headerCellHeight: CGFloat = 250
        static let headerCellHeightHiddenLabel: CGFloat = 210
        static let txsCellHeight: CGFloat = 200
        static let buttonsCellHeight: CGFloat = 109
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
            let walletID = service.session?.currentUserEthereumAddress ?? ""
            self.walletID = walletID
            let codeManager = QRCodeManager()
            codeManager.size = CGSize(width: 79, height: 75)
            qrCode = codeManager.code(from: walletID)
    }
    
    @objc
    func etherScanTapped(sender: UIButton)
    {
        guard !(wallet?.contractAddress ?? "").isEmpty else {
            return
        }
        log("tap Fund", type: .userInteraction)
        let url = URL(string: "https://etherscan.io/address/" + wallet!.contractAddress!)!
        present(SFSafariViewController(url: url), animated: true, completion: nil)
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
    
    @objc
    func tapTransactions(sender: UIButton) {
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
        Statistics.log(event: .tapSavePrivateKey)
        let alertController = UIAlertController(title: "",
                                                message: "Me.WalletVC.actionsCell.backupWallet".localized,
                                                preferredStyle: .actionSheet)
        let qrCode = UIAlertAction(title: "Me.WalletVC.actionsCell.backupWallet.qrCode".localized,
                                   style: .default) { action in
                                    self.showAlertBeforePresentingQRCode()
        }
        /*
         let passPhrase = UIAlertAction(title: "Me.WalletVC.actionsCell.backupWallet.passPhrase".localized,
         style: .default,
         handler: nil)
         */
        let cancel = UIAlertAction(title: "Me.WalletVC.actionsCell.backupWallet.cancel".localized,
                                   style: .cancel,
                                   handler: nil)
        alertController.addAction(qrCode)
        //        alertController.addAction(passPhrase)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }

    private func showAlertBeforePresentingQRCode() {
        let alertController = UIAlertController(title: "Me.WalletVC.QRCodeAlert.attention".localized,
                                                message: "Me.WalletVC.QRCodeAlert.attentionDetails".localized,
                                                preferredStyle: .alert)
        let sure = UIAlertAction(title: "Me.WalletVC.QRCodeAlert.yes".localized,
                                 style: .destructive) { action in
                                    service.router.showWalletQRCode(in: self)
        }
        let cancel = UIAlertAction(title: "Me.WalletVC.actionsCell.backupWallet.cancel".localized,
                                   style: .cancel,
                                   handler: nil)
        alertController.addAction(sure)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
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
            cell.withdrawButton.removeTarget(self, action: nil, for: .allEvents)
            cell.withdrawButton.addTarget(self, action: #selector(tapWithdraw), for: .touchUpInside)
            cell.fundWalletButton.addTarget(self, action: #selector(tapFund), for: .touchUpInside)
            cell.etherScanButton.addTarget(self, action: #selector(etherScanTapped), for: .touchUpInside)
            if (wallet?.contractAddress ?? "").isEmpty {
                cell.etherScanButton.isHidden = true
            }
        } else if let cell = cell as? WalletTxsCell {
            cell.allTxsButton.addTarget(self, action: #selector(tapTransactions), for: .touchUpInside)
            cell.infoButton.addTarget(self, action: #selector(tapInfo), for: .touchUpInside)
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
            var height = Constant.headerCellHeight
            if let model = dataSource[indexPath] as? WalletHeaderCellModel, model.fundWalletComment == "" {
                height = Constant.headerCellHeightHiddenLabel
            }
            return CGSize(width: collectionView.bounds.width, height: height)
        case 1:
            return CGSize(width: collectionView.bounds.width - Constant.horizontalCellPadding * 2,
                          height: Constant.txsCellHeight)
        case 2:
            return CGSize(width: collectionView.bounds.width, height: Constant.buttonsCellHeight)
        default:
            return CGSize.zero
        }
    }
}
