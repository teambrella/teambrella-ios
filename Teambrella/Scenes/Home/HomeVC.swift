//
//  HomeVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 25.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import PKHUD
import SpriteKit
import UIKit

class HomeVC: UIViewController, TabRoutable, PagingDraggable {
    struct Constant {
        static let cardInterval: CGFloat = 24
    }
    let tabType: TabType = .home
    
    @IBOutlet var gradientView: GradientView!
    @IBOutlet var collectionView: UICollectionView!
    
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
    var dataSource: HomeDataSource = HomeDataSource()
    
    @IBOutlet var teamsButton: DropDownButton!
    @IBOutlet var inboxButton: LabeledButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        title = "Main.home".localized
        tabBarItem.title = "Main.home".localized
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HUD.show(.progress)
        setupTransparentNavigationBar()
        gradientView.setup(colors: [#colorLiteral(red: 0.1803921569, green: 0.2392156863, blue: 0.7960784314, alpha: 1), #colorLiteral(red: 0.2156862745, green: 0.2705882353, blue: 0.8078431373, alpha: 1), #colorLiteral(red: 0.368627451, green: 0.4156862745, blue: 0.8588235294, alpha: 1)],
                           locations: [0.0, 0.5, 1.0])
        
        if let teamID = service.session.currentTeam?.teamID {
            dataSource.loadData(teamID: teamID)
            dataSource.onUpdate = { [weak self] in
                self?.setup()
            }
        } else {
            print("This session has no team!")
        }
        
        let touch = UITapGestureRecognizer(target: self, action: #selector(tapItem))
        itemCard.avatarView.isUserInteractionEnabled = true
        itemCard.avatarView.addGestureRecognizer(touch)
        HomeCellBuilder.registerCells(in: collectionView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollViewDidScroll(collectionView)
        
        //service.router.setMyTabImage(with: #imageLiteral(resourceName: "teammateF"))
        addEmitter()
    }
    
    func addEmitter() {
        let skScene: SKScene = SKScene(size: emitterScene.frame.size)
        skScene.scaleMode = .aspectFit
        skScene.backgroundColor = .clear
        if let emitter: SKEmitterNode = SKEmitterNode(fileNamed: "Fill.sks") {
            emitter.position = CGPoint(x: emitterScene.center.x, y: emitterScene.frame.maxY)
            skScene.addChild(emitter)
            emitterScene.presentScene(skScene)
            emitterScene.allowsTransparency = true
        }
    }
    
    func tapItem() {
        DeveloperTools.notSupportedAlert(in: self)
    }
    
    func setup() {
        collectionView.reloadData()
        
        guard let model = dataSource.model else { return }
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapPageControl(_ sender: UIPageControl) {
        let indexPath = IndexPath(row: sender.currentPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    @IBOutlet var submitClaimButton: BorderedButton!
    
    @IBAction func tapSubmitClaim(_ sender: UIButton) {
        MeRouter().presentClaimReport()
    }
    
    @IBAction func tapLeftBrick(_ sender: Any) {
        service.router.showCoverage()
    }
    
    @IBAction func tapRightBrick(_ sender: Any) {
        service.router.showWallet()
    }
    
    @IBAction func tapTeams(_ sender: UIButton) {
          DeveloperTools.notSupportedAlert(in: self)
    }
    
    @IBAction func tapInbox(_ sender: UIButton) {
        DeveloperTools.notSupportedAlert(in: self)
    }
    
    func tapChatWithSupport(_ sender: UIButton) {
        DeveloperTools.notSupportedAlert(in: self)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        pagerWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
}

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
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //let model = dataSource[indexPath]
        
      DeveloperTools.notSupportedAlert(in: self)
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

extension HomeVC: UICollectionViewDelegate {
    
}

extension HomeVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cardWidth, height: collectionView.bounds.height)
    }
}
