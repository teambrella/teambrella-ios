//
//  ReportVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 24.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class ReportVC: UIViewController, Routable {
    static let storyboardName: String = "Me"
    
    @IBOutlet var collectionView: UICollectionView!
    let dataSource: ReportDataSource = ReportDataSource(reportType: .claim)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTransparentNavigationBar()
        defaultGradientOnTop()
        automaticallyAdjustsScrollViewInsets = false
        ReportCellBuilder.registerCells(in: collectionView)
        title = "Report a Claim"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showSubmitButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showSubmitButton()
    }
    
    private func showSubmitButton() {
        navigationItem.setRightBarButton(UIBarButtonItem(title: "Submit",
                                                         style: .done,
                                                         target: self,
                                                         action: #selector(tapSubmit(_:))),
                                         animated: false)
    }
    
    func tapSubmit(_ sender: UIButton) {
        print("tap Submit")
    }
    
}

// MARK: UICollectionViewDataSource
extension ReportVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return ReportCellBuilder.dequeueCell(in: collectionView, indexPath: indexPath, type: dataSource[indexPath])
    }
    
}

// MARK: UICollectionViewDelegate
extension ReportVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout
extension ReportVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat!
        switch dataSource[indexPath] {
        case .item:
            height = 120
        case .date, .wallet:
            height = 80
        case .expenses:
            height = 160
        case .description:
            height = 170
        case .photos:
            height = 145
        }
        return CGSize(width: collectionView.bounds.width - 16 * 2, height: height)
    }
}
