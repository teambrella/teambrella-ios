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
    case claim(ClaimEntityLarge)
    case teammate(TeammateLarge)
    case feed(FeedEntity)
    case home(HomeCardModel)
    case chat(ChatModel)
    case privateChat(PrivateChatUser)
    case remote(RemoteTopicDetails)
    case none
    
    var claimID: Int? {
        switch self {
        case let .claim(entity):
            return entity.id
        case let .feed(feed):
            return feed.itemType == .claim ? feed.itemID : nil
        default:
            return nil
        }
    }
}

final class UniversalChatVC: UIViewController, Routable {
    static var storyboardName = "Chat"
    
    @IBOutlet var collectionView: UICollectionView!

    @IBOutlet var slidingView: SlidingView!
    @IBOutlet var slidingViewHeight: NSLayoutConstraint!

    override var inputAccessoryView: UIView? { return input }
    override var canBecomeFirstResponder: Bool { return true }
    
    lazy var picker: ImagePickerController = { ImagePickerController(parent: self, delegate: self) }()
    
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
    private var cloudWidth: CGFloat { return collectionView.bounds.width * 0.66 }
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientNavBar()
        addMuteButton()
        setMuteButtonImage(type: dataSource.notificationsType)
        setupCollectionView()
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
            guard hasNew else {
                if isFirstLoad {
                    self.shouldScrollToBottom = true
                    self.dataSource.isLoadPreviousNeeded = true
                }
                return
            }
            
            self.refresh(backward: backward)
        }
        dataSource.onSendMessage = { [weak self] indexPath in
            guard let `self` = self else { return }
            
            self.shouldScrollToBottom = true
            self.refresh(backward: false)
            self.dataSource.loadNext()
        }
        dataSource.onClaimVoteUpdate = { [weak self] in
            guard let `self` = self else { return }
            guard let model = self.dataSource.chatModel else { return }

            self.slidingView.updateChatModel(model: model)
        }

        dataSource.isLoadNextNeeded = true
        title = ""

        let session = service.session
        slidingView.setupViews(with: self, session: session)
        slidingView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startListeningSockets()
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
        service.socket?.remove(listener: socketToken)
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
        if let model = dataSource[indexPath] as? ChatTextCellModel {
            let userID = model.entity.userID
            service.router.presentMemberProfile(teammateID: userID)
        }
    }
    
    @objc
    private func tapMuteButton(sender: UIButton) {
        service.router.showNotificationFilter(in: self, delegate: self, currentState: dataSource.notificationsType)
        
    }

}

// MARK: Private
private extension UniversalChatVC {
    private func setupScrollHandler() {
        scrollViewHandler.onScrollingUp = {
            self.slidingView.hideAll()
        }

        scrollViewHandler.onScrollingDown = {
            self.showObject()
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
        collectionView.register(ChatCell.nib, forCellWithReuseIdentifier: ChatCell.cellID)
        collectionView.register(ChatTextCell.self, forCellWithReuseIdentifier: "com.chat.text.cell")
        collectionView.register(ChatSeparatorCell.self, forCellWithReuseIdentifier: "com.chat.separator.cell")
        collectionView.register(ChatNewMessagesSeparatorCell.self, forCellWithReuseIdentifier: "com.chat.new.cell")
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
    
    /**
     * Refresh controller after new data comes from the server
     *
     * - Parameter backward: if the chunk of data comes above existing cells or below them
     */
    private func refresh(backward: Bool) {
        // not using reloadData() to avoid blinking of cells
        //        collectionView.dataSource = nil
        //        collectionView.dataSource = self
        collectionView.reloadData()
        if self.shouldScrollToBottom {
            self.scrollToBottom(animated: true)
            self.shouldScrollToBottom = false
        } else if backward, let indexPath = self.dataSource.currentTopCellPath {
            self.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
        }
    }
    
    private func cloudSize(for indexPath: IndexPath) -> CGSize {
        guard let model = dataSource[indexPath] as? ChatTextCellModel else { return .zero }
        
        return CGSize(width: cloudWidth,
                      height: model.totalFragmentsHeight + CGFloat(model.fragments.count) * 2 + 60 )
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
        ViewDecorator.shadow(for: input, color: #colorLiteral(red: 0.8705882353, green: 0.8901960784, blue: 0.9098039216, alpha: 1), opacity: 1, radius: 8, offset: CGSize(width: 0, height: 0))
        if dataSource.isPrivateChat {
            input.leftButton.setImage(#imageLiteral(resourceName: "crossIcon"), for: .normal)
            input.leftButton.isHidden = true
            input.leftButton.isEnabled = false
        }
        input.leftButton.addTarget(self, action: #selector(tapLeftButton), for: .touchUpInside)
        input.rightButton.addTarget(self, action: #selector(tapRightButton), for: .touchUpInside)
        if let socket = service.socket,
            let teamID = service.session?.currentTeam?.teamID {
            input.onTextChange = { [weak socket, weak self] in
                guard let me = self else { return }
                
                let interval = me.lastTypingDate.timeIntervalSinceNow
                if interval < -2.0, let topicID = me.dataSource.topicID,
                    let name = service.session?.currentUserName {
                    socket?.meTyping(teamID: teamID, topicID: topicID, name: name.first)
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
        case _ as ChatTextCellModel,
             _ as ChatTextUnsentCellModel:
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
        if indexPath.row > dataSource.count - dataSource.limit / 2 {
            dataSource.isLoadNextNeeded = true
        }
        
        let model = dataSource[indexPath]
        if let cell = cell as? ChatTextCell {
            if let model = model as? ChatTextCellModel {
                let size = cloudSize(for: indexPath)
                cell.prepare(with: model, cloudWidth: size.width, cloudHeight: size.height)

                // crunch
//                if model.isMy, let model = dataSource.chatModel, model.isClaimChat, let vote = model.voting?.myVote {
//                    cell.rightLabel.text = dataSource.cellModelBuilder.rateText(rate: vote,
//                                                                                showRate: true,
//                                                                                isClaim: true)
//                }
                cell.avatarView.tag = indexPath.row
                cell.avatarTap.removeTarget(self, action: #selector(tapAvatar))
                cell.avatarTap.addTarget(self, action: #selector(tapAvatar))
                cell.onTapImage = { [weak self] cell, galleryView in
                    guard let `self` = self else { return }
                    
                    galleryView.fullscreen(in: self, imageStrings: self.dataSource.allImages)
                }
            } else if let model = model as? ChatTextUnsentCellModel {
                let size = cloudSize(for: indexPath)
                cell.prepare(with: model, cloudWidth: size.width, cloudHeight: size.height)
                cell.avatarView.tag = indexPath.row
                cell.avatarTap.removeTarget(self, action: #selector(tapAvatar))
                cell.avatarTap.addTarget(self, action: #selector(tapAvatar))
                cell.onTapImage = { [weak self] cell, galleryView in
                    guard let `self` = self else { return }
                    
                    galleryView.fullscreen(in: self, imageStrings: self.dataSource.allImages)
                }
                cell.alpha = 0.5
            }
        } else if let cell = cell as? ChatSeparatorCell, let model = model as? ChatSeparatorCellModel {
            cell.text = Formatter.teambrellaShort.string(from: model.date)
        } else if let cell = cell as? ChatNewMessagesSeparatorCell,
            let model = model as? ChatNewMessagesSeparatorModel {
            cell.label.text = model.text
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
        service.router.push(vc: viewControllerToCommit, animated: true)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                           viewControllerForLocation location: CGPoint) -> UIViewController? {
        let updatedLocation = view.convert(location, to: collectionView)
        guard let indexPath = collectionView?.indexPathForItem(at: updatedLocation) else { return nil }
        guard let cell = collectionView?.cellForItem(at: indexPath) as? ChatTextCell else { return nil }
        
        let cellLocation = collectionView.convert(updatedLocation, to: cell.avatarView)
        guard cell.avatarView.point(inside: cellLocation, with: nil) else { return nil }
        guard let model = dataSource[indexPath] as? ChatTextCellModel else { return nil }
        guard let vc = service.router.getControllerMemberProfile(teammateID: model.entity.userID) else { return nil }
        
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
        guard let teamID = service.session?.currentTeam?.teamID, let claimID = dataSource.chatModel?.id else { return }

        service.router.presentOthersVoted(teamID: teamID, teammateID: nil, claimID: claimID)
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
                service.router.presentMemberProfile(teammateID: userID, scrollToVote: true)
            }
        case view.chevronButton:
            self.slidingView.hideVotingView()
        default:
            break
        }
    }

    func chatObjectWasTapped(view: ChatObjectView) {
        if let model = dataSource.chatModel, model.isClaimChat, let id = model.id {
            service.router.presentClaim(claimID: id)
        } else if let userID = dataSource.chatModel?.basic?.userID {
            service.router.presentMemberProfile(teammateID: userID, scrollToVote: true)
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
