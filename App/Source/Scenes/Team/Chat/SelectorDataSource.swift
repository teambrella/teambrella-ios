//
/* Copyright(C) 2017 Teambrella, Inc.
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

import Foundation

protocol SelectorDataSource {
    var header: String { get }
    var count: Int { get }
    var models: [SelectorCellModel] { get }
    var isHidingOnSelection: Bool { get }
    
    func index(for type: SelectorItemsType) -> Int?
    func type(for index: Int) -> SelectorItemsType
    
    subscript(index: IndexPath) -> SelectorCellModel { get }
}

extension SelectorDataSource {
    var count: Int { return models.count }
    
    subscript(indexPath: IndexPath) -> SelectorCellModel {
        return models[indexPath.row]
    }
    
    func index(for type: SelectorItemsType) -> Int? {
        for (idx, model) in models.enumerated() where model.type.rawValue == type.rawValue {
            return idx
        }
        return nil
    }
    
    func type(for index: Int) -> SelectorItemsType {
        return models[index].type
    }
}

struct ChatMuteDataSource: SelectorDataSource {
    let header = "Team.Chat.NotificationSettings.title".localized
    let isHidingOnSelection: Bool = true
    let models: [SelectorCellModel] = [
        SelectorCellModel(icon: #imageLiteral(resourceName: "iconBell"),
                      topText: "Team.Chat.NotificationSettings.subscribed".localized,
                      bottomText: "Team.Chat.NotificationSettings.subscribed.details".localized,
                      type: MuteType.unmuted),
        
        SelectorCellModel(icon: #imageLiteral(resourceName: "iconBellMuted"),
                      topText: "Team.Chat.NotificationSettings.unsubscribed".localized,
                      bottomText: "Team.Chat.NotificationSettings.unsubscribed.details".localized,
                      type: MuteType.muted)
    ]
}

struct NotificationsMuteDataSource: SelectorDataSource {
    let header = "Team.Chat.NotificationSettings.title".localized
    let isHidingOnSelection: Bool = true
    let models: [SelectorCellModel] = [
        SelectorCellModel(icon: #imageLiteral(resourceName: "iconBell"),
                      topText: "Team.Notifications.often".localized,
                      bottomText: "Team.Notifications.Details.often".localized,
                      type: TeamNotificationsType.often),
        
        SelectorCellModel(icon: #imageLiteral(resourceName: "iconBell"),
                      topText: "Team.Notifications.occasionally".localized,
                      bottomText: "Team.Notifications.Details.occasionally".localized,
                      type: TeamNotificationsType.occasionally),
        SelectorCellModel(icon: #imageLiteral(resourceName: "iconBell"),
                      topText: "Team.Notifications.rarely".localized,
                      bottomText: "Team.Notifications.Details.rarely".localized,
                      type: TeamNotificationsType.rarely),
        SelectorCellModel(icon: #imageLiteral(resourceName: "iconBellMuted"),
                      topText: "Team.Notfications.never".localized,
                      bottomText: "Team.Notifications.Details.never".localized,
                      type: TeamNotificationsType.never)
    ]
}

class PinDataSource: SelectorDataSource {
    let header = "Team.Selector.Pin.header".localized.uppercased()
    let isHidingOnSelection: Bool = false
    var teamPinType: PinType = .unknown
    var models: [SelectorCellModel] = []
    
    func getModels(topicID: String, completion: @escaping (PinType) -> Void) {
        service.dao.requestPin(topicID: topicID).observe { [weak self] result in
            switch result {
            case let .value(pin):
                self?.updateModels(pin: pin)
                completion(pin.type)
            case let .error(error):
                log(error)
            }
        }
    }
    
    func updateModels(pin: PinEntity) {
        teamPinType = PinEntity.teamPinType(from: pin.teamVote)
        models = [
            SelectorCellModel(icon: #imageLiteral(resourceName: "PinIconGreen"),
                          topText: pin.pinTitle,
                          bottomText: pin.pinText,
                          type: PinType.pinned),
            SelectorCellModel(icon: #imageLiteral(resourceName: "PinIconRed"),
                          topText: pin.unpinTitle,
                          bottomText: pin.unpinText,
                          type: PinType.unpinned)
        ]
    }
    
    func change(topicID: String, type: PinType, completion: @escaping (PinType) -> Void) {
        service.dao.sendPin(topicID: topicID, pinType: type).observe { [weak self] result in
            switch result {
            case let .value(pin):
                self?.updateModels(pin: pin)
                completion(pin.type)
            case let .error(error):
                log(error)
            }
        }
    }
    
}

struct PostActionsDataSource: SelectorDataSource {
    let header = "Team.Chat.Actions.title".localized
    let model: ChatCellUserDataLike
    var models: [SelectorCellModel]
    let isHidingOnSelection: Bool = true
    
    init(model: ChatCellUserDataLike) {
        self.model = model

        if (model.isMy) {
            models = [
                SelectorCellModel(icon: #imageLiteral(resourceName: "iconMark2"),
                                  topText: "Team.Chat.Actions.summary".localized,
                                  bottomText: "",
                                  type: PostActionType.marked)
                            ]
        } else {
            let name = model.entity.teammate?.name.first
            models = []
            models.append(SelectorCellModel(icon: #imageLiteral(resourceName: "Upvote"),
                                            topText: "Team.Chat.Actions.upvote".localized,
                                            bottomText: "",
                                            type: PostActionType.like))
            models.append(SelectorCellModel(icon: #imageLiteral(resourceName: "Downvote"),
                                            topText: "Team.Chat.Actions.downvote".localized,
                                            bottomText: "",
                                            type: PostActionType.dislike))

            if (model.suggestAddingToProxy || model.myLike > 0) {
                if model.isMyProxy {
                    models.append(SelectorCellModel(icon: #imageLiteral(resourceName: "iconBlueProxy"),
                                                    topText: "Team.Chat.Actions.makeMainProxy".localized(name ?? "Team.Chat.Actions.user".localized),
                                                    bottomText: "Team.Chat.Actions.makeMainProxyComment".localized(name ?? "Team.Chat.Actions.userCaps".localized),
                                                    type: PostActionType.addToProxies))
                }
                else {
                    models.append(SelectorCellModel(icon: #imageLiteral(resourceName: "iconBlueProxy"),
                                                    topText: "Team.Chat.Actions.addToProxy".localized(name ?? "Team.Chat.Actions.user".localized),
                                                    bottomText: "Team.Chat.Actions.addToProxyComment".localized(name ?? "Team.Chat.Actions.userCaps".localized),
                                                    type: PostActionType.addToProxies))
                }
            }
            if (model.suggestRemovingFromProxy || model.myLike < 0) {
                if model.isMyProxy
                {
                    models.append(SelectorCellModel(icon: #imageLiteral(resourceName: "iconStop"),
                                                    topText: "Team.Chat.Actions.removeFromProxies".localized(name ?? "Team.Chat.Actions.user".localized),
                                                    bottomText: "Team.Chat.Actions.removeFromProxiesComment".localized(name ?? "Team.Chat.Actions.userCaps".localized),
                                                    type: PostActionType.removeFromProxies))
                }
            }
        }
    }
}
