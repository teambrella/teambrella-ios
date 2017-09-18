//
//  ChatModelBuilder.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 24.08.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

struct ChatModelBuilder {
    let fragmentParser = ChatFragmentParser()
    var showRate = true
    
    func cellModels(from chatItems: [ChatEntity], width: CGFloat, font: UIFont, isClaim: Bool) -> [ChatCellModel] {
        let heightCalculator = ChatFragmentHeightCalculator(width: width, font: font)
        var result: [ChatCellModel] = []
        var lastDate: Date = Date.distantPast
        for item in chatItems {
            let fragments = fragmentParser.parse(item: item)
            var isMy = false
            service.session?.currentUserID.map { isMy = item.userID == $0 }
            
            let name: String
            let avatar: String
            if isMy == true {
                name = "General.you".localized
                avatar = service.session?.currentUserAvatar ?? ""
            } else {
                name = item.name
                avatar = item.avatar
            }
            let date = item.created
            if date.interval(of: .day, since: lastDate) != 0 {
                result.append(ChatSeparatorCellModel(date: date))
                lastDate = date
            }
            var rateString: String?
            if showRate {
                if let rate = item.vote {
                rateString = isClaim
                    ? "Team.Chat.TextCell.voted_format".localized(String.truncatedNumber(rate * 100))
                    : "Team.Chat.TextCell.Application.voted_format".localized(String.formattedNumber(rate))
                } else {
                    rateString = "Team.Chat.TextCell.notVoted".localized
                }
            } else {
                rateString = nil
            }
            
            let model = ChatTextCellModel(entity: item,
                                          fragments: fragments,
                                          fragmentHeights: heightCalculator.heights(for: fragments),
                                          isMy: isMy,
                                          userName: name,
                                          userAvatar: avatar,
                                          rateText: rateString,
                                          date: date)
            result.append(model)
        }
        return result
    }
    
}
