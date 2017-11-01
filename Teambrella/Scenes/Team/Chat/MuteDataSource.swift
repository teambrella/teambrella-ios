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

struct MuteDataSource {
    var count: Int { return models.count }
    var models: [MuteCellModel] = []
    
    mutating func createModels() {
        models = [MuteCellModel(icon: #imageLiteral(resourceName: "teambrella-round-logo"),
                                topText: "Team.Chat.NotificationSettings.subscribed".localized,
                                bottomText: "Team.Chat.NotificationSettings.subscribed.details".localized),
                  MuteCellModel(icon: #imageLiteral(resourceName: "teambrella-round-logo"),
                                topText: "Team.Chat.NotificationSettings.unsubscribed".localized,
                                bottomText: "Team.Chat.NotificationSettings.unsubscribed.details".localized)]
    }
    
    subscript(indexPath: IndexPath) -> MuteCellModel {
        return models[indexPath.row]
    }
    
}
