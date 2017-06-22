//
//  ButtonBarPagerTabStripViewController.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import XLPagerTabStrip

extension ButtonBarPagerTabStripViewController {
    func setupTeambrellaTabLayout() {
        settings.style.buttonBarBackgroundColor = .clear
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = .teambrellaLightBlue
        settings.style.buttonBarItemFont = UIFont.teambrellaBold(size: 14)
        settings.style.selectedBarHeight = 4.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .white50
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        changeCurrentIndexProgressive = { oldCell, newCell, progressPercentage, changeCurrentIndex, animated -> Void in
            guard changeCurrentIndex == true else { return }
            
            oldCell?.label.textColor = .white50
            newCell?.label.textColor = .white
        }
    }
}
