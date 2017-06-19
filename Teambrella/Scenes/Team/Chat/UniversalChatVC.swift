//
//  UniversalChatVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 19.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class UniversalChatVC: UIViewController, Routable {
    static var storyboardName = "Chat"
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var input: ChatInputView!
    @IBOutlet var inputViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var inputViewBottomConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        listenForKeyboard()
        input.leftButton.addTarget(self, action: #selector(tapLeftButton), for: .touchUpInside)
        input.rightButton.addTarget(self, action: #selector(tapRightButton), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
        //            layout.estimatedItemSize = CGSize(width: collectionView.bounds.width, height: 100)
        //        }
    }
    
    func tapLeftButton(sender: UIButton) {
        
    }
    
    func tapRightButton(sender: UIButton) {
        view.endEditing(true)
    }
    
    func registerCells() {
        collectionView.register(ChatCell.nib, forCellWithReuseIdentifier: ChatCell.cellID)
    }
    
    override func keyboardWillHide(notification: Notification) {
        if let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt {
            moveInput(height: 0, duration: duration, curve: curve)
        }
    }
    
    override func keyboardWillShow(notification: Notification) {
        if let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt {
            moveInput(height: keyboardFrame.height, duration: duration, curve: curve)
        }
    }
    
    override func keyboardWillChangeFrame(notification: Notification) {
        if let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt {
            moveInput(height: keyboardFrame.height, duration: duration, curve: curve)
        }
    }
    
    func moveInput(height: CGFloat, duration: TimeInterval, curve: UInt) {
        inputViewBottomConstraint.constant = height
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: [UIViewAnimationOptions(rawValue: curve)],
                       animations: {
                        self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: UICollectionViewDataSource
extension UniversalChatVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: ChatCell.cellID, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                                   withReuseIdentifier: "Header",
                                                                   for: indexPath)
        return view
    }
    
}

// MARK: UICollectionViewDelegate
extension UniversalChatVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if let cell = cell as? ChatCell {
            cell.dateLabel.text = "Date"
            for _ in 0...Random.range(to: 5) {
                cell.add(text: "Ololo")
            }
            cell.align(offset: collectionView.bounds.width * 0.3, toLeading: indexPath.row % 2 == 0)
            cell.setNeedsDisplay()
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
extension UniversalChatVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 32, height: 100)
    }
    
}
