//
//  CoverageVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class CoverageVC: UIViewController, Routable {
    
    @IBOutlet var radarView: RadarView!
    @IBOutlet var gradientView: GradientView!
    @IBOutlet var coverage: UILabel!
    @IBOutlet var fundWalletButton: BorderedButton!
    @IBOutlet var weatherImage: UIImageView!
    
    @IBOutlet var subcontainer: UIView!
    @IBOutlet var umbrellaView: UmbrellaView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var upperLabel: UILabel!
    @IBOutlet var centerLabel: UILabel!
    @IBOutlet var lowerLabel: UILabel!
    @IBOutlet var slider: UISlider!
    @IBOutlet var upperAmount: AmountWithCurrency!
    @IBOutlet var centerAmount: AmountWithCurrency!
    @IBOutlet var lowerAmount: AmountWithCurrency!
    
    @IBAction func tapFundWalletButton(_ sender: Any) {
    }
    
    static var storyboardName = "Me"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        umbrellaView.startCurveCoeff = 1.1
        let cov = 60
        coverage.text = String(cov)
        setImage(for: cov)
        fundWalletButton.isEnabled = cov == 100
        fundWalletButton.alpha = (cov == 100) ? 30 : 100
        fundWalletButton.setTitle("Fund the wallet to increase", for: .normal)
        titleLabel.text = "HOW IT WORKS"
        subtitleLabel.text = "Use the slider to understand how Expenses impact your maximum reimbursement."
        upperLabel.text = "Max Expenses covered"
        upperAmount.amountLabel.text = "1200"
        upperAmount.currencyLabel.text = "USD"
        centerLabel.text = "In case your Expenses are"
        centerAmount.amountLabel.text = "750"
        centerAmount.currencyLabel.text = "USD"
        centerAmount.contentView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        lowerLabel.text = "The team would pay you up to"
        lowerAmount.amountLabel.text = "375"
        lowerAmount.currencyLabel.text = "USD"
    }
    
    func setImage(for percentage: Int) {
        switch percentage {
        case 100: weatherImage.image = #imageLiteral(resourceName: "confetti-umbrella")
        case 96...99: weatherImage.image = #imageLiteral(resourceName: "rain-1")
        default: weatherImage.image = #imageLiteral(resourceName: "rain")
        }
    }
}

extension CoverageVC: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Me.CoverageVC.indicatorTitle".localized)
    }
}
