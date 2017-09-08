//
//  CoverageVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.

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
    
    var coverageAmount: Int = 0 {
        didSet {
            coverage.text = String(coverageAmount)
            fundWalletButton.isEnabled = coverageAmount != 100
            fundWalletButton.alpha = (coverageAmount == 100) ? 0.5 : 1
            setImage(for: coverageAmount)
        }
    }
    var limitAmount: Double = 0 {
        didSet {
            upperAmount.amountLabel.text = String.truncatedNumber(limitAmount)
        }
    }
    
    @IBAction func tapFundWalletButton(_ sender: Any) {
        service.router.switchToWallet()
    }
    
    static var storyboardName = "Me"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        umbrellaView.startCurveCoeff = 1.1
        loadData()
        
        let currency = service.currencySymbol
        upperAmount.currencyLabel.text = currency //
        centerAmount.amountLabel.text = "750" //
        centerAmount.currencyLabel.text = currency //
        lowerAmount.amountLabel.text = "375" //
        lowerAmount.currencyLabel.text = currency //

        fundWalletButton.setTitle("Me.CoverageVC.fundButton".localized, for: .normal)
        titleLabel.text = "Me.CoverageVC.title".localized
        subtitleLabel.text = "Me.CoverageVC.subtitle".localized
        upperLabel.text = "Me.CoverageVC.maxExpenses".localized
        centerLabel.text = "Me.CoverageVC.yourExpenses".localized
        centerAmount.contentView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        lowerLabel.text = "Me.CoverageVC.teamPay".localized
        
        slider.addTarget(self, action: #selector(changeValues), for: .valueChanged)
        slider.isExclusiveTouch = true
    }
    
    func setImage(for percentage: Int) {
        switch percentage {
        case 98...100: weatherImage.image = #imageLiteral(resourceName: "confetti-umbrella")
        case 90...97: weatherImage.image  = #imageLiteral(resourceName: "rain-1")
        default: weatherImage.image       = #imageLiteral(resourceName: "rain")
        }
    }
    
    func loadData() {
        let dateString = Formatter.teambrellaShortDashed.string(from: Date())
        service.server.updateTimestamp { timestamp, error in
            let key = service.server.key
            let body = RequestBody(key: key, payload: ["TeamId": service.session?.currentTeam?.teamID ?? 0,
                                                       "Date": dateString])
            let request = TeambrellaRequest(type: .coverageForDate, body: body, success: { [weak self] response in
                if case .coverageForDate(let coverage, let limit) = response {
                    self?.coverageAmount = Int(coverage * 100)
                    self?.limitAmount = limit
                    if let slider = self?.slider {
                        self?.changeValues(slider: slider)
                    }
                }
                })
            request.start()
        }
    }
    
    @objc func changeValues(slider: UISlider) {
        let expenses = Double(slider.value) * limitAmount
        centerAmount.amountLabel.text = String.truncatedNumber(expenses)
        lowerAmount.amountLabel.text = String.truncatedNumber(expenses * Double(coverageAmount / 100))
    }
    
}

extension CoverageVC: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Me.CoverageVC.indicatorTitle".localized)
    }
}
