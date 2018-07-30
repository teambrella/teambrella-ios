//
/* Copyright(C) 2016-2018 Teambrella, Inc.
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
 * along with this program.  If not, see http://www.gnu.org/licenses/
 */

import FBSDKCoreKit
import FBSDKLoginKit
import Foundation

class LoginWorker {
    enum LoginWorkerError: Error {
        case unknownError
    }

    var dao: DAO { return service.dao }
    var keyStorage: KeyStorage { return service.keyStorage }
    var router: MainRouter { return service.router }
    var teambrella: TeambrellaService { return service.teambrella }

    func getTeams(completion: @escaping (TeamsModel, Bool) -> Void, failure: @escaping (Error) -> Void) {
        let isDemo = keyStorage.isDemoUser
        dao.requestTeams(demo: isDemo).observe { result in
            switch result {
            case let .value(teamsEntity):
                completion(teamsEntity, isDemo)
            case let .error(error):
                if isDemo {
                    service.keyStorage.createNewDemoKey()
                }
                failure(error)
            }
        }
    }

    func loginAndRegister(in controller: UIViewController,
                          completion: @escaping (FacebookUser) -> Void,
                          failure: @escaping (Error) -> Void) {
        loginFacebookUser(in: controller, completion: { [weak self] token, userID in
            self?.register(token: token, userID: userID, completion: {
                self?.getFacebookMe(completion: completion, failure: failure)
            }, failure: { error in
                failure(error)
            })
        }) { error in
            failure(error)
        }
    }

    func getFacebookMe(completion: @escaping (FacebookUser) -> Void, failure: @escaping (Error) -> Void) {
            let fields = "email, birthday, age_range, name, first_name, last_name, gender, picture.type(large)"
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": fields]).start { connection, object, error in
                guard let reply = object as? [String: Any], error == nil else {
                    failure(error ?? LoginWorkerError.unknownError)
                    return
                }
                log("Facebook reply: \(reply)", type: .social)
                completion(FacebookUser(dict: reply))
            }
    }

    func loginFacebookUser(in controller: UIViewController,
                           completion: @escaping (String, String) -> Void,
                           failure: @escaping (Error) -> Void) {
        let manager = FBSDKLoginManager()
        manager.logOut()
        // remove user_friends permission to comply with FBSDK 3.0
        let permissions =  ["public_profile", "email"]
        manager.logIn(withReadPermissions: permissions, from: controller) { result, error in
            guard error == nil, let result = result, let token = result.token else {
                failure(error ?? LoginWorkerError.unknownError)
                return
            }
            completion(token.tokenString, token.userID)
        }
    }

    func register(token: String, userID: String, completion: @escaping () -> Void, failure: @escaping (Error) -> Void) {
        keyStorage.setToRealUser()
        let processor = teambrella.processor
        guard let signature = processor.publicKeySignature else {
            router.logout()
            return
        }

        log("Eth address: \(processor.ethAddressString ?? "none")", type: .info)
        dao.registerKey(facebookToken: token, signature: signature).observe { result in
            switch result {
            case .value:
                completion()
            case let .error(error):
                failure(error)
            }
        }
    }
    
}
