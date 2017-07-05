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
    func votingScroller(controller: VotingScrollerVC, middleCellRow: Int)
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
    var middleCellRow: Int = -1 {
        didSet {
            delegate?.votingScroller(controller: self, middleCellRow: middleCellRow)
            colorizeCenterCell()
        }
    }
    
    weak var delegate: VotingScrollerDelegate?
    
    func updateWithRiskScale(riskScale: RiskScaleEntity) {
        dataSource.onUpdate = { [weak self] in
            self?.collectionView.reloadData()
        }
        dataSource.createModels(with: riskScale)
    }
    
    func colorizeCenterCell() {
        let indexPath = IndexPath(row: middleCellRow, section: 0)
        guard let cell = collectionView.cellForItem(at: indexPath) as? VotingScrollerCell else { return }
        
        collectionView.visibleCells.forEach { cell in
            if let cell = cell as? VotingScrollerCell {
                if cell.centerLabel.text == "" || cell.centerLabel.text == nil {
                    cell.topLabel.alpha = 0
                }
                if cell.isCentered {
                    cell.column.setup(colors: [.lightPeriwinkleTwo, .lavender], locations: [0, 0.8])
                    cell.topLabel.backgroundColor = UIColor.perrywinkle
                    cell.isCentered = false
                }
            }
            UIView.performWithoutAnimation {
                cell.layoutIfNeeded()
            }
        }
    
        cell.topLabel.isHidden = false
        cell.isCentered = true
        
        cell.column.setup(colors: [.blueWithAHintOfPurple, .perrywinkle], locations: [0, 0.8])
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState], animations: {
            cell.topLabel.alpha = 1
            cell.topLabel.backgroundColor = UIColor.blueWithAHintOfPurple
        }) { finished in
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        if let path = collectionView.indexPathForItem(at: CGPoint(x: collectionView.bounds.midX,
                                                                  y: collectionView.bounds.midY)),
            path.row != middleCellRow {
            middleCellRow = path.row
        }
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
            cell.topLabel.text = String.formattedNumber(double: model.riskCoefficient)
            cell.centerLabel.text = model.isTeamAverage ? "TEAM\nAVG" : ""
            cell.topLabel.clipsToBounds = true
            cell.topLabel.layer.cornerRadius = 3
            cell.topLabel.layer.borderWidth = 1
            cell.topLabel.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor
            //cell.column.isHidden = model.heightCoefficient == 0
        }
    }
}

extension VotingScrollerVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width * 4 / CGFloat(dataSource.count),
                      height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
