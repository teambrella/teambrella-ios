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
    
    @IBOutlet var objectView: UIView!
    @IBOutlet var objectViewHeight: NSLayoutConstraint!
    @IBOutlet var objectImage: UIImageView!
    @IBOutlet var objectNameLabel: StatusSubtitleLabel!
    @IBOutlet var objectDetailsLabel: InfoHelpLabel!
    @IBOutlet var objectBlueDetailsLabel: CurrencyLabel!
    @IBOutlet var objectVoteTitleLabel: InfoLabel!
    @IBOutlet var objectVoteLabel: TitleLabel!
    @IBOutlet var objectPercentLabel: TitleLabel!
    @IBOutlet var objectRightLabel: UILabel!
    @IBOutlet var objectAvatarView: RoundImageView!
    
    override var inputAccessoryView: UIView? { return input }
    override var canBecomeFirstResponder: Bool { return true }
    
    lazy var picker: ImagePickerController = { ImagePickerController(parent: self, delegate: self) }()
    
    private let input: InputAccessoryView = InputAccessoryView()
    private let dataSource = UniversalChatDatasource()
    private var socketToken = "UniversalChat"
    private var lastTypingDate: Date = Date()
    private var typingUsers: [String: Date] = [:]
    
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
        setupInitialObjectView()
        setupCollectionView()
        setupInput()
        setupTapGestureRecognizer()
        dataSource.onUpdate = { [weak self] backward, hasNew, isFirstLoad in
            guard let `self` = self else { return }
            
            self.collectionView.refreshControl?.endRefreshing()
            self.setupActualObjectViewIfNeeded()
            self.setupTitle()
            self.setMuteButtonImage(type: self.dataSource.notificationsType)
            guard hasNew else {
                if isFirstLoad {
                    self.shouldScrollToBottom = true
                    self.dataSource.isLoadPreviousNeeded = true
                }
                return
            }
            
            self.refresh(backward: backward)
        }
        dataSource.onSendMessage = { [weak self] indexPAth in
            guard let `self` = self else { return }
            
            self.shouldScrollToBottom = true
            self.refresh(backward: false)
            self.dataSource.loadNext()
        }
        dataSource.isLoadNextNeeded = true
        title = ""
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapRightLabel))
        objectRightLabel.addGestureRecognizer(tap)
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
        
        //let lastIndexPath = IndexPath(row: dataSource.count - 1, section: 0)
        //        collectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: animated)
        //        return
        
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
        //if dataSource.isPrivateChat { return }
        
        picker.showOptions()
        //input.isHidden = true
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
    
    //    func adjustCollectionViewHeight() {
    //        collectionView.contentInset.bottom = keyboardHeight
    //    }
    
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
    func tapHeader(sender: UIButton) {
        if let claimID = dataSource.claimID {
            service.router.presentClaim(claimID: claimID)
        }
    }
    
    @objc
    private func tapMuteButton(sender: UIButton) {
        service.router.showNotificationFilter(in: self, delegate: self, currentState: dataSource.notificationsType)
        
    }
    
    @objc
    private func tapRightLabel(gesture: UITapGestureRecognizer) {
        if let claimID = dataSource.chatModel?.id {
       // if (dataSource.chatModel?.basicPart as? BasicPartClaimConcrete) != nil, let id = dataSource.chatModel?.id {
            service.router.presentClaim(claimID: claimID, scrollToVoting: true)
        } else if let userID = dataSource.chatModel?.basic?.userID {
            service.router.presentMemberProfile(teammateID: userID, scrollToVote: true)
        }
    }
    
    @objc
    private func showClaimDetails(gesture: UITapGestureRecognizer) {
        guard let id = dataSource.chatModel?.id else { return }
        
        service.router.presentClaim(claimID: id, scrollToVoting: false)
    }
    
    @objc
    private func showTeammateDetails(gesture: UITapGestureRecognizer) {
        guard let userID = dataSource.chatModel?.basic?.userID else { return }
        
        service.router.presentMemberProfile(teammateID: userID)
    }
    
}

// MARK: Private
private extension UniversalChatVC {
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
                                       constant: 3 + objectView.frame.minY).isActive = true
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
    
    private func setupClaimObjectView(basic: ChatModel.BasicPart,
                                      voting: ChatModel.VotingPart?,
                                      team: TeamPart) {
        objectNameLabel.text = basic.model
        objectDetailsLabel.text = basic.claimAmount.map { amount in
            "Team.Chat.ObjectView.ClaimAmountLabel".localized + String(format: "%.2f", amount)
        }
        objectBlueDetailsLabel.text = team.currency
        objectVoteTitleLabel.text = "Team.Chat.ObjectView.TitleLabel".localized
        objectPercentLabel.text = "%"
        objectRightLabel.text = "Team.Chat.ObjectView.VoteLabel".localized
        
        objectImage.image = #imageLiteral(resourceName: "imagePlaceholder")
        basic.smallPhoto.map { objectImage.showImage(string: $0) }
        
        if let voting = voting {
            if let vote = voting.myVote {
                objectVoteLabel.text = String(format: "%.f", vote * 100)
                objectRightLabel.text = "Team.Chat.ObjectView.RevoteLabel".localized
            } else {
                objectVoteLabel.text = "..."
            }
        } else if let reimbursement = basic.reimbursement {
            objectVoteTitleLabel.text = "Team.Chat.ObjectView.TitleLabel.team".localized
            objectVoteLabel.text = String.truncatedNumber(reimbursement * 100)
            objectRightLabel.isHidden = true
        }
    }
    
    private func setupTeammateObjectView(basic: ChatModel.BasicPart,
                                         voting: ChatModel.VotingPart?,
                                         team: TeamPart) {
        objectNameLabel.text = basic.name?.short
        objectImage.showImage(string: basic.avatar)
        if let model = basic.model, let year = basic.year {
        objectDetailsLabel.text = "\(model.uppercased()), \(year)"
        }
        objectVoteTitleLabel.text = "Team.Chat.ObjectView.TitleLabel".localized
        objectPercentLabel.isHidden = true
        objectBlueDetailsLabel.isHidden = true
        
        if let voting = voting {
            objectRightLabel.text = "Team.Chat.ObjectView.VoteLabel".localized
            objectBlueDetailsLabel.text = nil
            
            guard let vote = voting.myVote else {
                objectVoteLabel.text = "..."
                return
            }
            objectVoteLabel.text = String(format: "%.2f", vote)
            objectRightLabel.text = "Team.Chat.ObjectView.RevoteLabel".localized
        } else if let risk = basic.risk {
            objectVoteTitleLabel.text = "Team.Chat.ObjectView.TitleLabel.risk".localized
            objectVoteLabel.text = String.truncatedNumber(risk)
            objectRightLabel.isHidden = true
        }
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
        // adjustCollectionViewHeight()
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
            
            if Date().timeIntervalSince(self.lastTypingDate) > 3 {
                self.showIsTyping = false
                self.typingUsers.removeAll()
            }
        }
    }
    
    private func setupInput() {
        if dataSource.isPrivateChat {
            input.leftButton.setImage(#imageLiteral(resourceName: "crossIcon"), for: .normal)
            input.leftButton.isEnabled = false
        }
        input.leftButton.addTarget(self, action: #selector(tapLeftButton), for: .touchUpInside)
        input.rightButton.addTarget(self, action: #selector(tapRightButton), for: .touchUpInside)
        if let socket = service.socket,
            let teamID = service.session?.currentTeam?.teamID {
            input.onTextChange = { [weak socket, weak self] in
                guard let me = self else { return }
                
                let interval = me.lastTypingDate.timeIntervalSinceNow
                if interval < -2, let topicID = me.dataSource.topicID,
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
        
        // refresh(backward: false)
    }
    
    private func setupInitialObjectView() {
        ViewDecorator.shadow(for: objectView, opacity: 0.08, radius: 4)
        objectViewHeight.constant = 0
        objectView.isHidden = true
    }
    
    private func setupActualObjectViewIfNeeded() {
        guard dataSource.isObjectViewNeeded else {
            objectViewHeight.constant = 0
            objectView.isHidden = true
            return
        }
        guard let teamPart = dataSource.chatModel?.team else { return }
        
        objectViewHeight.constant = 48
        objectView.isHidden = false
        let tap = UITapGestureRecognizer()
        if let basicPart = dataSource.chatModel?.basic, basicPart.claimAmount != nil {
            setupClaimObjectView(basic: basicPart,
                                 voting: dataSource.chatModel?.voting,
                                 team: teamPart)
            tap.addTarget(self, action: #selector(showClaimDetails))
        } else if let basicPart = dataSource.chatModel?.basic {
            setupTeammateObjectView(basic: basicPart,
                                    voting: dataSource.chatModel?.voting,
                                    team: teamPart)
            tap.addTarget(self, action: #selector(showTeammateDetails))
        }
        objectView.addGestureRecognizer(tap)
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
        if let cell = cell as? ChatTextCell {
            if let model = model as? ChatTextCellModel {
                let size = cloudSize(for: indexPath)
                cell.prepare(with: model, cloudWidth: size.width, cloudHeight: size.height)
                cell.avatarView.tag = indexPath.row
                cell.avatarTap.removeTarget(self, action: #selector(tapAvatar))
                cell.avatarTap.addTarget(self, action: #selector(tapAvatar))
                cell.onTapImage = { [weak self] cell, galleryView in
                    guard let `self` = self else { return }
                    
                    galleryView.fullscreen(in: self, imageStrings: self.dataSource.allImages)
                }
                //cell.alpha = model.isTemporary ? 0.5 : 1
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
