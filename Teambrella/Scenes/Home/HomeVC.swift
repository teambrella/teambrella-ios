//
//  HomeVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 25.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {
    @IBOutlet var gradientView: GradientView!
    @IBOutlet var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTransparentNavigationBar()
        gradientView.setup(colors: [#colorLiteral(red: 0.1803921569, green: 0.2392156863, blue: 0.7960784314, alpha: 1), #colorLiteral(red: 0.2156862745, green: 0.2705882353, blue: 0.8078431373, alpha: 1), #colorLiteral(red: 0.368627451, green: 0.4156862745, blue: 0.8588235294, alpha: 1)],
                           locations: [0.0, 0.5, 1.0])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension HomeVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print(indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeCollectionCell", for: indexPath)
        if let cell = cell as? HomeCollectionCell {
            cell.setupShadow()
//            cell.leftNumberView.amountLabel.text = "1000"
//            cell.leftNumberView.titleLabel.text = "CLAIMED"
//            cell.leftNumberView.currencyLabel.text = "USD"
//            cell.leftNumberView.isBadgeVisible = false
//            
//            cell.rightNumberView.amountLabel.text = "1000"
//            cell.rightNumberView.titleLabel.text = "TEAM VOTE"
//            cell.rightNumberView.currencyLabel.text = "%"
//            cell.rightNumberView.isBadgeVisible = true
//            cell.rightNumberView.badgeLabel.text = "VOTING"
//            cell.rightNumberView.isCurrencyOnTop = false
        }
        return cell
    }
}

extension HomeVC: UICollectionViewDelegate {
    
}

extension HomeVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width * 0.85, height: collectionView.bounds.height * 0.9)
    }
}
