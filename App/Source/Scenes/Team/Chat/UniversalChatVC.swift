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

final class UniversalChatVC: UIViewController, Routable {
    struct Constant {
        static let newMessagesSeparatorCellID = "com.chat.new.cell"
        static let dateSeparatorCellID = "com.chat.separator.cell"
        static let textWithImagesCellID = "com.chat.textWithImages.cell"
        static let textCellID = "com.chat.text.cell"
        static let singleImageCellID = "com.chat.image.cell"
    }
    
    static var storyboardName = "Chat"
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var slidingView: SlidingView!
    @IBOutlet var slidingViewHeight: NSLayoutConstraint!
    
    override var inputAccessoryView: UIView? { return input }
    override var canBecomeFirstResponder: Bool { return true }
    
    lazy var picker: ImagePickerController = { ImagePickerController(parent: self, delegate: self) }()
    
    var conversationID: String { return dataSource.topicID ?? dataSource.chatModel?.basic?.userID ?? "" }
    
    private let input: InputAccessoryView = InputAccessoryView()
    private let dataSource = UniversalChatDatasource()
    private var socketToken = "UniversalChat"
    private var lastTypingDate: Date = Date()
    private var typingUsers: [String: Date] = [:]
    
    private let scrollViewHandler: ScrollViewHandler = ScrollViewHandler()
    
    private var endsEditingWhenTappingOnChatBackground = true
    private var shouldScrollToBottom: Bool = false
    //  private var shouldScrollToBottomSilently: Bool = false
    
    var muteButton = UIButton()
    
    var keyboardTopY: CGFloat?
    var keyboardHeight: CGFloat {
        guard let top = self.keyboardTopY else { return 0 }
        
        return self.view.bounds.maxY - top
    }
    
    private var showIsTyping: Bool = false {
        didSet {
            collectionView.reloadData()
        }
    }
    private var cloudWidth: CGFloat { return collectionView.bounds.width * 0.75 }
    
    private var leftButton: UIButton?
    
    var router: MainRouter!
    var session: Session!
    var push: PushService!
    var socket: SocketService!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.accessibilityIdentifier = "UniversalChatCollectionView"
        addGradientNavBar()
        addMuteButton()
        setMuteButtonImage(type: dataSource.notificationsType)
        setupCollectionView()
        collectionView.refreshControl?.beginRefreshing()
        setupInput()
        setupTapGestureRecognizer()
        setupScrollHandler()
        dataSource.onUpdate = { [weak self] backward, hasNew, isFirstLoad in
            guard let `self` = self else { return }
            
            self.collectionView.refreshControl?.endRefreshing()
            self.setupActualObjectViewIfNeeded()
            self.setupTitle()
            self.setMuteButtonImage(type: self.dataSource.notificationsType)
            self.slidingView.votingView.setup(with: self.dataSource.chatModel)
            //            guard hasNew else {
            //                if isFirstLoad {
            //                    self.shouldScrollToBottom = true
            //                    self.dataSource.isLoadPreviousNeeded = true
            //                }
            //                return
            //            }
            self.refresh(backward: backward, isFirstLoad: isFirstLoad)
            self.input.allowInput(self.dataSource.isInputAllowed)
        }
        dataSource.onSendMessage = { [weak self] indexPath in
            guard let `self` = self else { return }
            
            self.shouldScrollToBottom = true
            self.refresh(backward: false, isFirstLoad: false)
            self.dataSource.loadNext()
        }
        dataSource.onClaimVoteUpdate = { [weak self] in
            guard let `self` = self else { return }
            guard let model = self.dataSource.chatModel else { return }
            
            self.slidingView.updateChatModel(model: model)
            self.collectionView.reloadData()
        }
        
        dataSource.isLoadNextNeeded = true
        
        title = ""
        let session = self.session
        slidingView.setupViews(with: self, session: session)
        slidingView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startListeningSockets()
        startListeningPushes()
        listenForKeyboard()
        setupTitle()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = CGSize(width: collectionView.bounds.width, height: 30)
            layout.footerReferenceSize = CGSize(width: collectionView.bounds.width, height: 30)
        }
        dataSource.cloudWidth = cloudWidth
        collectionView.contentInset.bottom = keyboardHeight + input.frame.height
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopListeningSockets()
        stopListeningPushes()
        stopListeningKeyboard()
        title = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        }
    }
    
    deinit {
        socket.remove(listener: socketToken)
    }
    
    // MARK: Public
    
    public func setContext(context: ChatContext, itemType: ItemType) {
        dataSource.addContext(context: context, itemType: itemType)
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
    
    // MARK: Callbacks
    
    @objc
    func tapLeftButton(sender: UIButton) {
        picker.showOptions()
    }
    
    @objc
    func tapRightButton(sender: UIButton) {
        guard let text = input.textView.text else { return }
        
        send(text: text, imageFragments: [])
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
            guard finalFrame.minY < collectionView.contentSize.height else { return }
            
            keyboardTopY = finalFrame.minY
            let diff = initialFrame.minY - finalFrame.minY
            offset.y += diff
            collectionView.contentOffset = offset
            collectionView.contentInset.bottom = keyboardHeight
        }
    }
    
    @objc
    func tapAvatar(sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        
        let indexPath = IndexPath(row: view.tag, section: 0)
        if let model = dataSource[indexPath] as? ChatCellUserDataLike {
            let userID = model.entity.userID
            router.presentMemberProfile(teammateID: userID, teamID: nil)
        }
    }
    
    @objc
    private func tapMuteButton(sender: UIButton) {
        router.showNotificationFilter(in: self, delegate: self, currentState: dataSource.notificationsType)
        
    }
    
}

// MARK: Private
private extension UniversalChatVC {
    private func setupScrollHandler() {
        scrollViewHandler.onScrollingUp = {
            self.slidingView.hideAll()
        }
        
        scrollViewHandler.onScrollingDown = {
            if self.dataSource.chatModel != nil {
                self.showObject()
            }
        }
    }
    
    private func showObject() {
        guard dataSource.isObjectViewNeeded == true else { return }
        
        slidingView.showObjectView()
    }
    
    private func showMuteInfo(muteType: TopicMuteType) {
        let cloudView = CloudView()
        self.view.addSubview(cloudView)
        let rightCloudOffset: CGFloat = 8
        let peekX: CGFloat = muteButton.convert(self.muteButton.frame, to: nil).midX
        cloudView.rightPeekOffset = self.view.bounds.maxX - peekX - rightCloudOffset
        // add constraints
        cloudView.translatesAutoresizingMaskIntoConstraints = false
        cloudView.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.leadingAnchor, constant: 8).isActive = true
        cloudView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,
                                            constant: -rightCloudOffset).isActive = true
        cloudView.topAnchor.constraint(equalTo: self.view.topAnchor,
                                       constant: 3 + collectionView.frame.minY).isActive = true
        cloudView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 0, alpha: 0)
        cloudView.alpha = 0
        if muteType == .unmuted {
            cloudView.title = "Team.Chat.Unmute".localized
        } else {
            cloudView.title = "Team.Chat.Mute".localized
        }
        cloudView.appear()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            cloudView.disappear {
                cloudView.removeFromSuperview()
            }
        }
    }
    
    private func setupTitle() {
        title = dataSource.title
    }
    
    private func setupCollectionView() {
        registerCells()
        collectionView.keyboardDismissMode = .interactive
        collectionView.showsVerticalScrollIndicator = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsSelection = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.autoresizingMask = UIViewAutoresizing()
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshNeeded), for: .valueChanged)
        collectionView.refreshControl = refresh
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
    }
    
    private func addMuteButton() {
        let button = UIButton()
        let barItem = UIBarButtonItem(customView: button)
        button.addTarget(self, action: #selector(tapMuteButton), for: .touchUpInside)
        self.muteButton = button
        navigationItem.setRightBarButton(barItem, animated: true)
    }
    
    private func setMuteButtonImage(type: TopicMuteType) {
        guard dataSource.chatType != .privateChat else {
            muteButton.isEnabled = false
            muteButton.isHidden = true
            return
        }
        
        let image: UIImage
        if  type == .muted {
            image = #imageLiteral(resourceName: "iconBellMuted1")
        } else {
            image = #imageLiteral(resourceName: "iconBell1")
        }
        muteButton.setImage(image, for: .normal)
    }
    
    private func registerCells() {
        collectionView.register(ChatVariousContentCell.self,
                                forCellWithReuseIdentifier: Constant.textWithImagesCellID)
        collectionView.register(ChatTextCell.self,
                                forCellWithReuseIdentifier: Constant.textCellID)
        collectionView.register(ChatImageCell.self,
                                forCellWithReuseIdentifier: Constant.singleImageCellID)
        collectionView.register(ChatSeparatorCell.self,
                                forCellWithReuseIdentifier: Constant.dateSeparatorCellID)
        collectionView.register(ChatNewMessagesSeparatorCell.self,
                                forCellWithReuseIdentifier: Constant.newMessagesSeparatorCellID)
        collectionView.register(ChatFooter.nib,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                                withReuseIdentifier: ChatFooter.cellID)
        collectionView.register(ChatClaimPaidCell.nib,
                                forCellWithReuseIdentifier: ChatClaimPaidCell.cellID)
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
    
    /**
     * Refresh controller after new data comes from the server
     *
     * - Parameter backward: wether the chunk of data comes above existing cells or below them
     */
    private func refresh(backward: Bool, isFirstLoad: Bool) {
        collectionView.reloadData()
        if isFirstLoad, let lastReadIndexPath = dataSource.lastReadIndexPath {
            self.collectionView.scrollToItem(at: lastReadIndexPath, at: .top, animated: true)
        } else if self.shouldScrollToBottom {
            self.scrollToBottom(animated: true)
            self.shouldScrollToBottom = false
        } else if backward, let indexPath = self.dataSource.currentTopCellPath {
            self.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
        }
    }
    
    private func cloudSize(for indexPath: IndexPath) -> CGSize {
        if let model = dataSource[indexPath] as? ChatTextCellModel {
            let textInset = ChatVariousContentCell.Constant.textInset
            let minimalFragmentWidth: CGFloat = 50
            let fragmentWidth = max(model.maxFragmentsWidth,
                                    minimalFragmentWidth)
            let calculator = TextSizeCalculator()
            let rightLabelWidth = calculator.size(for: model.rateText ?? "",
                                                  font: ChatVariousContentCell.Constant.leftLabelFont,
                                                  maxWidth: cloudWidth).width
            let leftLabelWidth = calculator.size(for: model.userName.entire,
                                                 font: ChatVariousContentCell.Constant.leftLabelFont,
                                                 maxWidth: cloudWidth - rightLabelWidth).width
            
            let width = max(fragmentWidth + textInset * 2,
                            rightLabelWidth + leftLabelWidth + textInset * 3)
            
            let verticalInset = verticalInsetForCloud(with: model)
            return CGSize(width: width,
                          height: model.totalFragmentsHeight + CGFloat(model.fragments.count) * 2 + verticalInset)
        } else if let model = dataSource[indexPath] as? ChatImageCellModel {
            return CGSize(width: model.maxFragmentsWidth + ChatImageCell.Constant.imageInset * 2,
                          height: model.totalFragmentsHeight + ChatImageCell.Constant.imageInset * 2)
        } else {
            return .zero
        }
    }
    
    private func verticalInsetForCloud(with model: ChatTextCellModel) -> CGFloat {
        if model.isSingleText {
            if dataSource.isPrivateChat {
                return ChatTextCell.Constant.auxillaryLabelHeight
                    + ChatTextCell.Constant.labelToTextVerticalInset * 2
            } else {
                return ChatTextCell.Constant.auxillaryLabelHeight * 2
                    + ChatTextCell.Constant.labelToTextVerticalInset * 2
            }
        } else {
            return ChatVariousContentCell.Constant.auxillaryLabelHeight * 2
                + ChatVariousContentCell.Constant.textInset
                + ChatVariousContentCell.Constant.timeInset
        }
    }
    
    private func processIsTyping(action: SocketAction) {
        guard case let .theyTyping(_, _, _, name) = action.data else { return }
        
        showIsTyping = true
        typingUsers[name] = Date()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let `self` = self else { return }
            
            if Date().timeIntervalSince(self.lastTypingDate) > 3.0 {
                self.showIsTyping = false
                self.typingUsers.removeAll()
            }
        }
    }
    
    private func setupInput() {
        ViewDecorator.shadow(for: input, color: #colorLiteral(red: 0.231372549, green: 0.2588235294, blue: 0.4901960784, alpha: 1), opacity: 0.05, radius: 8, offset: CGSize(width: 0, height: -9))
        if dataSource.isPrivateChat {
            input.leftButton.setImage(#imageLiteral(resourceName: "crossIcon"), for: .normal)
            input.leftButton.isHidden = true
            input.leftButton.isEnabled = false
        }
        input.leftButton.addTarget(self, action: #selector(tapLeftButton), for: .touchUpInside)
        input.rightButton.addTarget(self, action: #selector(tapRightButton), for: .touchUpInside)
        input.onBeginEdit = { [weak self] in
            guard let `self` = self else { return }
            
            if self.dataSource.removeNewMessagesSeparator() {
                self.collectionView.reloadData()
            }
        }
        
        if let socket = socket,
            let teamID = session.currentTeam?.teamID {
            input.onTextChange = { [weak socket, weak self] in
                guard let me = self else { return }
                
                let interval = me.lastTypingDate.timeIntervalSinceNow
                if interval < -2.0, let topicID = me.dataSource.topicID,
                    let name = self?.session.currentUserName {
                    socket?.meTyping(teamID: teamID, topicID: topicID, name: name.first)
                    self?.lastTypingDate = Date()
                }
            }
        }
        input.allowInput(dataSource.isInputAllowed)
    }
    
    private func startListeningSockets() {
        socket.add(listener: socketToken, action: { [weak self] action in
            log("add command \(action.command)", type: .socket)
            switch action.command {
            case .theyTyping, .meTyping:
                self?.processIsTyping(action: action)
            case .privateMessage,
                 .newPost:
                print("received message, loading new data")
                self?.loadNewMessages()
            default:
                print("unsupported command: \(action.command)")
            }
        })
    }
    
    private func loadNewMessages() {
        showIsTyping = false
        dataSource.hasNext = true
        shouldScrollToBottom = true
        dataSource.loadNext()
    }
    
    private func stopListeningSockets() {
        socket.remove(listener: self)
    }
    
    private func startListeningPushes() {
        push.addListener(self) { [weak self] type, payload -> Bool in
            guard let `self` = self else { return true }
            
            switch type {
            case .topicMessage,
                 .privateMessage:
                let conversationID = payload["TopicId"] as? String ?? payload["UserId"] as? String ?? ""
                if self.conversationID == conversationID {
                    print("No need to show chat Push as chat is already opened")
                    self.loadNewMessages()
                    return false
                }
            default:
                break
            }
            //             self.loadNewMessages()
            return true
        }
    }
    
    private func stopListeningPushes() {
        push.removeListener(self)
    }
    
    private func send(text: String, imageFragments: [ChatFragment]) {
        guard dataSource.isLoading == false else { return }
        
        self.shouldScrollToBottom = true
        dataSource.send(text: text, imageFragments: imageFragments)
        input.textView.text = nil
        input.adjustHeight()
        
        if dataSource.notificationsType == .unknown && dataSource.chatType != .privateChat {
            let type: TopicMuteType = .unmuted
            dataSource.mute(type: type, completion: { [weak self] muted in
                self?.showMuteInfo(muteType: type)
                self?.setMuteButtonImage(type: type)
            })
        }
    }
    
    private func setupActualObjectViewIfNeeded() {
        if dataSource.isObjectViewNeeded {
            slidingView.showObjectView()
        } else {
            slidingView.hideObjectView()
        }
        if let model = dataSource.chatModel {
            slidingView.updateChatModel(model: model)
        }
    }
    
    private func linkImage(image: UIImage, name: String) {
        let fragment = ChatFragment.imageFragment(image: image, urlString: name, urlStringSmall: "")
        send(text: input.textView.text ?? "", imageFragments: [fragment])
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
        case let model as ChatTextCellModel:
            if model.fragments.count == 1, let fragment = model.fragments.first, case .text = fragment {
                identifier = Constant.textCellID
            } else {
                identifier = Constant.textWithImagesCellID
            }
        case _ as ChatImageCellModel:
            identifier = Constant.singleImageCellID
        case _ as ChatSeparatorCellModel:
            identifier = Constant.dateSeparatorCellID
        case _ as ChatNewMessagesSeparatorModel:
            identifier = Constant.newMessagesSeparatorCellID
        case _ as ChatClaimPaidCellModel:
            identifier = ChatClaimPaidCell.cellID
        case _ as ChatPayToJoinCellModel:
            identifier = ChatClaimPaidCell.cellID
        default:
            fatalError("Unknown cell")
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter,
                                                                   withReuseIdentifier: ChatFooter.cellID,
                                                                   for: indexPath)
        return view
    }
    
}

// MARK: UICollectionViewDelegate
extension UniversalChatVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if indexPath.row == dataSource.count - 1 {
            dataSource.isLoadNextNeeded = true
        }
        
        let model = dataSource[indexPath]
        switch model {
        case let model as ChatCellUserDataLike:
            populateUserData(cell: cell, indexPath: indexPath, model: model)
        default:
            populateService(cell: cell, model: model)
        }
    }
    
    private func populateUserData(cell: UICollectionViewCell, indexPath: IndexPath, model: ChatCellUserDataLike) {
        if let cell = cell as? ChatVariousContentCell {
            cell.prepare(with: model,
                         myVote: dataSource.myVote,
                         type: dataSource.chatType,
                         size: cloudSize(for: indexPath))
            cell.avatarView.tag = indexPath.row
            cell.avatarTap.removeTarget(self, action: #selector(tapAvatar))
            cell.avatarTap.addTarget(self, action: #selector(tapAvatar))
            cell.onTapImage = { [weak self] cell, galleryView in
                guard let `self` = self else { return }
                
                galleryView.fullscreen(in: self, imageStrings: self.dataSource.allImages)
            }
        } else if let cell = cell as? ChatTextCell {
            cell.prepare(with: model,
                         myVote: dataSource.myVote,
                         type: dataSource.chatType,
                         size: cloudSize(for: indexPath))
            cell.avatarView.tag = indexPath.row
            cell.avatarTap.removeTarget(self, action: #selector(tapAvatar))
            cell.avatarTap.addTarget(self, action: #selector(tapAvatar))
            cell.onTapImage = { [weak self] cell, galleryView in
                guard let `self` = self else { return }
                
                galleryView.fullscreen(in: self, imageStrings: self.dataSource.allImages)
            }
        } else if let cell = cell as? ChatImageCell {
            cell.prepare(with: model, size: cloudSize(for: indexPath))
            cell.avatarView.tag = indexPath.row
            cell.avatarTap.removeTarget(self, action: #selector(tapAvatar))
            cell.avatarTap.addTarget(self, action: #selector(tapAvatar))
            cell.onTapImage = { [weak self] cell, galleryView in
                guard let `self` = self else { return }
                
                galleryView.fullscreen(in: self, imageStrings: self.dataSource.allImages)
            }
        }
    }
    
    func populateService(cell: UICollectionViewCell, model: ChatCellModel) {
        if let cell = cell as? ChatSeparatorCell, let model = model as? ChatSeparatorCellModel {
            cell.text = DateProcessor().yearFilter(from: model.date)
        } else if let cell = cell as? ChatSeparatorCell, let model = model as? ChatSeparatorCellModel {
            cell.text = DateProcessor().yearFilter(from: model.date)
        } else if let cell = cell as? ChatNewMessagesSeparatorCell,
            let model = model as? ChatNewMessagesSeparatorModel {
            cell.setNeedsDisplay()
            cell.label.text = model.text
        } else if let cell = cell as? ChatClaimPaidCell {
            let model = model as? ChatModel
            if model?.basic?.datePayToJoin != nil {
                cell.messageLabel.text = "Team.Chat.PayToJoin.text".localized
                cell.button.setTitle("Team.Chat.PayToJoin.buttonTitle".localized, for: .normal)
                cell.confettiView.isHidden = true
                cell.onButtonTap = { [weak self] in
                    log("tap fund wallet (from chat)", type: .userInteraction)
                    self?.router.switchToWallet() // check this
                }
            } else {
                cell.messageLabel.text = "Team.Chat.ClaimPaidCell.text".localized
                cell.button.setTitle("Team.Chat.ClaimPaidCell.buttonTitle".localized, for: .normal)
                cell.onButtonTap = { [weak self] in
                    guard let model = self?.dataSource.chatModel,
                        let claimID = model.basic?.claimID,
                        let team = model.team else { return }

                    let urlText = URLBuilder().urlString(claimID: claimID, teamID: team.teamID)
                    let messageText = CoverageLocalizer(type: team.coverageType).paidClaimText()
                    let combinedText = "\(messageText)\n\(urlText)"
                    let vc = UIActivityViewController(activityItems: [combinedText], applicationActivities: [])
                    self?.present(vc, animated: true)
                }
            }
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
                
                if Date().timeIntervalSince(date) < 3.0 {
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
        case _ as ChatImageCellModel:
            let size = cloudSize(for: indexPath)
            return CGSize(width: collectionView.bounds.width, height: size.height)
        case _ as ChatSeparatorCellModel:
            return CGSize(width: collectionView.bounds.width, height: 30)
        case _ as ChatNewMessagesSeparatorModel:
            return CGSize(width: collectionView.bounds.width, height: 30)
        case _ as ChatClaimPaidCellModel:
            return CGSize(width: collectionView.bounds.width, height: 135)
        case _ as ChatPayToJoinCellModel:
            return CGSize(width: collectionView.bounds.width, height: 135)
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
    func imagePicker(controller: ImagePickerController, didSendImage image: UIImage, urlString: String) {
        linkImage(image: image, name: urlString)
    }
    
    func imagePicker(controller: ImagePickerController, didSelectImage image: UIImage) {
        controller.send(image: image)
        
    }
    
    func imagePicker(controller: ImagePickerController, willClosePickerByCancel cancel: Bool) {
        
    }
}

// MARK: UIViewControllerPreviewingDelegate
extension UniversalChatVC: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                           commit viewControllerToCommit: UIViewController) {
        router.push(vc: viewControllerToCommit, animated: true)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                           viewControllerForLocation location: CGPoint) -> UIViewController? {
        let updatedLocation = view.convert(location, to: collectionView)
        guard let indexPath = collectionView?.indexPathForItem(at: updatedLocation) else { return nil }
        guard let cell = collectionView?.cellForItem(at: indexPath) as? ChatVariousContentCell else { return nil }
        
        let cellLocation = collectionView.convert(updatedLocation, to: cell.avatarView)
        guard cell.avatarView.point(inside: cellLocation, with: nil) else { return nil }
        guard let model = dataSource[indexPath] as? ChatTextCellModel else { return nil }
        guard let vc = router.getControllerMemberProfile(teammateID: model.entity.userID, teamID: nil) else {
            return nil
        }
        
        vc.preferredContentSize = CGSize(width: view.bounds.width * 0.9, height: view.bounds.height * 0.9)
        previewingContext.sourceRect = collectionView.convert(cell.frame, to: view)
        vc.isPeeking = true
        return vc
    }
}

// MARK: MuteControllerDelegate
extension UniversalChatVC: MuteControllerDelegate {
    func mute(controller: MuteVC, didSelect type: TopicMuteType) {
        dataSource.mute(type: type) { [weak self] success in
            self?.setMuteButtonImage(type: type)
        }
    }
    
    func didCloseMuteController(controller: MuteVC) {
        
    }
}

// MARK: ClaimVotingDelegate
extension UniversalChatVC: ClaimVotingDelegate {
    func claimVoting(view: ClaimVotingView, finishedSliding slider: UISlider) {
        dataSource.updateVoteOnServer(vote: slider.value)
    }
    
    func claimVotingDidResetVote(view: ClaimVotingView) {
        dataSource.updateVoteOnServer(vote: nil)
    }
    
    func claimVotingDidTapTeam(view: ClaimVotingView) {
        guard let model = dataSource.chatModel else { return }
        guard let teamID = model.team?.teamID, let claimID = model.basic?.claimID else { return }
        
        router.presentOthersVoted(teamID: teamID, teammateID: nil, claimID: claimID)
    }
}

// MARK: ChatObjectViewDelegate
extension  UniversalChatVC: ChatObjectViewDelegate {
    func chatObject(view: ChatObjectView, didTap button: UIButton) {
        print("tap \(button)")
        switch button {
        case view.rightButton:
            if let model = dataSource.chatModel, model.isClaimChat {
                self.slidingView.showVotingView()
            } else if let userID = dataSource.chatModel?.basic?.userID {
                router.presentMemberProfile(teammateID: userID, scrollToVote: true)
            }
        case view.chevronButton:
            self.slidingView.hideVotingView()
        default:
            break
        }
    }
    
    func chatObjectWasTapped(view: ChatObjectView) {
        if let model = dataSource.chatModel, model.isClaimChat, let id = model.id {
            router.presentClaim(claimID: id)
        } else if let userID = dataSource.chatModel?.basic?.userID {
            router.presentMemberProfile(teammateID: userID,
                                        teamID: dataSource.chatModel?.team?.teamID,
                                        scrollToVote: true)
        }
    }
}

// MARK: UIScrollViewDelegate
extension UniversalChatVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewHandler.scrollViewDidScroll(scrollView)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollViewHandler.scrollViewWillBeginDragging(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollViewHandler.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }
}

// MARK: SlidingViewDelegate
extension UniversalChatVC: SlidingViewDelegate {
    func sliding(view: SlidingView, changeContentHeight height: CGFloat) {
        slidingViewHeight.constant = height
        var inset = collectionView.contentInset
        inset.top = height
        collectionView.contentInset = inset
        UIView.animate(withDuration: 0.3) {
            self.slidingView.layoutIfNeeded()
        }
    }
}
