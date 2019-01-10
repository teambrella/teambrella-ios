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

// swiftlint:disable file_length
final class UniversalChatVC: UIViewController, Routable {
    struct Constant {
        static let newMessagesSeparatorCellID = "com.chat.new.cell"
        static let dateSeparatorCellID = "com.chat.separator.cell"
        static let textWithImagesCellID = "com.chat.textWithImages.cell"
        static let textCellID = "com.chat.text.cell"
        static let singleImageCellID = "com.chat.image.cell"
        static let serviceCellID = "com.chat.service.cell"
    }
    
    static var storyboardName = "Chat"
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var slidingView: SlidingView!
    @IBOutlet var slidingViewHeight: NSLayoutConstraint!
    
    override var inputAccessoryView: UIView? { return input }
    override var canBecomeFirstResponder: Bool { return true }
    
    lazy var picker: ImagePickerController = { ImagePickerController(parent: self, delegate: self) }()
    lazy var internalPhotoPicker: ImagePickerController = {
        let picker = ImagePickerController(parent: self, delegate: self)
        return picker
    }()
    
    var conversationID: String {
        if dataSource.isPrivateChat {
            return dataSource.chatModel?.basic?.userID ?? ""
        } else {
            return dataSource.topicID ?? ""
        }
    }
    
    let dataSource = UniversalChatDatasource()
    
    private let input: InputAccessoryView = InputAccessoryView()
    private var socketToken = "UniversalChat"
    private var lastTypingDate: Date = Date()
    private var typingUsers: [String: Date] = [:]
    
    private let scrollViewHandler: ScrollViewHandler = ScrollViewHandler()
    
    private var endsEditingWhenTappingOnChatBackground = true
    private var isScrollToBottomNeeded: Bool = false
    
    var muteButton = UIButton()
    var pinButton = UIButton()
    
    var keyboardTopY: CGFloat?
    var keyboardHeight: CGFloat {
        guard let top = self.keyboardTopY else { return 0 }
        
        return self.view.bounds.maxY - top
    }
    var pinDataSource = PinDataSource()
    var pinState: PinType = .unknown {
        didSet {
            let image: UIImage
            switch pinDataSource.teamPinType {
            case .unpinned:
                image = #imageLiteral(resourceName: "PinIconRed").withRenderingMode(.alwaysTemplate)
            default:
                image = #imageLiteral(resourceName: "PinIconGrey")
            }
            pinButton.tintColor = UIColor.navigationButtonGray
            pinButton.setImage(image, for: .normal)
        }
    }
    
    var postActionsDataSource: PostActionsDataSource? = nil
    
    private var showIsTyping: Bool = false {
        didSet {
            collectionView.reloadData()
        }
    }
    private var cloudWidth: CGFloat { return collectionView.bounds.width * 0.75 }
    
    private var leftButton: UIButton?
    
    var router: MainRouter { return service.router }
    var session: Session? { return service.session }
    var push: PushService { return service.push }
    var socket: SocketService? { return service.socket }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.accessibilityIdentifier = "UniversalChatCollectionView"
        addGradientNavBar()
        addTopButtons()
        setMuteButtonImage(type: dataSource.notificationsType)
        setPinButtonImage()
        setupCollectionView()
        collectionView.refreshControl?.beginRefreshing()
        setupInput()
        setupTapGestureRecognizer()
        setupScrollHandler()
        dataSource.onUpdate = { [weak self] backward, hasNew, isFirstLoad in
            guard let self = self else { return }
            
            self.collectionView.refreshControl?.endRefreshing()
            self.setupActualObjectViewIfNeeded()
            self.setupTitle()
            self.setMuteButtonImage(type: self.dataSource.notificationsType)
            self.updateSlidingView()
            self.refresh(backward: backward, isFirstLoad: isFirstLoad)
            self.input.isUserInteractionEnabled = self.dataSource.isInputAllowed
            self.input.allowInput(self.dataSource.isInputAllowed)
            if self.dataSource.isPrejoining || self.dataSource.isPrivateChat {
                self.input.hideLeftButton()
            }
            self.pinButton.isHidden = !self.dataSource.isInputAllowed
        }
        dataSource.onSendMessage = { [weak self] indexPath in
            guard let `self` = self else { return }
            
            //            self.isScrollToBottomNeeded = true
            //            self.refresh(backward: false, isFirstLoad: false)
            self.isScrollToBottomNeeded = true
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
    
    func updateSlidingView() {
        if dataSource.isObjectViewNeeded {
            slidingView.isHidden = false
            slidingView.votingView.setup(with: dataSource.chatModel)
        } else {
            slidingView.isHidden = true
        }
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
        rememberMessage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopListeningSockets()
        stopListeningPushes()
        stopListeningKeyboard()
        memoriseMessage()
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
        socket?.remove(listener: socketToken)
    }
    
    // MARK: Public
    
    public func setContext(context: UniversalChatContext) {
        dataSource.addContext(context: context)
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

    func delete(_ cell: ChatImageCell) {
        dataSource.deleteMessage(id: cell.id) { [weak self] error in
            if let error = error {
                print("Error deleting cell \(cell.id): \(error)")
            } else {
                print("Successfully deleted cell id: \(cell.id)")
                self?.collectionView.reloadData()
            }
        }
    }

    func sizeForServiceMessage(model: ServiceMessageCellModel) -> CGSize {
        var size = model.size
        size.height += 16
        size.width += 16
        return size
    }

    func sizeForServiceMessageWithButton(model: ServiceMessageWithButtonCellModel) -> CGSize {
        var size = model.size
        size.height += (50 + 32)
        size.width = collectionView.bounds.width
        return size
    }
    
    // MARK: Callbacks
    
    @objc
    func tapLeftButton(sender: UIButton) {
        picker.showOptions()
    }
    
    @objc
    func userDidTapOnCollectionView() {
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
        // TODO: commenting this out as a quick fix for correct handing of SelectorVC
        
//        if let finalFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
//            let initialFrame = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?
//                .cgRectValue {
//            var offset =  collectionView.contentOffset
//            guard finalFrame.minY < collectionView.contentSize.height else { return }
//
//            keyboardTopY = finalFrame.minY
//            let diff = initialFrame.minY - finalFrame.minY
//            offset.y += diff
//            collectionView.contentOffset = offset
//            collectionView.contentInset.bottom = keyboardHeight
//        }
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
        router.showMuteSelector(in: self, delegate: self, currentState: dataSource.notificationsType)
    }
    
    @objc
    func tapPinButton(_ sender: UIButton) {
        router.showPinSelector(in: self,
                               delegate: self,
                               datasource: pinDataSource,
                               currentState: pinState)
    }
    
    func showCommandList(model: ChatCellUserDataLike) {
        postActionsDataSource = PostActionsDataSource(model: model)
        router.showPostActionsSelector(in: self,
                               delegate: self,
                               dataSource: postActionsDataSource!,
                               currentState: PostActionType(rawValue: model.myLike) ?? .unknown)
    }

    var unsentImages: [String: UIImage] = [:]

    func cloudSize(for indexPath: IndexPath) -> CGSize {
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
            return cloudSizeForImage(width: model.maxFragmentsWidth, height: model.totalFragmentsHeight)
        } else if let model = dataSource[indexPath] as? ChatUnsentImageCellModel {
            return cloudSizeForUnsentImage(id: model.id)
        } else {
            return .zero
        }
    }

    func cloudSizeForUnsentImage(id: String) -> CGSize {
        guard let image = unsentImages[id] else { return .zero }

        let ratio = image.size.height / image.size.width
        let width = dataSource.cellModelBuilder.width
        let height: CGFloat = ratio * width
        return cloudSizeForImage(width: width, height: height)
    }

    func cloudSizeForImage(width: CGFloat, height: CGFloat) -> CGSize {
        return CGSize(width: width + ChatImageCell.Constant.imageInset * 2,
                      height: height + ChatImageCell.Constant.imageInset * 2)
    }

    func showAddPhoto() {
        internalPhotoPicker.chatMetadata = dataSource.newPhotoMeta()
        internalPhotoPicker.showOptions()
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
    
    private func showMuteInfo(muteType: MuteType) {
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
        collectionView.autoresizingMask = UIView.AutoresizingMask()
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
    
    private func addTopButtons() {
        guard dataSource.chatType != .privateChat else {
            return
        }

        muteButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        muteButton.addTarget(self, action: #selector(tapMuteButton), for: .touchUpInside)
        
        pinButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        pinButton.addTarget(self, action: #selector(tapPinButton), for: .touchUpInside)
        navigationItem.setRightBarButtonItems([UIBarButtonItem(customView: muteButton),
                                               UIBarButtonItem(customView: pinButton)], animated: false)
    }
    
    private func setMuteButtonImage(type: MuteType) {
        let image: UIImage
        if  type == .muted {
            image = #imageLiteral(resourceName: "iconBellMuted1")
        } else {
            image = #imageLiteral(resourceName: "iconBell1")
        }
        muteButton.setImage(image, for: .normal)
    }
    
    private func setPinButtonImage() {
        guard let topicID = dataSource.topicID else { return }
        
        pinDataSource.getModels(topicID: topicID) { [weak self] state in
            self?.pinState = state
        }
        let image: UIImage = #imageLiteral(resourceName: "PinIconGrey")
        pinButton.setImage(image, for: .normal)
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
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: ChatFooter.cellID)
        collectionView.register(ChatClaimPaidCell.nib,
                                forCellWithReuseIdentifier: ChatClaimPaidCell.cellID)
        collectionView.register(ServiceChatCell.nib, forCellWithReuseIdentifier: ServiceChatCell.cellID)

        collectionView.register(ChatServiceTextCell.self, forCellWithReuseIdentifier: Constant.serviceCellID)
    }
    
    private func listenForKeyboard() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChangeFrame),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    
    private func stopListeningKeyboard() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillChangeFrameNotification,
                                                  object: nil)
    }
    
    private func setupTapGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(userDidTapOnCollectionView))
        tap.cancelsTouchesInView = false
        collectionView.addGestureRecognizer(tap)
    }
    
    /**
     * Refresh controller after new data comes from the server
     *
     * - Parameter backward: wether the chunk of data comes above existing cells or below them
     */
    private func refresh(backward: Bool, isFirstLoad: Bool) {
        collectionView.reloadData()
        DispatchQueue.main.async {
            if isFirstLoad, let lastReadIndexPath = self.dataSource.lastReadIndexPath {
                guard lastReadIndexPath.row < self.dataSource.count else { return }

                self.collectionView.scrollToItem(at: lastReadIndexPath, at: .top, animated: true)
            } else if self.isScrollToBottomNeeded {
                self.scrollToBottom(animated: true)
                self.isScrollToBottomNeeded = false
            } else if backward, let indexPath = self.dataSource.currentTopCellPath {
                guard indexPath.row < self.dataSource.count else { return }

                self.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
            }
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

    // swiftlint:disable:next cyclomatic_complexity
    private func setupInput() {
        input.isUserInteractionEnabled = false
        ViewDecorator.shadow(for: input, color: #colorLiteral(red: 0.231372549, green: 0.2588235294, blue: 0.4901960784, alpha: 1), opacity: 0.05, radius: 8, offset: CGSize(width: 0, height: -9))
        if dataSource.isPrivateChat || dataSource.isPrejoining {
            input.hideLeftButton()
        }
        input.leftButton.addTarget(self, action: #selector(tapLeftButton), for: .touchUpInside)
        input.onTapSend = { [weak self] in
            guard let self = self else { return }
            guard let text = self.input.textView.text, text != "" else { return }

            self.send(text: text, imageFragments: [])
        }
        input.onTapPhoto = { [weak self] in
            self?.showAddPhoto()
        }
        input.onBeginEdit = { [weak self] in
            guard let self = self else { return }
            
            if self.dataSource.removeNewMessagesSeparator() {
                self.collectionView.reloadData()
            }
            if !self.input.isEmpty {
                self.input.showRightButtonSend()
            }
        }
        input.onEndEditing = { [weak self] text in
            guard let self = self else { return }

            if (text != nil && text != "") || self.dataSource.isPrivateChat {
                self.input.showRightButtonSend()
            } else {
                self.input.showRightButtonPhoto()
            }
        }

        input.onTextChanged = { [weak self] text in
            guard let self = self else { return }

            if text.isEmpty && !self.dataSource.isPrivateChat {
                self.input.showRightButtonPhoto()
            } else {
                self.input.showRightButtonSend()
            }
        }
        if dataSource.isPrivateChat {
            input.showRightButtonSend()
        } else {
            input.showRightButtonPhoto()
        }
        
        if let socket = socket,
            let teamID = session?.currentTeam?.teamID {
            input.onTextChange = { [weak socket, weak self] in
                guard let me = self else { return }
                
                let interval = me.lastTypingDate.timeIntervalSinceNow
                if interval < -2.0, let topicID = me.dataSource.topicID,
                    let name = self?.session?.currentUserName {
                    socket?.meTyping(teamID: teamID, topicID: topicID, name: name.first)
                    self?.lastTypingDate = Date()
                }
            }
        }
        input.allowInput(dataSource.isInputAllowed)
    }
    
    private func startListeningSockets() {
        socket?.add(listener: socketToken, action: { [weak self] action in
            log("add command \(action.command)", type: .socket)
            switch action.command {
            case .theyTyping, .meTyping:
                self?.processIsTyping(action: action)
            case .privateMessage,
                 .newPost:
                log("received message, loading new data", type: .socket)
                self?.loadNewMessages()
            default:
                log("unsupported command: \(action.command)", type: .socket)
            }
        })
    }
    
    private func loadNewMessages() {
        showIsTyping = false
        dataSource.hasNext = true
        isScrollToBottomNeeded = true
        dataSource.loadNext()
    }
    
    private func stopListeningSockets() {
        socket?.remove(listener: self)
    }
    
    private func startListeningPushes() {
        push.addListener(self) { [weak self] type, payload -> Bool in
            guard let `self` = self else { return true }
            
            switch type {
            case .topicMessage,
                 .privateMessage:
                let conversationID = payload["TopicId"] as? String ?? payload["UserId"] as? String ?? ""
                if self.conversationID == conversationID {
                    log("No need to show chat Push as chat is already opened", type: .push)
                    self.loadNewMessages()
                    return false
                }
            default:
                break
            }
            return true
        }
    }
    
    private func stopListeningPushes() {
        push.removeListener(self)
    }
    
    private func send(text: String, imageFragments: [ChatFragment]) {
        guard dataSource.isLoading == false else { return }
        
        self.isScrollToBottomNeeded = true
        dataSource.send(text: text, imageFragments: imageFragments)
        forgetMessage()
        input.adjustHeight()
        if !dataSource.isPrivateChat {
            input.showRightButtonPhoto()
        }
        
        if dataSource.notificationsType == .unknown && dataSource.chatType != .privateChat {
            let type: MuteType = .unmuted
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
    
    private func memoriseMessage() {
        guard let session = service.session else { return }
        guard let text = input.textView.text else { return }
        
        session.draftMessages[conversationID] = text
    }
    
    private func rememberMessage() {
        guard let session = service.session else { return }
        guard let text = session.draftMessages[conversationID] else { return }
        
        let textView = input.textView
        textView.text = nil
        textView.insertText(text)
        input.placeholderLabel.isHidden = true
    }
    
    private func forgetMessage() {
        guard let session = service.session else { return }
        
        input.textView.text = nil
        session.draftMessages[conversationID] = nil
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
        case _ as ChatUnsentImageCellModel:
            identifier = Constant.singleImageCellID
        case _ as ChatSeparatorCellModel:
            identifier = Constant.dateSeparatorCellID
        case _ as ChatNewMessagesSeparatorModel:
            identifier = Constant.newMessagesSeparatorCellID
        case _ as ChatClaimPaidCellModel:
            identifier = ChatClaimPaidCell.cellID
        case _ as ServiceMessageCellModel:
            identifier = Constant.serviceCellID
        case _ as ServiceMessageWithButtonCellModel:
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
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter,
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
            ChatCellBuilder.populateUserData(cell: cell, controller: self, indexPath: indexPath, model: model)
        case let model as ChatUnsentImageCellModel:
            ChatCellBuilder.populateUnsent(cell: cell, controller: self, indexPath: indexPath, model: model)
        default:
            ChatCellBuilder.populateService(cell: cell, controller: self, model: model)
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

    //    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    //         let model = dataSource[indexPath]
    //        switch model {
    //        case let model as ServiceMessageCellModel:
    //            if let command = model.command {
    //                switch command {
    //                case .addMorePhoto:
    //                    showAddPhoto()
    //                default:
    //                    break
    //                }
    //            }
    //        default:
    //            break
    //        }
    //    }

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
        case let model as ServiceMessageWithButtonCellModel:
            return sizeForServiceMessageWithButton(model: model)
        case let model as ServiceMessageCellModel:
            return sizeForServiceMessage(model: model)
        case _ as ChatImageCellModel:
            let size = cloudSize(for: indexPath)
            return CGSize(width: collectionView.bounds.width, height: size.height)
        case let model as ChatUnsentImageCellModel:
            let size = cloudSizeForUnsentImage(id: model.id)
            return  CGSize(width: collectionView.bounds.width, height: size.height)
        case _ as ChatSeparatorCellModel:
            return CGSize(width: collectionView.bounds.width, height: 30)
        case _ as ChatNewMessagesSeparatorModel:
            return CGSize(width: collectionView.bounds.width, height: 30)
        case _ as ChatClaimPaidCellModel:
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
        let processedImage = controller.send(image: image, isAvatar: false)
        if let metadata = controller.chatMetadata {
            unsentImages[metadata.postID] = processedImage
            dataSource.addNewUnsentPhoto(metadata: metadata)
            isScrollToBottomNeeded = true
            refresh(backward: false, isFirstLoad: false)
        }
    }
    
    func imagePicker(controller: ImagePickerController, willClosePickerByCancel cancel: Bool) {
        
    }

    func imagePicker(controller: ImagePickerController, didSendPhotoPost post: ChatEntity) {
        print("New photo post: \(post)")
        dataSource.unsentPhotoWasSent(chatItem: post)
        refresh(backward: false, isFirstLoad: false)
    }

    func imagePicker(controller: ImagePickerController, failedWith error: Error) {
        log(error)
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

// MARK: SelectorDelegate
extension UniversalChatVC: SelectorDelegate {
    func selector(controller: SelectorVC, didSelect index: Int) {
        let type = controller.dataSource.type(for: index)
        if let type = type as? MuteType {
            dataSource.mute(type: type) { [weak self] success in
                self?.setMuteButtonImage(type: type)
            }
        } else if let type = type as? PinType {
            guard let topicID = dataSource.topicID else { return }
            
            if pinState == type {
                pinState = .unknown
                controller.selectedIndex = -1
            } else {
                pinState = type
            }
            
            pinDataSource.change(topicID: topicID, type: type) { [weak self, weak controller] type in
                self?.pinState = type
                controller?.reload()
            }
        } else if let type = type as? PostActionType {
            let oldLike = PostActionType(rawValue: postActionsDataSource?.model.myLike ?? 0)
            var newLike : PostActionType = type
            
            if oldLike == type {
                newLike = .unknown
                controller.selectedIndex = -1
            }

            dataSource.setMyLike(myLike: newLike.rawValue, chatItem: (postActionsDataSource?.model)!) { [weak self, weak controller] success in
                self?.collectionView.reloadData()
                // controller?.reload()
            }
        }
    }
    
    func didCloseSelectorController(controller: SelectorVC) {
        
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
    func chatObjectVoteHide(view: ChatObjectView) {
        log("tap hide", type: .userInteraction)
        self.slidingView.hideVotingView()
    }
    
    func chatObjectVoteShow(view: ChatObjectView) {
        log("tap show", type: .userInteraction)
        if let model = dataSource.chatModel, model.isClaimChat {
            self.slidingView.showVotingView()
        } else if let userID = dataSource.chatModel?.basic?.userID {
            router.presentMemberProfile(teammateID: userID, scrollToVote: true)
        }
    }
    
    func chatObjectWasTapped(view: ChatObjectView) {
        if let model = dataSource.chatModel, model.isClaimChat, let id = model.id {
            router.presentClaim(claimID: id)
        } else if let userID = dataSource.chatModel?.basic?.userID {
            if let canVote = dataSource.chatModel?.voting?.canVote, canVote == true {
                router.presentMemberProfile(teammateID: userID,
                                            teamID: dataSource.chatModel?.team?.teamID,
                                            scrollToVote: true)
            } else {
                router.presentMemberProfile(teammateID: userID,
                                            teamID: dataSource.chatModel?.team?.teamID,
                                            scrollToVote: false)
            }
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
