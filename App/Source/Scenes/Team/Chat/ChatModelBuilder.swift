//
//  ChatModelBuilder.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 24.08.17.
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

import UIKit

class ChatModelBuilder {
    let fragmentParser = ChatFragmentParser()
    
    var showRate = false
    var showTheirAvatar = false
    
    var isPrivateChat: Bool { return !showTheirAvatar }
    
    var font: UIFont = UIFont.teambrella(size: 14)
    var width: CGFloat = 0
    lazy var heightCalculator = ChatFragmentSizeCalculator(width: width, font: font)
    
    func separatorModelIfNeeded(firstModel: ChatCellModel, secondModel: ChatCellModel) -> ChatCellModel? {
        guard !(firstModel is ChatSeparatorCellModel), !(secondModel is ChatSeparatorCellModel) else { return nil }
        
        if firstModel.date.interval(of: .day, since: secondModel.date) != 0 {
            let calendar = Calendar.current
            let components = calendar.dateComponents([Calendar.Component.day,
                                                      Calendar.Component.month,
                                                      Calendar.Component.year], from: secondModel.date)
            let date = calendar.date(from: components)
            return date.flatMap { ChatSeparatorCellModel(date: $0) }
        }
        return nil
    }

    func serviceModel(from model: ChatEntity) -> ChatCellModel? {
        guard let type = model.systemType else { return nil }

        var size = TextSizeCalculator().size(for: model.text, font: font, maxWidth: width)
        switch type {
        case .needsFunding:
            return ServiceMessageWithButtonCellModel(date: model.created,
                                                     text: model.text,
                                                     buttonText: "Team.Chat.PayToJoin.buttonTitle".localized,
                                                     size: size)
        case .firstPhotoMissing, .firstPostMissing:
            return ServiceMessageCellModel(date: model.created, text: model.text, size: size)
        }
    }

    func cellModels(from chatItems: [ChatEntity],
                    isClaim: Bool,
                    isTemporary: Bool) -> [ChatCellModel] {
        var result: [ChatCellModel] = []
        
        for item in chatItems {
            // add service messages
            if let model = serviceModel(from: item) {
                result.append(model)
                continue
            }

            let fragments = fragmentParser.parse(item: item)
            var isMy = false
            if let session = service.session {
                isMy = item.userID == session.currentUserID
            }
            
            let name: Name
            let avatar: Avatar?
            if isMy == true {
                name = isPrivateChat ? Name.empty : Name(fullName: "General.you".localized)
                avatar = service.session?.currentUserAvatar ?? Avatar.none
            } else {
                name = item.teammate?.name ?? Name.empty
                avatar = showTheirAvatar ? item.teammate?.avatar : nil
            }
            
            let date = item.created
            let rateString = rateText(rate: item.teammate?.vote, showRate: showRate, isClaim: isClaim)
            
            let model: ChatCellUserDataLike

            if fragments.count == 1, let fragment = fragments.first, case .image = fragment {
                model = ChatImageCellModel(entity: item,
                                           fragments: fragments,
                                           fragmentSizes: heightCalculator.sizes(for: fragments),
                                           isMy: isMy,
                                           userAvatar: avatar,
                                           date: date,
                                           isTemporary: isTemporary)
            } else {
                model = ChatTextCellModel(entity: item,
                                          fragments: fragments,
                                          fragmentSizes: heightCalculator.sizes(for: fragments),
                                          isMy: isMy,
                                          userName: name,
                                          userAvatar: avatar,
                                          rateText: rateString,
                                          date: date,
                                          isTemporary: isTemporary)
            }
            result.append(model)
        }
        return result
    }
    
    func rateText(rate: Double?, showRate: Bool, isClaim: Bool) -> String? {
        let rateString: String?
        if showRate {
            if let rate = rate {
                rateString = isClaim
                    ? "Team.Chat.TextCell.voted_format".localized(String.truncatedNumber(rate * 100))
                    : "Team.Chat.TextCell.Application.voted_format".localized(String.formattedNumber(rate))
            } else {
                rateString = "Team.Chat.TextCell.notVoted".localized
            }
        } else {
            rateString = nil
        }
        return rateString
    }
    
}
