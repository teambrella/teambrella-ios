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
    service.router.showWallet()
    }
    
    static var storyboardName = "Me"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        umbrellaView.startCurveCoeff = 1.1
        let cov = 10 //
        upperAmount.amountLabel.text = "1200" //
        upperAmount.currencyLabel.text = "USD" //
        centerAmount.amountLabel.text = "750" //
        centerAmount.currencyLabel.text = "USD" //
        lowerAmount.amountLabel.text = "375" //
        lowerAmount.currencyLabel.text = "USD" //

        coverage.text = String(cov)
        setImage(for: cov)
        fundWalletButton.isEnabled = cov != 100
        fundWalletButton.alpha = (cov == 100) ? 0.3 : 1
        fundWalletButton.setTitle("Me.CoverageVC.fundButton".localized, for: .normal)
        titleLabel.text = "Me.CoverageVC.title".localized
        subtitleLabel.text = "Me.CoverageVC.subtitle".localized
        upperLabel.text = "Me.CoverageVC.maxExpenses".localized
        centerLabel.text = "Me.CoverageVC.yourExpenses".localized
        centerAmount.contentView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        lowerLabel.text = "Me.CoverageVC.teamPay".localized
        
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
