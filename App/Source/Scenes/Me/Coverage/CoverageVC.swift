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

import PKHUD
import UIKit
import XLPagerTabStrip

class CoverageVC: UIViewController, Routable {
    
    @IBOutlet var upperView: UIView!
    @IBOutlet var radarView: RadarView!
    @IBOutlet var gradientView: GradientView!
    @IBOutlet var coverageTop: UILabel!
    @IBOutlet var coverageCurrency: UILabel!
    @IBOutlet var weatherImage: UIImageView!
    
    @IBOutlet var sliderBlock: UIView!
    @IBOutlet var warningBlock: UIStackView!
    @IBOutlet var coverageActionButton: BorderedButton!
    @IBOutlet var warningBackround: UIView!
    @IBOutlet var warningText: UILabel!
    @IBOutlet var warningBlockBottom: UIView!

    @IBOutlet var dataBlock: UIView!
    @IBOutlet var umbrellaView: UmbrellaView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var desiredCoverageLabel: UILabel!
    @IBOutlet var slider: UISlider!
    @IBOutlet var desiredAmount: AmountWithCurrency!

    @IBOutlet var currentCoverageLabel: UILabel!
    @IBOutlet var currentCoverageAmount: AmountWithCurrency!
    @IBOutlet var maxPaymentLabel: UILabel!
    @IBOutlet var maxPaymentAmount: AmountWithCurrency!
    @IBOutlet var teammatesLabel: UILabel!
    @IBOutlet var teammatesAmount: AmountLabel!

    var lastMovedSlider: Date?
    var showCheckSettings = false
    var showLimitIncrease = false
    var showInvite = false
    var showFund = false
    var showDecreaseWarning = false
    var currency: String = ""

    @IBOutlet var silderBottomContstraint: NSLayoutConstraint!
    
    lazy var secretRecognizer: UILongPressGestureRecognizer = {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(secretTap))
        recognizer.minimumPressDuration = 8
        return recognizer
    }()
    
    var effectiveLimit: Int = 0 {
        didSet {
            coverageTop.text = String(effectiveLimit)
            coverageActionButton.isEnabled = true
            setImage(for: effectiveLimit)
        }
    }
    var limitAmount: Int = 0 {
        didSet {
            //upperAmount.amountLabel.text = String.truncatedNumber(limitAmount)
        }
    }
    
    @IBAction func tapCoverageActionButton(_ sender: Any) {
        if (showDecreaseWarning) {
            let desiredLimit = getDesiredLimit(from: slider)
            saveDesiredCoverage(coverage: Int(desiredLimit))
        }
        else if (showFund) {
            service.router.switchToWallet()
        }
        else if (showInvite) {
            ShareController().shareInvitation(in: self)
        }
    }
    
    static var storyboardName = "Me"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        umbrellaView.startCurveCoeff = 1.1
        umbrellaView.fillColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

        let session = service.session
        
        currency = session?.currentTeam?.currency ?? ""
        coverageCurrency.text = currency
        desiredAmount.currencyLabel.text = currency
        currentCoverageAmount.currencyLabel.text = currency
        maxPaymentAmount.currencyLabel.text = currency

        titleLabel.text = "Me.CoverageVC.title".localized
        subtitleLabel.text = "Me.CoverageVC.subtitle".localized
        //upperLabel.text = "Me.CoverageVC.maxExpenses".localized
        desiredCoverageLabel.text = "Me.CoverageVC.desirableLimit".localized
        desiredAmount.backView.backgroundColor = #colorLiteral(red: 0.7411764706, green: 0.7647058824, blue: 1, alpha: 0.2)
        teammatesAmount.textAlignment = NSTextAlignment.right
        //lowerLabel.text = "Me.CoverageVC.teamPay".localized

        currentCoverageLabel.text = "Me.CoverageVC.currentCoverage".localized
        maxPaymentLabel.text = "Me.CoverageVC.possiblePayment".localized
        teammatesLabel.text = "Me.CoverageVC.teammatesWouldPay".localized

        slider.addTarget(self, action: #selector(changeValues), for: .valueChanged)
        slider.isExclusiveTouch = true
    
        titleLabel.isUserInteractionEnabled = true
        titleLabel.addGestureRecognizer(secretRecognizer)
        ViewDecorator.shadow(for: upperView, opacity: 0.1, radius: 5)
        
        sliderBlock.layer.cornerRadius = 4
        ViewDecorator.shadow(for: sliderBlock, opacity: 0.1, radius: 5)

        dataBlock.layer.cornerRadius = 4
        ViewDecorator.shadow(for: dataBlock, opacity: 0.1, radius: 5)

        warningBackround.layer.cornerRadius = 4

        warningBlock.visibility = .gone
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    @objc
    func secretTap(sender: UILongPressGestureRecognizer) {
        let alert = UIAlertController(title: "Secret BTC key",
                                      message: service.keyStorage.privateKey,
                                      preferredStyle: .actionSheet)
        let copy = UIAlertAction(title: "Copy", style: .default) { action in
            UIPasteboard.general.string = service.keyStorage.privateKey
        }
        alert.addAction(copy)
        let close = UIAlertAction(title: "Close", style: .cancel, handler: nil)
        alert.addAction(close)
        present(alert, animated: true, completion: nil)
    }
    
    func setImage(for percentage: Int) {
        switch percentage {
        case 90...100: weatherImage.image = #imageLiteral(resourceName: "confetti-umbrella")
        case 80...89: weatherImage.image  = #imageLiteral(resourceName: "rain-1")
        default: weatherImage.image       = #imageLiteral(resourceName: "rain")
        }
    }
    
    func setControls(from wallet: WalletEntity) {
        currentCoverageAmount.alpha = 1
        maxPaymentAmount.alpha = 1
        teammatesAmount.alpha = 1
        coverageTop.alpha = 1
        coverageCurrency.alpha = 1

        let covPart = wallet.coveragePart
        effectiveLimit = Int(covPart.claimLimit)

        limitAmount = covPart.teamClaimLimit ?? 1000
        currentCoverageAmount.amountLabel.text = String.truncatedNumber(covPart.claimLimit)
        maxPaymentAmount.amountLabel.text = String.truncatedNumber(covPart.maxPayment)
        teammatesAmount.text = String(covPart.teammatesAtEffLimit)
        if let slider = slider {
            HUD.hide()
            slider.value = Float(covPart.desiredLimit) / Float(limitAmount)
            self.setValues(slider: slider)
        }
        
        showCheckSettings = false
        showLimitIncrease = false
        showInvite = false
        showFund = false
        
        if (covPart.coverage.value <= 0 && covPart.wasCoverageSuppressed) {
            showCheckSettings = true
        }
        else if (covPart.nextLimit > Double(effectiveLimit) * 1.2) {
            showLimitIncrease = true
        }
        else if (covPart.teammatesAtEffLimit > covPart.teammatesAtLimit) {
            showInvite = true
        }
        else if (covPart.nextLimit * 1.01 < covPart.desiredLimit) {
            showFund = true
        }
        else if (covPart.nextLimit > Double(effectiveLimit) * 1.01) {
            showLimitIncrease = true
        }

        warningBlock.visibility = .gone
        warningBlockBottom.visibility = .gone
        coverageActionButton.visibility = .gone
        coverageActionButton.setTitle("", for: .normal)

        if (showFund || showCheckSettings || showInvite || showLimitIncrease) {
            warningBlock.visibility = .visible
        }

        if (showFund || showInvite) {
            warningBlockBottom.visibility = .visible
            coverageActionButton.visibility = .visible
        }

        if (showLimitIncrease) {
            warningText.text = "Me.CoverageVC.explanationIncrease".localized(Int(covPart.nextLimit), currency)
            warningBackround.backgroundColor = UIColor.ligherGold
        }
        else if (showFund) {
            warningText.text = "Me.CoverageVC.explanationFund".localized
            coverageActionButton.setTitle("Me.CoverageVC.fundWallet".localized, for: .normal)
            warningBackround.backgroundColor = UIColor.ligherGold
        }
        else if (showCheckSettings) {
            warningText.text = "Me.CoverageVC.explanationSettings".localized
            //coverageActionButton.setTitle("Me.CoverageVC.checkSettings".localized, for: .normal)
            warningBackround.backgroundColor = UIColor.ligherGold
        }
        else if (showInvite) {
            warningText.text = "Me.CoverageVC.explanationNeedMoreTeammates".localized(covPart.teammatesAtLimit)
            coverageActionButton.setTitle("Team.MembersVC.inviteAFriend".localized, for: .normal)
            warningBackround.backgroundColor = UIColor.ligherGold
        }
        if (!(covPart.text ?? "").isEmpty && (showFund || showInvite || showCheckSettings)) {
            warningText.text = covPart.text
        }

    }
    
    
    func showDecreaseCoverageWarning() {
        warningBlock.visibility = .visible
        warningBlockBottom.visibility = .visible
        coverageActionButton.visibility = .visible
        warningText.text = "Me.CoverageVC.reductionWarning".localized
        coverageActionButton.setTitle("Me.CoverageVC.coverageReductionButton".localized, for: .normal)
        warningBackround.backgroundColor = UIColor.lightGold
        showDecreaseWarning = true
    }
    
    
    func loadData() {
        guard let teamID = service.session?.currentTeam?.teamID else { return }
        HUD.show(.progress, onView: view)
        service.dao.requestWallet(teamID: teamID).observe { [weak self] result in
            switch result {
            case let .value(wallet):
                self?.setControls(from: wallet)
            case .error:
                break
            }
        }
    }

    func saveDesiredCoverage(coverage: Int) {
        guard let teamID = service.session?.currentTeam?.teamID else { return }
        HUD.show(.progress, onView: view)

        showDecreaseWarning = false
        warningBlock.visibility = .gone
        coverageActionButton.setTitle("", for: .normal)
        currentCoverageAmount.alpha = 0.3
        maxPaymentAmount.alpha = 0.3
        teammatesAmount.alpha = 0.3
        coverageTop.alpha = 0.3
        coverageCurrency.alpha = 0.3

        service.dao.setLimit(teamID: teamID, claimLimit: coverage).observe { [weak self] result in
            switch result {
            case let .value(wallet):
                self?.setControls(from: wallet)
            case .error:
                break
            }
        }
    }
    
    func getDesiredLimit(from slider: UISlider) -> Double {
        let sliderScale = Double(limitAmount) / 100
        return (Double(slider.value) * Double(limitAmount) / sliderScale).rounded() * sliderScale
    }
    
    func setValues(slider: UISlider) {
        desiredAmount.amountLabel.text = String.truncatedNumber(getDesiredLimit(from: slider))
    }

    @objc
    func changeValues(slider: UISlider) {
        setValues(slider: slider)
        lastMovedSlider = Date()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { [weak self] in
            if let lastUpdate = self?.lastMovedSlider {
                let difference = Date().timeIntervalSince(lastUpdate)
                if difference > 0.99 {
                    self?.lastMovedSlider = nil
                    let desiredLimit = self?.getDesiredLimit(from: slider) ?? 0
                    if (Int(desiredLimit) < (self?.effectiveLimit ?? 0)) {
                        self?.showDecreaseCoverageWarning()
                    } else {
                        self?.saveDesiredCoverage(coverage: Int(desiredLimit))
                    }
                }
            }
            
        })

    }
    
}

extension CoverageVC: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Me.CoverageVC.indicatorTitle".localized)
    }
}
