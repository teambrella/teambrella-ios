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
        case noTokenProvided
    }
    
    enum LoginType {
        case facebook, vk
    }
    
    typealias CompletionHandler = (String?, Error?) -> Void
    
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
    
    func loginAndRegister(type: LoginType,
                          in controller: UIViewController,
                          completion: @escaping CompletionHandler) {
        let handler: CompletionHandler = { [weak self] token, error in
            self?.register(type: type, token: token, completion: completion)
        }
        switch type {
        case .facebook:
            loginFacebook(in: controller, completion: handler)
        case .vk:
            loginVK(in: controller, completion: handler)
        }
    }
    
    func loginFacebook(in controller: UIViewController,
                       completion: @escaping CompletionHandler) {
        let manager = FBSDKLoginManager()
        manager.logOut()
        // remove user_friends permission to comply with FBSDK 3.0
        let permissions =  ["public_profile", "email"]
        manager.logIn(withReadPermissions: permissions, from: controller) { result, error in
            completion(result?.token?.tokenString, error)
        }
    }
    
    func loginVK(in controller: UIViewController,
                 completion: @escaping CompletionHandler) {
        let auth0 = Auth0Authenticator()
        auth0.authWithVK(completion: completion)
    }
    
    func register(userData: UserApplicationData, completion: @escaping (Error?) -> Void) {
        keyStorage.setToRealUser()
        let processor = teambrella.processor
        guard let signature = processor.publicKeySignature else {
            router.logout()
            return
        }
        
        dao.registerKey(signature: signature, userData: userData).observe { result in
            switch result {
            case .value:
                completion(nil)
            case let .error(error):
                completion(error)
            }
        }
    }
    
    func register(type: LoginType, token: String?, completion: @escaping CompletionHandler) {
        keyStorage.setToRealUser()
        let processor = teambrella.processor
        guard let signature = processor.publicKeySignature else {
            router.logout()
            return
        }
        
        log("Eth address: \(processor.ethAddressString ?? "none")", type: .info)
        guard let token = token else {
            completion(nil, LoginWorkerError.noTokenProvided)
            return
        }
        let ethereumWallet = processor.ethAddressString ?? ""
        
        let future: Future<Bool>
        
        switch type {
        case .facebook:
            future = dao.registerKey(facebookToken: token, signature: signature, wallet: ethereumWallet)
        case .vk:
            future = dao.registerKey(socialToken: token, signature: signature, wallet: ethereumWallet)
        }
        future.observe { result in
            switch result {
            case .value:
                completion(token, nil)
            case let .error(error):
                completion(token, error)
            }
        }
    }
    
}
