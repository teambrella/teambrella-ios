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

protocol MuteDataSource {
    var header: String { get }
    var count: Int { get }
    var models: [MuteCellModel] { get }
    
    func index(for type: MuteType) -> Int?
    func type(for index: Int) -> MuteType
    
    subscript(index: IndexPath) -> MuteCellModel { get }
}

extension MuteDataSource {
    var count: Int { return models.count }
    
    subscript(indexPath: IndexPath) -> MuteCellModel {
        return models[indexPath.row]
    }
    
    func index(for type: MuteType) -> Int? {
        for (idx, model) in models.enumerated() where model.type.rawValue == type.rawValue {
            return idx
        }
        return nil
    }
    
    func type(for index: Int) -> MuteType {
        return models[index].type
    }
}

struct ChatMuteDataSource: MuteDataSource {
    let header = "Team.Chat.NotificationSettings.title".localized
    let models: [MuteCellModel] = [
        MuteCellModel(icon: #imageLiteral(resourceName: "iconBell"),
                      topText: "Team.Chat.NotificationSettings.subscribed".localized,
                      bottomText: "Team.Chat.NotificationSettings.subscribed.details".localized,
                      type: ChatMuteType.unmuted),
        
        MuteCellModel(icon: #imageLiteral(resourceName: "iconBellMuted"),
                      topText: "Team.Chat.NotificationSettings.unsubscribed".localized,
                      bottomText: "Team.Chat.NotificationSettings.unsubscribed.details".localized,
                      type: ChatMuteType.muted)
    ]
}

struct NotificationsMuteDataSource: MuteDataSource {
    let header = "Team.Chat.NotificationSettings.title".localized
    let models: [MuteCellModel] = [
        MuteCellModel(icon: #imageLiteral(resourceName: "iconBell"),
                      topText: "Team.Notifications.often".localized,
                      bottomText: "Team.Notifications.Details.often".localized,
                      type: TeamNotificationsFrequencyType.often),
        
        MuteCellModel(icon: #imageLiteral(resourceName: "iconBell"),
                      topText: "Team.Notifications.occasionally".localized,
                      bottomText: "Team.Notifications.Details.occasionally".localized,
                      type: TeamNotificationsFrequencyType.occasionally),
        MuteCellModel(icon: #imageLiteral(resourceName: "iconBell"),
                      topText: "Team.Notifications.rarely".localized,
                      bottomText: "Team.Notifications.Details.never".localized,
                      type: TeamNotificationsFrequencyType.rarely),
        MuteCellModel(icon: #imageLiteral(resourceName: "iconBellMuted"),
                      topText: "Team.Notfications.never".localized,
                      bottomText: "Team.Notifications.Details.never".localized,
                      type: TeamNotificationsFrequencyType.never)
    ]
}

class PinDataSource: MuteDataSource {
    let header = "Прикрепить тему".uppercased()
    var models: [MuteCellModel] = []
    
   func getModels(topicID: String, completion: @escaping (ChatPinType) -> Void) {
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
        models = [
            MuteCellModel(icon: #imageLiteral(resourceName: "iconBell"),
                          topText: pin.pinTitle,
                          bottomText: pin.pinText,
                          type: ChatPinType.pinned),
            MuteCellModel(icon: #imageLiteral(resourceName: "iconBellMuted"),
                          topText: pin.unpinTitle,
                          bottomText: pin.unpinText,
                          type: ChatPinType.unpinned)
        ]
    }
    
    func change(topicID: String, type: ChatPinType) {
        service.dao.sendPin(topicID: topicID, pinType: type).observe { [weak self] result in
            switch result {
            case let .value(pin):
                self?.updateModels(pin: pin)
            case let .error(error):
                log(error)
            }
        }
    }
    
}
