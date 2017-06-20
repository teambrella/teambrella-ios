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
    
    @IBOutlet var input: ChatInputView!
    @IBOutlet var collectionView: UICollectionView!
    
//    @IBOutlet var inputViewHeightConstraint: NSLayoutConstraint!
//    @IBOutlet var inputViewBottomConstraint: NSLayoutConstraint!
    
    let dataSource = UniversalChatDatasource()
    
      public var endsEditingWhenTappingOnChatBackground = true
    
    var topic: Topic? {
        get { return dataSource.topic }
        set { dataSource.topic = newValue }
    }
    
    var claim: EnhancedClaimEntity? {
        get { return dataSource.claim }
        set { dataSource.claim =  newValue }
    }
    
    var teammate: TeammateLike?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        input.removeFromSuperview()
        setupCollectionView()
        setupInput()
        setupTapGestureRecognizer()
        listenForKeyboard()
        dataSource.loadNext()
        dataSource.onUpdate = { [weak self] in
            self?.collectionView.reloadData()
        }
        title = claim?.name ?? "none"
    }
    
    override var inputAccessoryView: UIView? {
        return input
    }
    
    override var canBecomeFirstResponder: Bool { return true }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startListeningSockets()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = CGSize(width: collectionView.bounds.width, height: 1)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopListeningSockets()
    }
    
    private func setupInput() {
        input?.leftButton.addTarget(self, action: #selector(tapLeftButton), for: .touchUpInside)
        input?.rightButton.addTarget(self, action: #selector(tapRightButton), for: .touchUpInside)
    }
    
    private func startListeningSockets() {
        service.socket.add(listener: self) { message in
            print("Socket received \(message)")
        }
    }
    
    private func stopListeningSockets() {
        service.socket.remove(listener: self)
    }
    
    func tapLeftButton(sender: UIButton) {
        
    }
    
    func tapRightButton(sender: UIButton) {
        guard let text = input?.textView.text else { return }
        
        dataSource.send(text: text) { [weak self] success in
            self?.collectionView.reloadData()
            guard let collectionView = self?.collectionView else { return }
            
            collectionView.performBatchUpdates({
                collectionView.reloadSections([0])
            }, completion: { success in
                self?.input?.textView.text = nil
                self?.scrollToBottom(animated: true)
            })
        }
    }
    
    func setupCollectionView() {
        registerCells()
        collectionView.keyboardDismissMode = .interactive
        collectionView.showsVerticalScrollIndicator = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsSelection = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.autoresizingMask = UIViewAutoresizing()
        automaticallyAdjustsScrollViewInsets = false
    }
    
    func registerCells() {
        collectionView.register(ChatCell.nib, forCellWithReuseIdentifier: ChatCell.cellID)
    }
    
    override func keyboardWillHide(notification: Notification) {
        if let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt {
            //moveInput(height: 48, duration: duration, curve: curve)
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: input.frame.height, right: 0)
            collectionView.contentInset = contentInsets
            collectionView.scrollIndicatorInsets = contentInsets
        }
    }
    
    override func keyboardWillShow(notification: Notification) {
        if let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt {
            var offset =  collectionView.contentOffset
            offset.y += keyboardFrame.height
            collectionView.contentOffset = offset
            moveInput(height: keyboardFrame.height, duration: duration, curve: curve)
        }
    }
    
    override func keyboardWillChangeFrame(notification: Notification) {
        if let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt {
//            moveInput(height: view.bounds.height - keyboardFrame.minY, duration: duration, curve: curve)
        }
    }
    
    func moveInput(height: CGFloat, duration: TimeInterval, curve: UInt) {
//        inputViewBottomConstraint.constant = height
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0)
        collectionView.contentInset = contentInsets
        collectionView.scrollIndicatorInsets = contentInsets
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
    
    private func setupTapGestureRecognizer() {
        collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                   action: #selector(userDidTapOnCollectionView)))
    }
    
    @objc
    open func userDidTapOnCollectionView() {
        if self.endsEditingWhenTappingOnChatBackground {
            self.view.endEditing(true)
        }
    }
    
    public func scrollToBottom(animated: Bool) {
        // Cancel current scrolling
        self.collectionView.setContentOffset(self.collectionView.contentOffset, animated: false)
 
        let offsetY = max(-collectionView.contentInset.top,
                          collectionView.collectionViewLayout.collectionViewContentSize.height
                            - collectionView.bounds.height
                            + collectionView.contentInset.bottom)
        
        if animated {
            UIView.animate(withDuration: 0.33, animations: { () -> Void in
                self.collectionView.contentOffset = CGPoint(x: 0, y: offsetY)
            })
        } else {
            self.collectionView.contentOffset = CGPoint(x: 0, y: offsetY)
        }
    }
    
}

// MARK: UICollectionViewDataSource
extension UniversalChatVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatCell.cellID, for: indexPath)
        return cell
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
            let chatItem = dataSource.posts[indexPath.row]
            ChatTextParser().populate(cell: cell, with: chatItem)
            cell.align(offset: collectionView.bounds.width * 0.3, toLeading: chatItem.name != "Iaroslav Pasternak")
            cell.dateLabel.text = Formatter.teambrellaShort.string(from: chatItem.created)
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
//extension UniversalChatVC: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//       // let constraintRect = CGSize(width: collectionView.bounds.width, height: CGFloat.max)
//       
//        return CGSize(width: collectionView.bounds.width - 32, height: 100)
//    }
//
//}
