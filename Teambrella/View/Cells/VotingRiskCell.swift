//
//  VotingRiskCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 21.09.2017.
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
//

import UIKit

protocol VotingRiskCellDelegate: class {
    func votingRisk(cell: VotingRiskCell, changedOffset: CGFloat)
    func votingRisk(cell: VotingRiskCell, stoppedOnOffset: CGFloat)
    func votingRisk(cell: VotingRiskCell, changedMiddleRowIndex: Int)
}

class VotingRiskCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var titleLabel: BlockHeaderLabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var pieChart: PieChartView!
    
    @IBOutlet var slashView: SlashView!
    @IBOutlet var teamVoteHeaderLabel: InfoLabel!
    @IBOutlet var teamVoteValueLabel: UILabel!
    @IBOutlet var teamVoteBadgeLabel: UILabel!
    @IBOutlet var teammatesAvatarStack: RoundImagesStack!
    
    @IBOutlet var yourVoteHeaderLabel: InfoLabel!
    @IBOutlet var yourVoteValueLabel: UILabel!
    @IBOutlet var yourVoteBadgeLabel: UILabel!
    
    @IBOutlet var resetVoteButton: UIButton!
    
    @IBOutlet var proxyAvatarView: RoundImageView!
    @IBOutlet var proxyNameLabel: InfoLabel!
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var pearLeftAvatar: LabeledRoundImageView!
    @IBOutlet var pearMiddleAvatar: LabeledRoundImageView!
    @IBOutlet var pearRightAvatar: LabeledRoundImageView!
    
    @IBOutlet var othersButton: UIButton!
    
    var maxValue: CGFloat {
        let itemWidth = collectionView(collectionView,
                                       layout: collectionView.collectionViewLayout,
                                       sizeForItemAt: IndexPath(row: 0, section: 0)).width
        return collectionView.contentSize.width - collectionLeftInset - collectionRightInset -  itemWidth
    }
    
    var collectionLeftInset: CGFloat {
        return (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset.left ?? 0
    }
    
    var collectionRightInset: CGFloat {
        return (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset.right ?? 0
    }
    
    var middleCellRow: Int = -1 {
        didSet {
            delegate?.votingRisk(cell: self, changedMiddleRowIndex: middleCellRow)
            colorizeCenterCell()
        }
    }
    
    private var dataSource: VotingScrollerDataSource = VotingScrollerDataSource()
    
    weak var delegate: VotingRiskCellDelegate?
    
    var shouldSilenceScroll: Bool = false
    
    var isProxyHidden: Bool = true {
        didSet {
            proxyAvatarView.isHidden = isProxyHidden
            proxyNameLabel.isHidden = isProxyHidden
            resetVoteButton.isHidden = !isProxyHidden
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.layer.cornerRadius = 4
        collectionView.layer.borderColor = #colorLiteral(red: 0.9411764706, green: 0.9647058824, blue: 1, alpha: 1).cgColor
        collectionView.layer.borderWidth = 1
        
        slashView.layer.cornerRadius = 4
        slashView.layer.borderColor = #colorLiteral(red: 0.9411764706, green: 0.9647058824, blue: 1, alpha: 1).cgColor
        slashView.layer.borderWidth = 1
        
        pearLeftAvatar.isHidden = true
        pearRightAvatar.isHidden = true
      
        titleLabel.text = "Team.VotingRiskVC.headerLabel".localized
        teamVoteHeaderLabel.text = "Team.VotingRiskVC.numberBar.left".localized
        teamVoteBadgeLabel.text = "Team.VotingRiskVC.avgLabel".localized(0)
        
        yourVoteHeaderLabel.text = "Team.VotingRiskVC.numberBar.right".localized
        yourVoteBadgeLabel.text = "Team.VotingRiskVC.avgLabel".localized(0)
   
        resetVoteButton.setTitle("Team.VotingRiskVC.resetVoteButton".localized, for: .normal)
        othersButton.setTitle("Team.VotingRiskVC.othersButton".localized, for: .normal)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(VotingChartCell.nib, forCellWithReuseIdentifier: VotingChartCell.cellID)
        dataSource.onUpdate = { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionInset.left = collectionView.frame.width / 2
            layout.sectionInset.right = layout.sectionInset.left
        }
    }
    
    func updateWithRiskScale(riskScale: RiskScaleEntity) {
        dataSource.onUpdate = { [weak self] in
            self?.collectionView.reloadData()
        }
        dataSource.createModels(with: riskScale)
        collectionView.reloadData()
    }
    
    func colorizeCenterCell() {
        guard middleCellRow >= 0 else { return }
        
        let indexPath = IndexPath(row: middleCellRow, section: 0)
        guard let cell = collectionView.cellForItem(at: indexPath) as? VotingChartCell else { return }
        
        collectionView.visibleCells.forEach { cell in
            if let cell = cell as? VotingChartCell {
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
    
    func scrollToAverage(silently: Bool = true) {
        shouldSilenceScroll = silently
        for (idx, model) in dataSource.models.enumerated() where model.isTeamAverage {
            collectionView.scrollToItem(at: IndexPath(row: idx, section: 0),
                                        at: .centeredHorizontally,
                                        animated: true)
            break
        }
    }
    
    func scrollToCenter(silently: Bool) {
        scrollTo(offset: maxValue / 2, silently: silently)
    }
    
    func scrollTo(offset: CGFloat, silently: Bool) {
        shouldSilenceScroll = silently
        collectionView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
    }
    
}

extension VotingRiskCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: VotingChartCell.cellID, for: indexPath)
    }
}

extension VotingRiskCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        let model = dataSource.models[indexPath.row]
        if let cell = cell as? VotingChartCell {
            let multiplier: CGFloat = CGFloat(model.heightCoefficient)
            //cell.heightConstraint = cell.heightConstraint.setMultiplier(multiplier: multiplier)
            cell.columnHeightConstraint.constant = (cell.bounds.height - cell.topLabel.frame.height)
                * multiplier + cell.topLabel.frame.height / 2
            cell.topLabel.text = String.formattedNumber(model.riskCoefficient)
            cell.centerLabel.text = model.isTeamAverage ? "TEAM\nAVG" : ""
            cell.topLabel.clipsToBounds = true
            cell.topLabel.layer.cornerRadius = 3
            cell.topLabel.layer.borderWidth = 1
            cell.topLabel.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor
            //cell.column.isHidden = model.heightCoefficient == 0
        }
    }
}

extension VotingRiskCell: UICollectionViewDelegateFlowLayout {
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

extension VotingRiskCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if shouldSilenceScroll == false {
            delegate?.votingRisk(cell: self, changedOffset: scrollView.contentOffset.x)
        } else {
            shouldSilenceScroll = false
        }
        if let path = collectionView.indexPathForItem(at: CGPoint(x: collectionView.bounds.midX,
                                                                  y: collectionView.bounds.midY)),
            path.row != middleCellRow {
            middleCellRow = path.row
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            delegate?.votingRisk(cell: self, stoppedOnOffset: scrollView.contentOffset.x)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.votingRisk(cell: self, stoppedOnOffset: scrollView.contentOffset.x)
    }
}
