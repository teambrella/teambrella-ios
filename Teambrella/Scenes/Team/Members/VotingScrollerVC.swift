//
//  VotingScrollerVC.swift
//  Scroller
//
//  Created by Екатерина Рыжова on 28.06.17.
//  Copyright © 2017 Екатерина Рыжова. All rights reserved.
//

import UIKit

protocol VotingScrollerDelegate: class {
    func votingScroller(controller: VotingScrollerVC, didChange value: CGFloat)
}

class VotingScrollerVC: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    fileprivate var dataSource = VotingScrollerDataSource()
    var maxValue: CGFloat { return collectionView.contentSize.width - collectionLeftInset - collectionRightInset }
    var collectionLeftInset: CGFloat {
        return (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset.left ?? 0
    }
    var collectionRightInset: CGFloat {
        return (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset.right ?? 0
    }
    
    weak var delegate: VotingScrollerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.createFakeModels()
        collectionView.layer.cornerRadius = 4
        collectionView.layer.borderColor = #colorLiteral(red: 0.9411764706, green: 0.9647058824, blue: 1, alpha: 1).cgColor
        collectionView.layer.borderWidth = 1
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionInset.left = collectionView.frame.width / 2
            layout.sectionInset.right = layout.sectionInset.left
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.votingScroller(controller: self, didChange: scrollView.contentOffset.x)
    }
    
}

extension VotingScrollerVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    }
}

extension VotingScrollerVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        let model = dataSource.models[indexPath.row]
        if let cell = cell as? VotingScrollerCell {
            let multiplier: CGFloat = CGFloat(model.heightCoefficient)
            //cell.heightConstraint = cell.heightConstraint.setMultiplier(multiplier: multiplier)
            cell.columnHeightConstraint.constant = (cell.bounds.height - cell.topLabel.frame.height)
                * multiplier + cell.topLabel.frame.height / 2
            cell.topLabel.text = String(model.riskCoefficient)
            cell.centerLabel.text = model.isTeamAverage ? "TEAM AVG" : ""
            cell.topLabel.clipsToBounds = true
            cell.topLabel.layer.cornerRadius = 3
            cell.topLabel.layer.borderWidth = 1
            cell.topLabel.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        }
    }
}

extension VotingScrollerVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 5, height: collectionView.bounds.height)
    }
}
