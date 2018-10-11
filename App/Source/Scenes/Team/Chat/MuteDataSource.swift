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
    let models: [MuteCellModel] = [
        MuteCellModel(icon: #imageLiteral(resourceName: "iconBell"),
                      topText: "Team.Notifications.often".localized,
                      bottomText: "",
                      type: TeamNotificationsFrequencyType.often),
        
        MuteCellModel(icon: #imageLiteral(resourceName: "iconBell"),
                      topText: "Team.Notifications.occasionally".localized,
                      bottomText: "",
                      type: TeamNotificationsFrequencyType.occasionally),
        MuteCellModel(icon: #imageLiteral(resourceName: "iconBell"),
                      topText: "Team.Notifications.rarely".localized,
                      bottomText: "",
                      type: TeamNotificationsFrequencyType.rarely),
        MuteCellModel(icon: #imageLiteral(resourceName: "iconBellMuted"),
                      topText: "Team.Notifications.never".localized,
                      bottomText: "",
                      type: TeamNotificationsFrequencyType.never)
    ]
}

