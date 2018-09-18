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

import Foundation

class ApplicationRouter {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func presentApplication(type: ApplicationScreenType, userData: ApplicationUserData, animated: Bool) {
        let vc = controller(type: type, userData: userData)
        
        if navigationController.viewControllers.contains(vc) {
            navigationController.popToViewController(vc, animated: animated)
        } else {
            navigationController.pushViewController(vc, animated: animated)
        }
    }
    
    func performNext(from vc: ApplicationVC, userData: ApplicationUserData) {
        if let nextType = controllerType(after: vc.type) {
            presentApplication(type: nextType, userData: userData, animated: true)
        } else {
            unwind(vc: vc)
        }
    }
    
    func unwind(vc: ApplicationVC) {
        vc.performSegue(withIdentifier: "unwindToInitial", sender: vc)
    }
    
    func controller(type: ApplicationScreenType, userData: ApplicationUserData, reuse: Bool = true) -> ApplicationVC {
        if reuse {
            for vc in navigationController.viewControllers {
                if let vc = vc as? ApplicationVC, vc.type == type {
                    return vc
                }
            }
        }
        
        if let vc = ApplicationVC.instantiate() as? ApplicationVC {
            vc.router = self
            return vc
        } else {
            fatalError()
        }
    }
    
    private func controllerType(after type: ApplicationScreenType) -> ApplicationScreenType? {
        switch type {
        case .intro:
            return ApplicationScreenType.user
        default:
            return nil
        }
    }
    
}
