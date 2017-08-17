//
//  HomeVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 25.05.17.

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

import PKHUD
import SpriteKit
import UIKit

class HomeVC: UIViewController, TabRoutable, PagingDraggable {
    struct Constant {
        static let cardInterval: CGFloat = 24
        
        static let teamIconWidth: CGFloat = 24
        static let teamIconCornerRadius: CGFloat = 4
    }
    
    let tabType: TabType = .home
    
    @IBOutlet var gradientView: GradientView!
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var walletContainer: UIView!
    @IBOutlet var greetingsTitleLabel: UILabel!
    @IBOutlet var greetingsSubtitileLabel: UILabel!
    
    @IBOutlet var leftBrickTitleLabel: UILabel!
    @IBOutlet var leftBrickAvatarView: UIImageView!
    @IBOutlet var leftBrickAmountLabel: UILabel!
    @IBOutlet var leftBrickCurrencyLabel: UILabel!
    
    @IBOutlet var rightBrickTitleLabel: UILabel!
    @IBOutlet var rightBrickAvatarView: UIImageView!
    @IBOutlet var rightBrickAmountLabel: UILabel!
    @IBOutlet var rightBrickCurrencyLabel: UILabel!
    @IBOutlet var confettiView: UIImageView!
    
    @IBOutlet var pageControl: UIPageControl!
    var draggablePageWidth: Float { return Float(cardWidth) }
    var cardWidth: CGFloat { return collectionView.bounds.width - Constant.cardInterval * 2 }
    
    @IBOutlet var itemCard: ItemCard!
    
    @IBOutlet var emitterScene: SKView!
    
    @IBOutlet var teamsButton: DropDownButton!
    @IBOutlet var inboxButton: LabeledButton!
    
    var dataSource: HomeDataSource = HomeDataSource()
    
    var isEmitterAdded: Bool = false
    
    // MARK: Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        title = "Main.home".localized
        tabBarItem.title = "Main.home".localized
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearScreen()
        setupTransparentNavigationBar()
        gradientView.setup(colors: [#colorLiteral(red: 0.1803921569, green: 0.2392156863, blue: 0.7960784314, alpha: 1), #colorLiteral(red: 0.2156862745, green: 0.2705882353, blue: 0.8078431373, alpha: 1), #colorLiteral(red: 0.368627451, green: 0.4156862745, blue: 0.8588235294, alpha: 1)],
                           locations: [0.0, 0.5, 1.0])
        HomeCellBuilder.registerCells(in: collectionView)
        setupWalletContainer()
        let touch = UITapGestureRecognizer(target: self, action: #selector(tapItem))
        itemCard.avatarView.isUserInteractionEnabled = true
        itemCard.avatarView.addGestureRecognizer(touch)
        
        switchToCurrentTeam()
    }
    
    func switchToCurrentTeam() {
        HUD.show(.progress)
        dataSource = HomeDataSource()
        if let teamID = service.session.currentTeam?.teamID {
            dataSource.loadData(teamID: teamID)
        }
        
        dataSource.onUpdate = { [weak self] in
            self?.setup()
        }
        guard let source = service.session.currentTeam?.teamLogo else { return }
        
        UIImage.fetchAvatar(string: source,
                            width: Constant.teamIconWidth,
                            cornerRadius: Constant.teamIconCornerRadius) { image, error  in
                                guard error == nil else { return }
                                guard let image = image else { return }
                                
                                self.teamsButton.setImage(image, for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Should fix an unwanted slide of the card to the left after returning to this vc from tap
        guard collectionView(collectionView, numberOfItemsInSection: 0) > pageControl.currentPage else { return }
        
        collectionView.scrollToItem(at: IndexPath(row: pageControl.currentPage, section: 0),
                                    at: .centeredHorizontally,
                                    animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //scrollViewDidScroll(collectionView)
        addEmitter()
    }
    
    private func clearScreen() {
        greetingsTitleLabel.text = nil
        greetingsSubtitileLabel.text = nil
        
        leftBrickAmountLabel.text = "..."
        rightBrickAmountLabel.text = "..."
        
        itemCard.avatarView.image = #imageLiteral(resourceName: "imagePlaceholder")
        itemCard.subtitleLabel.text = nil
        itemCard.titleLabel.text = nil
    }
    
    private func setupWalletContainer() {
        CellDecorator.shadow(for: walletContainer, opacity: 0.08, radius: 3, offset: CGSize(width: 0, height: -3))
    }
    
    private func addEmitter() {
        guard !isEmitterAdded else { return }
        
        isEmitterAdded = true
        let skScene: SKScene = SKScene(size: emitterScene.frame.size)
        skScene.scaleMode = .aspectFit
        skScene.backgroundColor = .clear
        if let emitter: SKEmitterNode = SKEmitterNode(fileNamed: "Fill.sks") {
            emitter.position = CGPoint(x: emitterScene.center.x, y: 0)
            skScene.addChild(emitter)
            emitterScene.presentScene(skScene)
            emitterScene.allowsTransparency = true
        }
    }
    
    private func setup() {
        collectionView.reloadData()
        
        guard let model = dataSource.model else { return }
        
        service.session.currentUserID = model.userID
        service.session.currentUserName = model.name
        service.session.currentUserAvatar = model.avatar
        
        UIImage.fetchAvatar(string: model.avatar) { image, error in
            guard let image = image else { return }
            
            service.router.setMyTabImage(with: image)
        }
        
        leftBrickAmountLabel.text = String(format: "%.0f", model.coverage * 100)
        rightBrickAmountLabel.text = String.formattedNumber(model.balance * 1000)
        rightBrickCurrencyLabel.text = "mBTC"
        
        greetingsTitleLabel.text = "Home.salutation".localized(dataSource.name)
        greetingsSubtitileLabel.text = "Home.subtitle".localized
        
        leftBrickTitleLabel.text = "Home.leftBrick.title".localized
        rightBrickTitleLabel.text = "Home.rightBrick.title".localized
        
        itemCard.avatarView.showImage(string: model.smallPhoto)
        itemCard.titleLabel.text = model.objectName
        itemCard.statusLabel.text = "Home.itemCard.status".localized
        itemCard.subtitleLabel.text = model.coverageType.localizedName
        
        let buttonTitle = model.haveVotingClaims
            ? "Home.submitButton.anotherClaim".localized
            : "Home.submitButton.claim".localized
        submitClaimButton.setTitle(buttonTitle, for: .normal)
        
        pageControl.numberOfPages = dataSource.cardsCount
        if model.unreadCount > 0 {
            inboxButton.cornerText = String(model.unreadCount)
        }
        HUD.hide()
    }
    
    // MARK: User interaction handling
    
    func tapItem() {
        DeveloperTools.notSupportedAlert(in: self)
    }
    
    @IBAction func tapPageControl(_ sender: UIPageControl) {
        let indexPath = IndexPath(row: sender.currentPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    @IBOutlet var submitClaimButton: BorderedButton!
    
    @IBAction func tapSubmitClaim(_ sender: UIButton) {
        service.router.presentClaimReport()
    }
    
    @IBAction func tapLeftBrick(_ sender: Any) {
        service.router.switchToCoverage()
    }
    
    @IBAction func tapRightBrick(_ sender: Any) {
        service.router.switchToWallet()
    }
    
    @IBAction func tapTeams(_ sender: UIButton) {
        service.router.showChooseTeam(in: self, delegate: self)
    }
    
    @IBAction func tapInbox(_ sender: UIButton) {
        DeveloperTools.notSupportedAlert(in: self)
    }
    
    func tapChatWithSupport(_ sender: UIButton) {
        DeveloperTools.notSupportedAlert(in: self)
    }
    
    func closeCard(_ sender: UIButton) {
        print("Tap close!!!!!!!")
        dataSource.deleteCard(at: sender.tag)
        collectionView.reloadData()
        pageControl.numberOfPages = dataSource.cardsCount
    }
    
}

// MARK: UICollectionViewDataSource
extension HomeVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.cardsCount
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return  collectionView.dequeueReusableCell(withReuseIdentifier: dataSource.cellID(for: indexPath),
                                                   for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        HomeCellBuilder.populate(cell: cell, dataSource: dataSource, model: dataSource[indexPath])
        if let cell = cell as? HomeSupportCell {
            cell.button.removeTarget(nil, action: nil, for: .allEvents)
            cell.button.addTarget(self, action: #selector(tapChatWithSupport), for: .touchUpInside)
        }
        if let cell = cell as? ClosableCell {
            cell.closeButton.removeTarget(self, action: nil, for: .allEvents)
            cell.closeButton.addTarget(self, action: #selector(closeCard), for: .touchUpInside)
            cell.closeButton.tag = indexPath.row
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row < dataSource.cardsCount - 1 else {
            // handle Chat with support tap
            DeveloperTools.notSupportedAlert(in: self)
            return
        }
        
        dataSource[indexPath].map { service.router.presentChat(context: ChatContext.home($0)) }
    }
}

// MARK: UICollectionViewDelegate
extension HomeVC: UICollectionViewDelegate {
    
}

// MARK: UICollectionViewDelegateFlowLayout
extension HomeVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cardWidth, height: collectionView.bounds.height)
    }
}

// MARK: UIScrollViewDelegate
extension HomeVC: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        pagerWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let center = view.bounds.midX
        let cells = collectionView.visibleCells
        var nearest = CGFloat.greatestFiniteMagnitude
        for cell in cells {
            let cellCenter = collectionView.convert(cell.center, to: view)
            let newNearest = abs(center - cellCenter.x)
            if  newNearest < nearest {
                nearest = newNearest
            }
            
            let scaleMultiplier = 1 - 0.07 * (newNearest / 100)
            let scaleTransform = CATransform3DMakeScale(scaleMultiplier, scaleMultiplier, 1.0)
            cell.layer.transform = scaleTransform
        }
    }
}

extension HomeVC: ChooseYourTeamControllerDelegate {
    func chooseTeam(controller: ChooseYourTeamVC, didSelectTeamID: Int) {
        service.router.switchTeam()
    }
}
