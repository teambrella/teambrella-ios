//
//  JoinTeamVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 01.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class JoinTeamVC: UIViewController, Routable {
    struct Constant {
        static var cellSpacing: CGFloat = 16
    }
    
    static let storyboardName = "Team"
    
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var infoButton: UIButton!
    @IBOutlet var teamImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var teamNameLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var getStartedButton: PlainButton!
    
    @IBOutlet var teamImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet var teamImageTopOffsetConstraint: NSLayoutConstraint!
    
    var dataSource: JoinTeamDataSource = JoinTeamDataSource()
    
    var isAvatarSmall: Bool = false
    var currentItem: Int = 0
    
    fileprivate var itemWidth: CGFloat {
        return collectionView.bounds.width - Constant.cellSpacing * 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        JoinTeamCellBuilder.registerCells(in: collectionView)
        dataSource.createFakeCells()
        teamImageView.layer.cornerRadius = 10
    }
    
    @IBAction func tapClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapInfo(_ sender: UIButton) {
        setAvatarSizeToSmall(!isAvatarSmall)
    }
    
    @IBAction func tapGetStarted(_ sender: UIButton) {
        currentItem = currentItem < dataSource.count - 1 ? currentItem + 1 : 0
        collectionView.scrollToItem(at: IndexPath(row: currentItem, section: 0),
                                    at: .centeredHorizontally,
                                    animated: true)
        pageControl.currentPage = currentItem
    }
    
    func setAvatarSizeToSmall(_ small: Bool) {
        if small {
            resizeAvatar(to: 32, offset: 27, cornerRadius: 4, animated: true)
            isAvatarSmall = true
        } else {
            resizeAvatar(to: 64, offset: 23, cornerRadius: 10, animated: true)
            isAvatarSmall = false
        }
    }
    
    func resizeAvatar(to size: CGFloat, offset: CGFloat, cornerRadius: CGFloat, animated: Bool) {
        teamImageWidthConstraint.constant = size
        teamImageTopOffsetConstraint.constant = offset
        if animated {
            
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 15,
                           options: [],
                           animations: {
                            self.view.layoutIfNeeded()
            })
            let animation = CABasicAnimation(keyPath: "cornerRadius")
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            animation.fromValue = teamImageView.layer.cornerRadius
            animation.toValue = cornerRadius
            animation.duration = 0.5
            teamImageView.layer.cornerRadius = cornerRadius
            teamImageView.layer.add(animation, forKey: "cornerRadius")
        } else {
            teamImageView.layer.cornerRadius = cornerRadius
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let pageWidth = Float(itemWidth + Constant.cellSpacing)
        let targetXContentOffset = Float(targetContentOffset.pointee.x)
        let contentWidth = Float(collectionView.contentSize.width  )
        var newPage = Float(self.pageControl.currentPage)
        
        if velocity.x == 0 {
            newPage = floor( (targetXContentOffset - Float(pageWidth) / 2) / Float(pageWidth)) + 1.0
        } else {
            newPage = Float(velocity.x > 0 ? self.pageControl.currentPage + 1 : self.pageControl.currentPage - 1)
            if newPage  > contentWidth / pageWidth {
                newPage = ceil(contentWidth / pageWidth) - 1.0
            }
        }
        self.pageControl.currentPage = Int(newPage)
        let point = CGPoint (x: CGFloat(newPage * pageWidth), y: targetContentOffset.pointee.y)
        targetContentOffset.pointee = point
    }
    
}

// MARK: UICollectionViewDataSource
extension JoinTeamVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageControl.numberOfPages = dataSource.count
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: type(of: dataSource[indexPath]).cellID,
                                                  for: indexPath)
    }
    
}

// MARK: UICollectionViewDelegate
extension JoinTeamVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        JoinTeamCellBuilder.populate(cell: cell, with: dataSource[indexPath])
        
        if let cell = cell as? JoinTeamGreetingCell {
            let size = self.collectionView(collectionView,
                                           layout: collectionView.collectionViewLayout,
                                           sizeForItemAt: indexPath)
            cell.radarView.centerY = 85 - size.height
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout
extension JoinTeamVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: collectionView.bounds.height - 30)
    }
}
