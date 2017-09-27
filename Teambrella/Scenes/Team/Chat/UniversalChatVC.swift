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
    case teammate(ExtendedTeammateEntity)
    case feed(FeedEntity)
    case home(HomeScreenModel.Card)
    case chat(ChatModel)
    case privateChat(PrivateChatUser)
    case none
}

final class UniversalChatVC: UIViewController, Routable {
    static var storyboardName = "Chat"
    
    @IBOutlet var collectionView: UICollectionView!
    
    override var inputAccessoryView: UIView? { return input }
    override var canBecomeFirstResponder: Bool { return true }
    
    lazy var picker: ImagePickerController = { ImagePickerController(parent: self, delegate: self) }()
    
    private let input: InputAccessoryView = InputAccessoryView()
    private let dataSource = UniversalChatDatasource()
    private var socketToken = "UniversalChat"
    private var lastTypingDate: Date = Date()
    private var typingUsers: [String: Date] = [:]
    private var endsEditingWhenTappingOnChatBackground = true
    private var shouldScrollToBottom: Bool = true
    private var isFirstRefresh: Bool = true
    
    private var showIsTyping: Bool = false {
        didSet {
            collectionView.reloadData()
        }
    }
    private var cloudWidth: CGFloat { return collectionView.bounds.width * 0.66 }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientNavBar()
        setupCollectionView()
        setupInput()
        setupTapGestureRecognizer()
        dataSource.onUpdate = { [weak self] backward, hasNew in
            guard hasNew else { return }
            
            self?.refresh(backward: backward)
        }
        dataSource.isLoadNextNeeded = true
        title = dataSource.title
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startListeningSockets()
        listenForKeyboard()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = CGSize(width: collectionView.bounds.width, height: 30)
            layout.footerReferenceSize = CGSize(width: collectionView.bounds.width, height: 30)
        }
        dataSource.cloudWidth = cloudWidth
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopListeningSockets()
        stopListeningKeyboard()
    }
    
    deinit {
        service.socket?.remove(listener: socketToken)
    }
    
    func setContext(context: ChatContext, itemType: ItemType) {
        dataSource.addContext(context: context, itemType: itemType)
    }
    
    // MARK: Callbacks
    
    @objc
    func tapLeftButton(sender: UIButton) {
        picker.showOptions()
        //input.isHidden = true
    }
    
    @objc
    func tapRightButton(sender: UIButton) {
        guard let text = input.textView.text else { return }
        
        send(text: text, images: [])
    }
    
    @objc
    open func userDidTapOnCollectionView() {
        if self.endsEditingWhenTappingOnChatBackground {
            self.view.endEditing(true)
        }
    }
    
    @objc
    func refreshNeeded(sender: UIRefreshControl) {
        if dataSource.hasPrevious {
            dataSource.loadPrevious()
        } else {
            sender.endRefreshing()
            sender.removeTarget(self, action: nil, for: .allEvents)
            collectionView.refreshControl = nil
        }
    }
    
    @objc
    func keyboardWillChangeFrame(notification: Notification) {
        if let finalFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let initialFrame = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            var offset =  collectionView.contentOffset
            let diff = initialFrame.minY - finalFrame.minY
            offset.y += diff
            collectionView.contentOffset = offset
            collectionView.contentInset.bottom = view.frame.maxY - finalFrame.minY
        }
    }
    
    @objc
    func tapAvatar(sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        
        let indexPath = IndexPath(row: view.tag, section: 0)
        if let model = dataSource[indexPath] as? ChatTextCellModel {
            let userID = model.entity.userID
            service.router.presentMemberProfile(teammateID: userID)
        }
    }
    
    @objc
    func tapHeader(sender: UIButton) {
        if let claimID = dataSource.claimID {
            service.router.presentClaim(claimID: claimID)
        }
    }
    
    // MARK: Private
    
    /**
     * Refresh controller after new data comes from the server
     *
     * - Parameter backward: if the chunk of data comes above existing cells or below them
     */
    private func refresh(backward: Bool) {
        // not using reloadData() to avoid blinking of cells
        collectionView.dataSource = nil
        collectionView.dataSource = self
        
        if self.shouldScrollToBottom {
            scrollToBottom(animated: true)
            self.shouldScrollToBottom = false
            self.isFirstRefresh = false
        } else if backward, let indexPath = dataSource.currentTopCell {
            self.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
        }
        collectionView.refreshControl?.endRefreshing()
    }
    
    private func cloudSize(for indexPath: IndexPath) -> CGSize {
        guard let model = dataSource[indexPath] as? ChatTextCellModel else { return .zero }
        
        return CGSize(width: cloudWidth,
                      height: model.totalFragmentsHeight + CGFloat(model.fragments.count) * 2 + 50 )
    }
    
    private func processIsTyping(action: SocketAction) {
        guard case let .theyTyping(_, _, _, name) = action.data else { return }
        
        showIsTyping = true
        typingUsers[name] = Date()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let `self` = self else { return }
            
            if Date().timeIntervalSince(self.lastTypingDate) > 3 {
                self.showIsTyping = false
                self.typingUsers.removeAll()
            }
        }
    }
    
    private func setupInput() {
        input.leftButton.addTarget(self, action: #selector(tapLeftButton), for: .touchUpInside)
        input.rightButton.addTarget(self, action: #selector(tapRightButton), for: .touchUpInside)
        if let socket = service.socket,
            let teamID = service.session?.currentTeam?.teamID {
            input.onTextChange = { [weak socket, weak self] in
                guard let me = self else { return }
                
                let interval = me.lastTypingDate.timeIntervalSinceNow
                if interval < -2, let topicID = me.dataSource.topicID,
                    let name = service.session?.currentUserName {
                    socket?.meTyping(teamID: teamID, topicID: topicID, name: name)
                    self?.lastTypingDate = Date()
                }
            }
        }
    }
    
    private func startListeningSockets() {
        service.socket?.add(listener: socketToken, action: { [weak self] action in
            log("add command \(action.command)", type: .socket)
            switch action.command {
            case .theyTyping, .meTyping:
                self?.processIsTyping(action: action)
            case .privateMessage,
                 .newPost:
                self?.showIsTyping = false
                self?.dataSource.hasNext = true
                self?.dataSource.loadNext()
            default:
                break
            }
        })
    }
    
    private func stopListeningSockets() {
        service.socket?.remove(listener: self)
    }
    
    private func send(text: String, images: [String]) {
        guard dataSource.isLoading == false else { return }
        
        self.shouldScrollToBottom = true
        dataSource.send(text: text, images: images)
        input.textView.text = nil
        input.adjustHeight()
    }
    
    private func setupCollectionView() {
        registerCells()
        collectionView.keyboardDismissMode = .interactive
        collectionView.showsVerticalScrollIndicator = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsSelection = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.autoresizingMask = UIViewAutoresizing()
        automaticallyAdjustsScrollViewInsets = false
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshNeeded), for: .valueChanged)
        collectionView.refreshControl = refresh
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
    }
    
    private func registerCells() {
        collectionView.register(ChatCell.nib, forCellWithReuseIdentifier: ChatCell.cellID)
        collectionView.register(ChatTextCell.self, forCellWithReuseIdentifier: "com.chat.text.cell")
        collectionView.register(ChatSeparatorCell.self, forCellWithReuseIdentifier: "com.chat.separator.cell")
        collectionView.register(ChatNewMessagesSeparatorCell.self, forCellWithReuseIdentifier: "com.chat.new.cell")
        collectionView.register(ChatHeader.self,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                withReuseIdentifier: "com.chat.header")
        collectionView.register(ChatFooter.nib,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                                withReuseIdentifier: ChatFooter.cellID)
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
    
    private func setupTapGestureRecognizer() {
        collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                   action: #selector(userDidTapOnCollectionView)))
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
    
    private func linkImage(name: String) {
        send(text: input.textView.text ?? "", images: [name])
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
        let identifier: String
        switch dataSource[indexPath] {
        case _ as ChatTextCellModel:
            identifier = "com.chat.text.cell"
        case _ as ChatSeparatorCellModel:
            identifier = "com.chat.separator.cell"
        case _ as ChatNewMessagesSeparatorModel:
            identifier = "com.chat.new.cell"
        default:
            fatalError("Unknown cell")
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let view: UICollectionReusableView
        if kind == UICollectionElementKindSectionHeader {
            view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                                   withReuseIdentifier: "com.chat.header",
                                                                   for: indexPath)
        } else {
            view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter,
                                                                   withReuseIdentifier: ChatFooter.cellID,
                                                                   for: indexPath)
        }
        return view
    }
    
}

// MARK: UICollectionViewDelegate
extension UniversalChatVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if indexPath.row > dataSource.count - dataSource.limit / 2 {
            dataSource.isLoadNextNeeded = true
        }
        
        let model = dataSource[indexPath]
        if let cell = cell as? ChatTextCell, let model = model as? ChatTextCellModel {
            let size = cloudSize(for: indexPath)
            cell.prepare(with: model, cloudWidth: size.width, cloudHeight: size.height)
            cell.avatarView.tag = indexPath.row
            cell.avatarTap.removeTarget(self, action: #selector(tapAvatar))
            cell.avatarTap.addTarget(self, action: #selector(tapAvatar))
            cell.onTapImage = { [weak self] cell, galleryView in
                guard let `self` = self else { return }
                
                galleryView.fullscreen(in: self, imageStrings: self.dataSource.allImages)
            }
        } else if let cell = cell as? ChatSeparatorCell, let model = model as? ChatSeparatorCellModel {
            cell.text = Formatter.teambrellaShort.string(from: model.date)
        } else if let cell = cell as? ChatNewMessagesSeparatorCell,
            let model = model as? ChatNewMessagesSeparatorModel {
            cell.label.text = model.text
            //cell.setNeedsUpdateConstraints()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        at indexPath: IndexPath) {
        if let view = view as? ChatFooter {
            var text = ""
            for user in typingUsers.keys {
                guard let date = typingUsers[user] else { continue }
                
                if Date().timeIntervalSince(date) < 3 {
                    if text != "" { text += ", " }
                    text += user.uppercased()
                } else {
                    typingUsers[user] = nil
                }
            }
            text += " "
            text += "Team.Chat.typing_format".localized(typingUsers.count).uppercased()
            view.label.text =  text
            view.hide(!showIsTyping)
        } else if let view = view as? ChatHeader {
            view.titleLabel.text = dataSource.chatHeader
            view.button.removeTarget(self, action: nil, for: .allEvents)
            view.button.addTarget(self, action: #selector(tapHeader), for: .touchUpInside)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout
extension UniversalChatVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch dataSource[indexPath] {
        case _ as ChatTextCellModel:
            let size = cloudSize(for: indexPath)
            return CGSize(width: collectionView.bounds.width, height: size.height)
        case _ as ChatSeparatorCellModel:
              return CGSize(width: collectionView.bounds.width, height: 30)
        case _ as ChatNewMessagesSeparatorModel:
            return CGSize(width: collectionView.bounds.width, height: 30)
        default:
            return CGSize(width: collectionView.bounds.width - 32, height: 100)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 30)
    }
}

// MARK: ImagePickerControllerDelegate
extension UniversalChatVC: ImagePickerControllerDelegate {
    func imagePicker(controller: ImagePickerController, didSendPhoto photo: String) {
        linkImage(name: photo)
    }
    
    func imagePicker(controller: ImagePickerController, didSelectPhoto photo: UIImage) {
        controller.send(image: photo)
        input.isHidden = false
    }
    
    func imagePicker(controller: ImagePickerController, willClosePickerByCancel cancel: Bool) {
        input.isHidden = false
    }
}
