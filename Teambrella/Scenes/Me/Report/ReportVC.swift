//
//  ReportVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 24.06.17.

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

import UIKit

class ReportVC: UIViewController, Routable {
    static let storyboardName: String = "Me"
    
    @IBOutlet var collectionView: UICollectionView!
    var reportContext: ReportContext!
    var dataSource: ReportDataSource!
    
    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.date = Date()
        datePicker.datePickerMode = .dateAndTime
        datePicker.minuteInterval = 5
        return datePicker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTransparentNavigationBar()
        defaultGradientOnTop()
        addKeyboardObservers()
        automaticallyAdjustsScrollViewInsets = false
        dataSource = ReportDataSource(context: reportContext)
        ReportCellBuilder.registerCells(in: collectionView)
        title = "Report a Claim"
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
    
    func tapView(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showSubmitButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showSubmitButton()
    }
    
    private func showSubmitButton() {
        navigationItem.setRightBarButton(UIBarButtonItem(title: "Submit",
                                                         style: .done,
                                                         target: self,
                                                         action: #selector(tapSubmit(_:))),
                                         animated: false)
    }
    
    func tapSubmit(_ sender: UIButton) {
        print("tap Submit")
    }
    
    var photoController: PhotoPreviewVC = PhotoPreviewVC(collectionViewLayout: UICollectionViewFlowLayout())
    
    func addPhotoController(to view: UIView) {
        photoController.loadViewIfNeeded()
        if let superview = photoController.view.superview, superview == view {
            return
        }
        photoController.view.removeFromSuperview()
        photoController.removeFromParentViewController()
        photoController.didMove(toParentViewController: nil)
        photoController.willMove(toParentViewController: self)
        view.addSubview(photoController.view)
        photoController.view.frame = view.bounds
        photoController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addChildViewController(photoController)
        photoController.didMove(toParentViewController: self)
    }
    
}

// MARK: UICollectionViewDataSource
extension ReportVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = dataSource[indexPath].cellReusableIdentifier
        print(identifier + " at: \(indexPath)")
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier,
                                                  for: indexPath)
    }
    
}

// MARK: UICollectionViewDelegate
extension ReportVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        ReportCellBuilder.populate(cell: cell, with: dataSource[indexPath], reportVC: self)
        if let cell = cell as? ReportPhotoGalleryCell {
            addPhotoController(to: cell.container)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout
extension ReportVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 16 * 2,
                      height: CGFloat(dataSource[indexPath].preferredHeight))
    }
}
