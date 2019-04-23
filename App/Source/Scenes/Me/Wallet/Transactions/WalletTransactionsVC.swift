//
//  WalletTransactionsVC.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 01.09.17.
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

import PKHUD
import UIKit

class WalletTransactionsVC: UIViewController, Routable {
    
    static let storyboardName = "Me"
    
    @IBOutlet var headerView: RadarView!
    @IBOutlet var perYearTitle: TitleLabel!
    @IBOutlet var perMonthTitle: TitleLabel!
    @IBOutlet var perYearValue: TitleLabel!
    @IBOutlet var perMonthValue: TitleLabel!
    @IBOutlet var signPerMonthValue: UILabel!
    @IBOutlet var signPerYearValue: UILabel!

    var teamID: Int?
    
    var balance: MEth?
    var reserved: Ether?
    
    var router: MainRouter!
    
    var dataSource: WalletTransactionsDataSource!
    fileprivate var previousScrollOffset: CGFloat = 0
    weak var emptyVC: EmptyVC?
    
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientNavBar()
        headerView.color = .veryLightBlueThree

        signPerYearValue.text = ""
        perYearValue.text = ""
        perYearTitle.text = ""
        signPerMonthValue.text = ""
        perMonthValue.text = ""
        perMonthTitle.text = ""

        HUD.show(.progress, onView: view)
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        title = "Me.WalletVC.WalletTransactionsVC.title".localized
        collectionView.register(WalletTransactionCell.nib, forCellWithReuseIdentifier: WalletTransactionCell.cellID)
        collectionView.register(InfoHeader.nib,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: InfoHeader.cellID)
        guard let teamID = teamID else { return }
        
        dataSource = WalletTransactionsDataSource(teamID: teamID)
        dataSource.onUpdate = { [weak self] in
            HUD.hide()
            self?.collectionView.reloadData()
            self?.showEmptyIfNeeded()
            self?.updateHeaderStats()
        }
        dataSource.onError = { error in
            HUD.hide()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dataSource.loadData()
        setupHeaderView()
    }
    
    func setupHeaderView() {
        headerView.clipsToBounds = false
        ViewDecorator.shadow(for: headerView, opacity: 0.1, radius: 8)
//        objectImageView.layer.masksToBounds = true
//        objectImageView.layer.cornerRadius = 4
//        reportButton.setTitle("Team.Claims.objectView.reportButton.title".localized, for: .normal)
    }

    
    func showEmptyIfNeeded() {
        if dataSource.isEmpty {
            if emptyVC == nil {
                let frame = CGRect(x: self.collectionView.frame.origin.x, y: self.collectionView.frame.origin.y + 44,
                                   width: self.collectionView.frame.width,
                                   height: self.collectionView.frame.height - 44)
                emptyVC = EmptyVC.show(in: self, inView: self.view, frame: frame, animated: false)
                emptyVC?.setImage(image: #imageLiteral(resourceName: "iconVote"))
                emptyVC?.setText(title: "Me.Wallet.Transactions.Empty.title".localized,
                                 subtitle: "Me.Wallet.Transactions.Empty.details".localized)
            }
        } else {
            emptyVC?.remove()
            emptyVC = nil
        }
    }
    
    func updateHeaderStats() {
        var firstItem: WalletTransactionsCellModel? = nil
        if let firstVisiblePos = self.collectionView.indexPathsForVisibleItems.sorted().first {
            firstItem = self.dataSource[firstVisiblePos]
        } else if !self.dataSource.isEmpty {
            firstItem = self.dataSource[IndexPath(row: 0, section: 0)]
        } else {
            return
        }
        
        let currency = service.session?.currentTeam?.currencySymbol ?? ""

        let month = firstItem!.month
        let date = Date(year: month/12, month: month%12, day: 1, hour: 0, minute: 0)
        let yearAmount = firstItem!.amountFiatYear.value
        let signYear: String = yearAmount >= 0.01 ? "+" : yearAmount <= -0.01 ? "-" : ""
        let signYearColor: UIColor = yearAmount > 0.0 ? .tealish : .lipstick
        signPerYearValue.text = signYear
        signPerYearValue.textColor = signYearColor
        perYearTitle.text = String(format:
            ((yearAmount > 0) ? "Me.Wallet.Transactions.incomeForYear" : "Me.Wallet.Transactions.expensesForYear").localized,
            month/12)
        perYearValue.text = String(format:"%.2f %@", abs(yearAmount), currency)
        
        
        let monthAmount = firstItem!.amountFiatMonth.value
        let signMonth: String = monthAmount >= 0.01 ? "+" : monthAmount <= -0.01 ? "-" : ""
        let signMonthColor: UIColor = monthAmount > 0.0 ? .tealish : .lipstick
        signPerMonthValue.text = signMonth
        signPerMonthValue.textColor = signMonthColor
        perMonthTitle.text = String(format:
            ((monthAmount > 0) ? "Me.Wallet.Transactions.incomeForPeriod" : "Me.Wallet.Transactions.expensesForPeriod").localized,
            Formatter.monthName.string(from: date).capitalized)
        perMonthValue.text = String(format:"%.2f %@", abs(monthAmount), currency)

        // Update space below last item
        let lastSection = collectionView.numberOfSections - 1
        if (lastSection >= 0) {
            let lastItemRow = collectionView.numberOfItems(inSection: lastSection) - 1
            let lastItemFrame = collectionView.layoutAttributesForItem(at: IndexPath(row: lastItemRow, section: lastSection))?.frame
            let height = collectionView.bounds.height - (lastItemFrame?.height ?? 0)
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0)
        }
    }
}

// MARK: UICollectionViewDataSource
extension WalletTransactionsVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.sections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.itemsIn(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: WalletTransactionCell.cellID, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                               withReuseIdentifier: InfoHeader.cellID,
                                                               for: indexPath)
    }
}

// MARK: UICollectionViewDelegate
extension WalletTransactionsVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        WalletTransactionsCellBuilder.populate(cell: cell,
                                               indexPath: indexPath,
                                               with: dataSource[indexPath],
                                               cellsCount: dataSource.itemsIn(section:indexPath.section))
        
        if indexPath.section == dataSource.sections - 2 {
            dataSource.loadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        at indexPath: IndexPath) {
        // swiftlint:disable:next empty_count
        if dataSource.sections > 0 {
            guard let view = view as? InfoHeader else { return }
            
            let item = dataSource[indexPath]
            let date = Date(year: item.month/12, month: item.month%12, day: 1, hour: 0, minute: 0)
            view.leadingLabel.text = String(format:"%@ %d", Formatter.monthName.string(from: date).uppercased(), item.month/12)
            view.trailingLabel.text = ""
            
//            val item = mPager.loadedData[position].asJsonObject
//            val date = TimeUtils.getDateFromTicks(item.lastUpdated ?: 0L)
//            //holder.setTitle(java.text.DateFormatSymbols().months[date.month] + " " + (1900+date.year))
//            holder.setTitle(dateFormat.format(date))

            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = dataSource[indexPath]
        if let claimID = model.claimID {
            router.presentClaim(claimID: claimID)
        } else if let balance = balance, let reserved = reserved {
            router.presentWithdraw(balance: balance, reserved: reserved)
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension WalletTransactionsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
}

// MARK: UIScrollViewDelegate
extension WalletTransactionsVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        previousScrollOffset = currentOffset
        self.updateHeaderStats()
    }
}
