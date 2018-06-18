//
//  MasterTabBarController.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 31.05.17.

/* Copyright(C) 2017  Teambrella, Inc.
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

import UIKit

class MasterTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let items = tabBar.items else { return }
        
        for item in items {
            item.image = item.image?.withRenderingMode(.alwaysOriginal)
        }
        
        UIImage.fetchImage(string: service.session?.myAvatarStringSmall ?? "") { [weak self] image, error in
            guard let image = image else { return }
                
                self?.setLastTabImage(image: image)
        }
    }
    
    func setLastTabImage(image: UIImage) {
        if let vc = viewControllers?.last {
            vc.tabBarItem.image = ImageTransformer(image: image).tabBarImage
        }
    }
    
    func switchTo(tabType: TabType) -> UIViewController? {
        guard let viewControllers = viewControllers else { return nil }
        
        for (idx, vc) in viewControllers.enumerated() {
            if let nc = vc as? UINavigationController,
                let firstVC = nc.viewControllers.first,
                let tabRoutable = firstVC as? TabRoutable,
                tabRoutable.tabType == tabType {
                selectedIndex = idx
                return firstVC
            }
        }
        return nil
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
