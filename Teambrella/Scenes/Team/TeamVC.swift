//
//  TeamVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 25.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class TeamVC: ButtonBarPagerTabStripViewController {
    
    override func viewDidLoad() {
        setup()
        super.viewDidLoad()

        navigationController?.navigationBar.barTintColor = .clear
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setup() {
        settings.style.buttonBarBackgroundColor = .clear
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = .teambrellaLightBlue
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        settings.style.selectedBarHeight = 4.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .whiteHalfTransparent
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        changeCurrentIndexProgressive = { oldCell, newCell, progressPercentage, changeCurrentIndex, animated -> Void in
            guard changeCurrentIndex == true else { return }
            
            oldCell?.label.textColor = .whiteHalfTransparent
            newCell?.label.textColor = .white
        }
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let feed = UIStoryboard(name: "Team", bundle: nil).instantiateViewController(withIdentifier: "FeedVC")
        let members = UIStoryboard(name: "Team", bundle: nil).instantiateViewController(withIdentifier: "MembersVC")
        let claims = UIStoryboard(name: "Team", bundle: nil).instantiateViewController(withIdentifier: "ClaimsVC")
        let rules = UIStoryboard(name: "Team", bundle: nil).instantiateViewController(withIdentifier: "RulesVC")
        return [feed, members, claims, rules]
    }
}
