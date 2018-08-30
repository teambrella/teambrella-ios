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

import Auth0
import Foundation

class Auth0Authenticator {
    var credentials: Credentials?
    var domain: String {
        #if SURILLA
        return "surilla.auth0.com"
        #else
        return ""
        #endif
    }

    var audience: String {
        return "https://\(domain)/userinfo"
    }

}

extension Auth0Authenticator: VKAuthenticating {
    func authWithVK(completion: @escaping (String?, Error?) -> Void) {
        Auth0
            .webAuth()
            .scope("openid profile")
            .audience(audience)
            .start { [weak self] result in
                switch result {
                case .failure(let error):
                    print("Error: \(error)")
                    completion(nil, error)
                case let .success(credentials):
                    print("Credentials: \(credentials)")
                    self?.credentials = credentials
                    completion(credentials.accessToken, nil)
                }
        }
    }
}
