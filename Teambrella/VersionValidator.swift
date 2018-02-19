//
/* Copyright(C) 2018 Teambrella, Inc.
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

struct VersionValidator {
    let router: MainRouter

    @discardableResult
    func validate(serverReply: ServerReply) -> Bool {
        let application = Application()
        guard let currentBuild = Int(application.build) else { return false }

        let serverRecommendedBuild = serverReply.status.recommendedVersion
        let result = currentBuild >= serverRecommendedBuild
        if result == false {
            presentOldVersionNotificationIfNeeded()
        }
        return result
    }

    func presentOldVersionNotificationIfNeeded() {
        let simpleStorage = SimpleStorage()
        let now = Date()
        // no need to show notification more than once in 3 days
        if let lastShownDate = simpleStorage.date(forKey: .outdatedVersionLastShowDate),
            now < lastShownDate.add(components: [.day: 3]) {
                return
        }
        guard let vc = router.frontmostViewController else { return }

        simpleStorage.store(date: now, forKey: .outdatedVersionLastShowDate)
        router.showSOD(mode: .oldVersion, in: vc)
    }

}
