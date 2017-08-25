//
//  UniversalChatVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 19.06.17.

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

enum ChatContext {
    case claim(EnhancedClaimEntity)
    case teammate(ExtendedTeammate)
    case feed(FeedEntity)
    case home(HomeScreenModel.Card)
    case chat(ChatModel)
    case none
}

class UniversalChatVC: UIViewController, Routable {
    static var storyboardName = "Chat"
    
    @IBOutlet var input: ChatInputView!
    @IBOutlet var collectionView: UICollectionView!
    
    let dataSource = UniversalChatDatasource()
    
    public var endsEditingWhenTappingOnChatBackground = true
    
    //var topic: Topic?
    func cloudSize(for indexPath: IndexPath) -> CGSize {
        guard let model = dataSource[indexPath] as? ChatTextCellModel else { return .zero }
        
        return CGSize(width: cloudWidth,
                      height: model.totalFragmentsHeight + CGFloat(model.fragments.count) * 2 + 50 )
    }
    
    var cloudWidth: CGFloat { return collectionView.bounds.width * 0.66 }
    var shouldScrollToBottom: Bool = true
    var isFirstRefresh: Bool = true
    
    private var lastTypingDate: Date = Date()
    
    func setContext(context: ChatContext) {
        dataSource.addContext(context: context)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientNavBar()
        input.removeFromSuperview()
        setupCollectionView()
        setupInput()
        setupTapGestureRecognizer()
        listenForKeyboard()
        dataSource.onUpdate = { [weak self] backward in
            guard let me = self else { return }
            
            print("Datasource has \(me.dataSource.count) messages after update")
            me.refresh(backward: backward)
        }
        dataSource.isLoadNextNeeded = true
        title = dataSource.title
        
        service.socket?.add(listener: self, action: { action in
            print("Received socket action: \(action)")
        })
    }
    
    deinit {
        service.socket?.remove(listener: self)
    }
    
    func refresh(backward: Bool) {
        // not using reloadData() to avoid blinking of cells
        collectionView.dataSource = nil
        collectionView.dataSource = self
        
        if self.shouldScrollToBottom {
            self.collectionView.scrollToItem(at: self.dataSource.lastIndexPath,
                                             at: .bottom,
                                             animated: !isFirstRefresh)
            self.shouldScrollToBottom = false
            self.isFirstRefresh = false
        }
        if backward {
            let indexPath = IndexPath(row: dataSource.count - dataSource.previousCount, section: 0)
            self.collectionView.scrollToItem(at: indexPath,
                                             at: .top,
                                             animated: false)
        }
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
            layout.estimatedItemSize = CGSize(width: collectionView.bounds.width, height: 30)
        }
        dataSource.cloudWidth = cloudWidth
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopListeningSockets()
    }
    
    private func setupInput() {
        input?.leftButton.addTarget(self, action: #selector(tapLeftButton), for: .touchUpInside)
        input?.rightButton.addTarget(self, action: #selector(tapRightButton), for: .touchUpInside)
        if let socket = service.socket,
            let teamID = service.session.currentTeam?.teamID,
            let myID = service.session.currentUserID {
            input?.onTextChange = { [weak socket, weak self] in
                guard let me = self else { return }
                
                let interval = me.lastTypingDate.timeIntervalSinceNow
                if interval < -2 {
                    socket?.typing(teamID: teamID, teammateID: myID)
                    self?.lastTypingDate = Date()
                }
            }
        }
    }
    
    private func startListeningSockets() {
        service.socket?.add(listener: self) { message in
            print("Socket received \(message)")
        }
    }
    
    private func stopListeningSockets() {
        service.socket?.remove(listener: self)
    }
    
    func tapLeftButton(sender: UIButton) {
        showImagePicker(controller: self)
    }
    
    func showImagePicker(controller: UIViewController) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        controller.present(picker, animated: true, completion: nil)
    }
    
    func tapRightButton(sender: UIButton) {
        guard let text = input?.textView.text else { return }
        
        send(text: text, images: [])
    }
    
    func send(text: String, images: [String]) {
        guard dataSource.isLoading == false else { return }
        
        self.shouldScrollToBottom = true
        dataSource.send(text: text, images: images)
        input.textView.text = nil
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
        collectionView.register(ChatTextCell.self, forCellWithReuseIdentifier: "Test")
    }
    
    override func keyboardWillHide(notification: Notification) {
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: input.frame.height, right: 0)
        collectionView.contentInset = contentInsets
        collectionView.scrollIndicatorInsets = contentInsets
        //        }
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
    
    func moveInput(height: CGFloat, duration: TimeInterval, curve: UInt) {
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
    
    public func scrollToBottom(animated: Bool, completion: (() -> Void)? = nil) {
        // Cancel current scrolling
        self.collectionView.setContentOffset(self.collectionView.contentOffset, animated: false)
        
        let offsetY = max(-collectionView.contentInset.top,
                          collectionView.collectionViewLayout.collectionViewContentSize.height
                            - collectionView.bounds.height
                            + collectionView.contentInset.bottom)
        
        if animated {
            UIView.animate(withDuration: 0.33, animations: { () -> Void in
                self.collectionView.contentOffset = CGPoint(x: 0, y: offsetY)
            }) { completed in
                completion?()
            }
        } else {
            self.collectionView.contentOffset = CGPoint(x: 0, y: offsetY)
            completion?()
        }
    }
    
    func send(image: UIImage) {
        service.server.updateTimestamp { [weak self] timestamp, error in
            guard error == nil else { return }
            
            let imageData = UIImageJPEGRepresentation(image, 0.3)
            var body = RequestBody(key: service.server.key, payload: nil)
            body.contentType = "image/jpeg"
            body.data = imageData
            let request = TeambrellaRequest(type: .uploadPhoto, body: body, success: { [weak self] response in
                if case .uploadPhoto(let name) = response {
                    print("Photo uploaded name: \(name)")
                    self?.linkImage(name: name)
                }
            })
            request.start()
        }
    }
    
    func linkImage(name: String) {
        send(text: input?.textView.text ?? "", images: [name])
    }
    
    func tapAvatar(sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        
        let indexPath = IndexPath(row: view.tag, section: 0)
        if let model = dataSource[indexPath] as? ChatTextCellModel {
            let userID = model.entity.userID
            service.router.presentMemberProfile(teammateID: userID)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Test", for: indexPath)
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
        if indexPath.row > dataSource.count - 20 {
            dataSource.loadNext()
        }
        let model = dataSource[indexPath]
        if let cell = cell as? ChatTextCell, let model = model as? ChatTextCellModel {
            let size = cloudSize(for: indexPath)
            cell.prepare(with: model, cloudWidth: size.width, cloudHeight: size.height)
            cell.avatarView.tag = indexPath.row
            cell.avatarTap.removeTarget(self, action: #selector(tapAvatar))
            cell.avatarTap.addTarget(self, action: #selector(tapAvatar))
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

// MARK: UIImagePickerControllerDelegate
extension UniversalChatVC: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            print("Image received: \(pickedImage)")
            send(image: pickedImage)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}

extension UniversalChatVC: UINavigationControllerDelegate {
    
}

// MARK: UICollectionViewDelegateFlowLayout
extension UniversalChatVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let model = dataSource[indexPath] as? ChatTextCellModel {
            let size = cloudSize(for: indexPath)
            return CGSize(width: collectionView.bounds.width, height: size.height)
        }
        return CGSize(width: collectionView.bounds.width - 32, height: 100)
    }
    
}
