//
//  JoinTeamVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 01.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class JoinTeamVC: UIViewController, Routable {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        JoinTeamCellBuilder.registerCells(in: collectionView)
        dataSource.createFakeCells()
    }

    @IBAction func tapClose(_ sender: UIButton) {
        
    }
    
    @IBAction func tapInfo(_ sender: UIButton) {
        setAvatarSizeToSmall(!isAvatarSmall)
    }
    
    @IBAction func tapGetStarted(_ sender: UIButton) {
        
    }
    
    func setAvatarSizeToSmall(_ small: Bool) {
        if small {
            resizeAvatar(to: 32, offset: 27, animated: true)
            isAvatarSmall = true
        } else {
            resizeAvatar(to: 64, offset: 23, animated: true)
            isAvatarSmall = false
        }
    }
    
    func resizeAvatar(to size: CGFloat, offset: CGFloat, animated: Bool) {
        teamImageWidthConstraint.constant = size
        teamImageTopOffsetConstraint.constant = offset
        if animated {
            UIView.animate(withDuration: 0.3, animations: { 
                self.view.layoutIfNeeded()
            })
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

}

// MARK: UICollectionViewDataSource
extension JoinTeamVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        at indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout
extension JoinTeamVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let offset: CGFloat = 16 * 2
        return CGSize(width: collectionView.bounds.width - offset, height: collectionView.bounds.height - 30)
    }
}
