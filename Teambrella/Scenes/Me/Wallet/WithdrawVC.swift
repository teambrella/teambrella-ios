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

import AVFoundation
import PKHUD
import UIKit

class WithdrawVC: UIViewController, CodeCaptureDelegate, Routable {
    
    static let storyboardName = "Me"
    
    @IBOutlet var backView: UIView!
    @IBOutlet var collectionView: UICollectionView!
    
    var teamID: Int = 0
    
    let dataSource = WithdrawDataSource(teamID: service.session?.currentTeam?.teamID ?? 0)
    fileprivate var previousScrollOffset: CGFloat = 0
    
    var isFirstLoading = true
    
    var keyboardTopY: CGFloat?
    var keyboardHeight: CGFloat {
        guard let top = self.keyboardTopY else { return 0 }
        
        return self.view.bounds.maxY - top
    }
    
    // MARK: Lifecycle
    
    func setupCrypto(balance: MEth, reserved: Ether) {
        dataSource.cryptoBalance = Ether(balance)
        dataSource.cryptoReserved = reserved
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HUD.show(.progress, onView: view)
        collectionView.register(WalletInfoCell.nib, forCellWithReuseIdentifier: WalletInfoCell.cellID)
        collectionView.register(WithdrawDetailsCell.nib, forCellWithReuseIdentifier: WithdrawDetailsCell.cellID)
        collectionView.register(WithdrawCell.nib, forCellWithReuseIdentifier: WithdrawCell.cellID)
        collectionView.register(WithdrawHeader.nib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                withReuseIdentifier: WithdrawHeader.cellID)
        
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
        addKeyboardObservers()
        addGradientNavBar()
        title = "Me.Wallet.Withdraw".localized
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.contentInset.bottom = keyboardHeight
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listenForKeyboard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard isFirstLoading == true else {
            isFirstLoading = false
            return
        }
        
        dataSource.loadData()
        //dataSource.updateSilently()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopListeningKeyboard()
    }
    
    private func listenForKeyboard() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChangeFrame),
                                               name: Notification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
    }
    
    private func stopListeningKeyboard() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc
    func keyboardWillChangeFrame(notification: Notification) {
        if let finalFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let offset = collectionView.contentOffset
            guard finalFrame.minY < collectionView.contentSize.height else { return }
            
            keyboardTopY = finalFrame.minY
            collectionView.contentOffset = offset
            collectionView.contentInset.bottom = keyboardHeight
        }
    }
    
    func addKeyboardObservers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapView))
        view.addGestureRecognizer(tap)
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(adjustForKeyboard),
                           name: Notification.Name.UIKeyboardWillHide,
                           object: nil)
        center.addObserver(self, selector: #selector(adjustForKeyboard),
                           name: Notification.Name.UIKeyboardWillChangeFrame,
                           object: nil)
    }
    
    @objc
    func adjustForKeyboard(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let value = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = value.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            collectionView.contentInset = UIEdgeInsets.zero
        } else {
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        collectionView.scrollIndicatorInsets = collectionView.contentInset
        if let responder = collectionView.currentFirstResponder() as? UIView {
            for cell in collectionView.visibleCells where responder.isDescendant(of: cell) {
                if let indexPath = collectionView.indexPath(for: cell) {
                    collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
                }
            }
        }
    }
    
    @objc
    func tapView(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func codeCapture(controller: CodeCaptureVC, didCapture: String, type: QRCodeType) {
        controller.confirmButton.isEnabled = true
        controller.confirmButton.alpha = 1
    }
    
    func codeCaptureWillClose(controller: CodeCaptureVC, cancelled: Bool) {
        guard !cancelled else { return }
        
        dataSource.ethereumAddress = EthereumAddress(string: controller.lastReadString)
        collectionView.reloadData()
    }
    
    @objc
    private func tapQR() {
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            showCodeCapture()
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { [weak self] granted in
                if granted {
                    self?.showCodeCapture()
                } else {
                    self?.alertNoCameraAccess()
                }
            })
        }
    }
    
    private func showCodeCapture() {
        let vc = service.router.showCodeCapture(in: self, delegate: self)
        vc?.confirmButton.isEnabled = false
        vc?.confirmButton.alpha = 0.5
    }
    
    private func alertNoCameraAccess() {
        let alert = UIAlertController(title: "Me.Wallet.Withdraw.noCameraAccess.title".localized,
                                      message: "Me.Wallet.Withdraw.noCameraAccess.details".localized,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Me.Wallet.Withdraw.noCameraAccess.cancelButton".localized,
                                      style: .cancel))
        alert.addAction(UIAlertAction(title: "Me.Wallet.Withdraw.noCameraAccess.settingsButton".localized,
                                      style: .default) { (alert) -> Void in
                                        guard let url = URL(string: UIApplicationOpenSettingsURLString) else { return }
                                        UIApplication.shared.open(url, options: [:], completionHandler: { success in
                                            
                                        })
        })
        
        present(alert, animated: true)
    }
    
    @objc
    private func tapInfo() {
        service.router.showWithdrawInfo(in: self,
                                        balance: dataSource.cryptoBalance,
                                        reserved: dataSource.cryptoReserved)
    }
    
    @objc
    private func tapWithdraw(sender: UIButton) {
        sender.isEnabled = false
        sender.alpha = 0.5
        dataSource.withdraw()
        dataSource.cleanWithdrawDetails()
    }
    
    func changedDetails(cell: WithdrawDetailsCell) {
        dataSource.detailsModel.toValue = cell.cryptoAddressTextView.text
        dataSource.detailsModel.amountValue = cell.cryptoAmountTextField.text ?? ""
        
        if validateAddress(string: dataSource.detailsModel.toValue)
            && validateAmount(string: dataSource.detailsModel.amountValue) {
            cell.submitButton.alpha = 1
            cell.submitButton.isEnabled = true
        } else {
            cell.submitButton.alpha = 0.5
            cell.submitButton.isEnabled = false
        }
    }
    
    func validateAddress(string: String) -> Bool {
        return EthereumAddress(string: string) != nil
    }
    
    func validateAmount(string: String) -> Bool {
        guard let amount = Double(string) else { return false }
        
        return MEth(amount) <= MEth(dataSource.maxEthAvailable) && amount != 0
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
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        if indexPath.section == 0 && indexPath.row == 0 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: WalletInfoCell.cellID, for: indexPath)
        } else if indexPath.section == 0 && indexPath.row == 1 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: WithdrawDetailsCell.cellID, for: indexPath)
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: WithdrawCell.cellID, for: indexPath)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                                   withReuseIdentifier: WithdrawHeader.cellID,
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
        if let cell = cell as? WithdrawDetailsCell {
            cell.qrButton.removeTarget(self, action: nil, for: .allEvents)
            cell.qrButton.addTarget(self, action: #selector(tapQR), for: .touchUpInside)
            cell.infoButton.removeTarget(self, action: nil, for: .allEvents)
            cell.infoButton.addTarget(self, action: #selector(tapInfo), for: .touchUpInside)
            cell.submitButton.removeTarget(self, action: nil, for: .allEvents)
            cell.submitButton.addTarget(self, action: #selector(tapWithdraw), for: .touchUpInside)
            cell.onValuesChanged = { [weak self] cell in
                self?.changedDetails(cell: cell)
            }
        }
        let maxRow = dataSource.rows(in: indexPath.section)
        if let cell = cell as? WithdrawCell {
            cell.separator.isHidden = indexPath.row == maxRow - 1
            ViewDecorator.decorateCollectionView(cell: cell,
                                                 isFirst: indexPath.row == 0,
                                                 isLast: indexPath.row == maxRow - 1)
            guard let text = cell.rightLabel.text else { return }
            
            let keyIndex = text.index(text.endIndex, offsetBy: -3)
            let amountAttributed = NSMutableAttributedString(string: text)
                .decorate(substring: String(text[..<keyIndex]), type: .integerPart)
                .decorate(substring: String(text[keyIndex...]), type: .fractionalPart)
            cell.rightLabel.attributedText = amountAttributed
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        at indexPath: IndexPath) {
        if let view = view as? WithdrawHeader {
            view.leadingLabel.text = dataSource.headerName(section: indexPath.section)
            view.trailingLabel.text = dataSource.currencyName(section: indexPath.section)
        }
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout
extension WithdrawVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 && indexPath.row == 0 {
            return CGSize(width: collectionView.bounds.width - 32, height: 150)
        } else if indexPath.section == 0 && indexPath.row == 1 {
            return CGSize(width: collectionView.bounds.width - 32, height: 300)
        } else {
            return CGSize(width: collectionView.bounds.width, height: 72)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return section == 0
            ? CGSize(width: collectionView.bounds.width, height: 20)
            : CGSize(width: collectionView.bounds.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return section == 0 ? CGFloat(16) : CGFloat(0)
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
