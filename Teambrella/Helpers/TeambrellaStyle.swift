//
//  TeambrellaStyle.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 31.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

struct TeambrellaStyle {
    static func apply() {
        navigationStyle()
        labelStyle()
        buttonStyle()
    }
    
    static func navigationStyle() {
        let navigationBar = UINavigationBar.appearance()
        //        navigationBar.setBackgroundImage(UIImage(), for: .default)
        //        navigationBar.shadowImage = UIImage()
        navigationBar.barTintColor = .teambrellaBlue
        navigationBar.tintColor = .white
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
    
    // swiftlint:disable:next function_body_length
    static func labelStyle() {
        let header = HeaderLabel.appearance()
        header.font = UIFont.teambrellaBold(size: 25)
        header.textColor = .white
        
        let subHeader = SubheaderLabel.appearance()
        subHeader.font = UIFont.teambrellaBold(size: 13)
        subHeader.textColor = .white50
        
        let amount = AmountLabel.appearance()
        amount.font = UIFont.teambrellaBold(size: 23)
        amount.textColor = .dark
        
        let walletAmount = WalletAmountLabel.appearance()
        walletAmount.font = UIFont.teambrellaBold(size: 88)
        walletAmount.textColor = .dark
        
        let currency = CurrencyLabel.appearance()
        currency.font = UIFont.teambrellaBold(size: 9)
        currency.textColor = .darkSkyBlue
        
        let currencyNormal = CurrencyNormalLabel.appearance()
        currencyNormal.font = UIFont.teambrellaBold(size: 23)
        currencyNormal.textColor = .darkSkyBlue
        
        let badge = BadgeLabel.appearance()
        badge.font = UIFont.teambrella(size: 9)
        badge.textColor = .white
        badge.backgroundColor = .lightBlue
        
        let info = InfoLabel.appearance()
        info.font = UIFont.teambrellaBold(size: 10)
        info.textColor = .blueyGray
        
        let infoHelp = InfoHelpLabel.appearance()
        infoHelp.font = UIFont.teambrellaBold(size: 10)
        
        let itemName = ItemNameLabel.appearance()
        itemName.font = UIFont.teambrella(size: 15)
        itemName.textColor = .charcoalGray
        
        let itemValue = ItemValueLabel.appearance()
        itemValue.font = UIFont.teambrella(size: 15)
        itemValue.textColor = .battleshipGray
        
        let title = TitleLabel.appearance()
        title.font = UIFont.teambrellaBold(size: 20)
        title.textColor = .charcoalGray
        
        let thinStatusSubtitle = ThinStatusSubtitleLabel.appearance()
         thinStatusSubtitle.font = UIFont.teambrella(size: 10)
        thinStatusSubtitle.textColor = .blueyGray
        
        let statusSubtitle = StatusSubtitleLabel.appearance()
        statusSubtitle.font = UIFont.teambrellaBold(size: 12)
        statusSubtitle.textColor = .blueyGray
        
        let blockHeader = BlockHeaderLabel.appearance()
        blockHeader.font = UIFont.teambrellaBold(size: 14)
        blockHeader.textColor = .darkSkyBlue
        
        let messageTitle = MessageTitleLabel.appearance()
        messageTitle.font = UIFont.teambrellaBold(size: 15)
        messageTitle.textColor = .dark
        
        let messageText = MessageTextLabel.appearance()
        messageText.font = UIFont.teambrella(size: 12)
        messageText.textColor = .bluishGray
        
        let chatText = ChatTextLabel.appearance()
        chatText.font = UIFont.teambrella(size: 14)
        chatText.textColor = .charcoalGray
    }
    
    static func buttonStyle() {
        let label = UILabel.appearance(whenContainedInInstancesOf: [BorderedButton.self])
        label.textColor = .lightBlue
        label.font = UIFont.teambrellaBold(size: 15)
    }
    
}

/*
 let view = UIView.appearance(whenContainedInInstancesOf: [UIWindow.self])
 view.backgroundColor = .teambrellaBlue
 
 let label = UILabel.appearance()
 label.textColor = .white
 label.backgroundColor = .clear
 
 let button = UIButton.appearance()
 button.setTitleColor(.white, for: .normal)
 button.backgroundColor = .clear
 
 let tabBar = UITabBar.appearance()
 tabBar.backgroundColor = .clear
 tabBar.barTintColor = .teambrellaBlue
 tabBar.tintColor = .white
 tabBar.backgroundImage = UIImage()
 tabBar.shadowImage = UIImage()
 */
