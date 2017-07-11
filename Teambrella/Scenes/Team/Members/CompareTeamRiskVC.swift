//
//  CompareTeamRiskVC.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 11.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class CompareTeamRiskVC: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    
    let dataSource = MembersDatasource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func registerCells() {
        collectionView.register(InfoHeader.nib,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                withReuseIdentifier: InfoHeader.cellID)
        collectionView.register(RiskCell.nib, forCellWithReuseIdentifier: RiskCell.cellID)
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

extension CompareTeamRiskVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                               withReuseIdentifier: InfoHeader.cellID,
                                                               for: indexPath)
    }
}

extension CompareTeamRiskVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let model = dataSource.models[indexPath.row]
        if let cell = cell as? VotingScrollerCell {
            let multiplier: CGFloat = CGFloat(model.heightCoefficient)
            cell.heightConstraint = cell.heightConstraint.setMultiplier(multiplier: multiplier)
            cell.topLabel.text = String(model.riskCoefficient)
            cell.centerLabel.text = model.isTeamAverage ? "TEAM AVG" : ""
        }
    }
}

extension CompareTeamRiskVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: <#width#>, height: <#height#>)
    }
}
