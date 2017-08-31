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
    
    func cellModels(from chatItems: [ChatEntity], width: CGFloat, font: UIFont) -> [ChatCellModel] {
        let heightCalculator = ChatFragmentHeightCalculator(width: width, font: font)
        var result: [ChatCellModel] = []
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
            
            let model = ChatTextCellModel(entity: item,
                                          fragments: fragments,
                                          fragmentHeights: heightCalculator.heights(for: fragments),
                                          isMy: isMy,
                                          userName: name,
                                          userAvatar: avatar,
                                          voteRate: item.vote,
                                          date: date)
            result.append(model)
        }
        return result
    }
    
}
