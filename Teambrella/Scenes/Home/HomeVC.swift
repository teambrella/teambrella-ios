//
//  HomeVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 25.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import PKHUD
import UIKit

class HomeVC: UIViewController, TabRoutable {
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
    
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet var itemCard: ItemCard!
    
    var dataSource: HomeDataSource = HomeDataSource()
    
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
    }
    
    func setup() {
        collectionView.reloadData()
        
        guard let model = dataSource.model else { return }
        
        leftBrickAmountLabel.text = String(format: "%.0f", model.coverage * 100)
        rightBrickAmountLabel.text = String.formattedNumber(double: model.balance)
        rightBrickCurrencyLabel.text = dataSource.currency
        
        if let name = model.name.components(separatedBy: " ").first {
            greetingsTitleLabel.text = "Hi " + name + "!"
        }
        
        itemCard.avatarView.showImage(string: model.smallPhoto)
        itemCard.titleLabel.text = model.objectName
        
        let buttonTitle = model.haveVotingClaims ? "Submit Another Claim" : "Submit Claim"
        submitClaimButton.setTitle(buttonTitle, for: .normal)
        
        pageControl.numberOfPages = dataSource.cardsCount
        
        HUD.hide()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollViewDidScroll(collectionView)
        
        service.router.setMyTabImage(with: #imageLiteral(resourceName: "teammateF"))
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
}

extension HomeVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.cardsCount
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print(indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeCollectionCell", for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if let cell = cell as? HomeCollectionCell {
            cell.setupShadow()
            
            guard let model = dataSource[indexPath] else { return }
            
            cell.leftNumberView.amountLabel.text = String.formattedNumber(double: model.amount)
            cell.leftNumberView.titleLabel.text = "CLAIMED"
            cell.leftNumberView.currencyLabel.text = dataSource.currency
            
            cell.rightNumberView.amountLabel.text = String(format: "%.0f", model.teamVote * 100)
            cell.rightNumberView.titleLabel.text = "TEAM VOTE"
            cell.rightNumberView.currencyLabel.text = "%"
            cell.rightNumberView.badgeLabel.text = "VOTING"
            
            cell.avatarView.showAvatar(string: model.smallPhoto)
            if let date = model.itemDate {
                cell.subtitleLabel.text = Formatter.teambrella.string(from: date)
            }
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let center = view.bounds.midX
        let cells = collectionView.visibleCells
        var nearest = CGFloat.greatestFiniteMagnitude
        var idx = 0
        for cell in cells {
            let cellCenter = collectionView.convert(cell.center, to: view)
            let newNearest = abs(center - cellCenter.x)
            if  newNearest < nearest {
                nearest = newNearest
                let index = collectionView.indexPath(for: cell)
                idx = index?.row ?? 0
            }
            
            let scaleMultiplier = 1 - 0.07 * (newNearest / 100)
            let scaleTransform = CATransform3DMakeScale(scaleMultiplier, scaleMultiplier, 1.0)
            cell.layer.transform = scaleTransform
        }
        pageControl.currentPage = idx
    }
}

extension HomeVC: UICollectionViewDelegate {
    
}

extension HomeVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 20, height: collectionView.bounds.height)
    }
}
