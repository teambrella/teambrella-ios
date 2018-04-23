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

struct SODManager {
    let router: MainRouter
    let storage = SimpleStorage()

    func checkVersion(serverReply: ServerReply) {
        let validator = VersionValidator(router: router)
        let isValid = validator.validate(serverReply: serverReply)
        if !isValid {
             presentOldVersionNotificationIfNeeded()
        }
    }

    func checkSilentPush(infoMaker: InfoMaker) {
        if infoMaker.isSilentPushAvailable == false {
            presentSilentPushNotificationIfNeeded()
        }
    }

    func showCriticallyOldVersion() {
        guard let vc = router.frontmostViewController else { return }

        router.showSOD(mode: .criticallyOldVersion, in: vc)
    }

    func showOutdatedDemo(in vc: UIViewController?) -> SODVC? {
        guard let vc = vc ?? router.frontmostViewController else { return nil }

        return router.showSOD(in: vc)
    }

    // MARK: Private

    private func presentOldVersionNotificationIfNeeded() {
        let now = Date()
        let key = SimpleStorage.StorageKey.outdatedVersionLastShowDate
        guard isProperDateToShow(date: now, sodForKey: key) else { return }
        guard let vc = router.frontmostViewController else { return }

        storage.store(date: now, forKey: key)
        router.showSOD(mode: .oldVersion, in: vc)
    }

    private func presentSilentPushNotificationIfNeeded() {
        let now = Date()
        let key = SimpleStorage.StorageKey.disabledPushLastShowDate
        guard isProperDateToShow(date: now, sodForKey: key) else { return }
        guard let vc = router.frontmostViewController else { return }

        storage.store(date: now, forKey: key)
        router.showSOD(mode: .silentPush, in: vc)
    }

    private func isProperDateToShow(date: Date, sodForKey key: SimpleStorage.StorageKey) -> Bool {
        // no need to show notification more than once in 3 days
        if let lastShownDate = storage.date(forKey: key),
            date < lastShownDate.add(components: [.day: 3]) {
            return false
        }
        return true
    }

}
