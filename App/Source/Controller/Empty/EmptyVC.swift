//
//  EmptyVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 05.09.17.
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
//

import UIKit

class EmptyVC: UIViewController {
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var mainLabel: UILabel!
    @IBOutlet private var detailsLabel: UILabel!
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet var backImageView: UIImageView!
    
    class func show(in viewController: UIViewController,
                    inView: UIView? = nil,
                    frame: CGRect? = nil,
                    animated: Bool = true) -> EmptyVC {
        let vc = EmptyVC(nibName: "EmptyVC", bundle: nil)
        let view: UIView! = inView ?? viewController.view
        if let frame = frame {
            vc.view.frame = frame
        } else {
            vc.view.frame = view.bounds
            vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
        view.addSubview(vc.view)
        viewController.addChildViewController(vc)
        vc.didMove(toParentViewController: viewController)
        
        if animated {
            vc.view.alpha = 0
            UIView.animate(withDuration: 0.5, animations: {
                vc.view.alpha = 1
            })
        }
        return vc
    }
    
    func setText(title: String?, subtitle: String?) {
        mainLabel.text = title
        detailsLabel.text = subtitle
    }
    
    func setImage(image: UIImage) {
        imageView.image = image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .overCurrentContext
    }
    
    func remove() {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
        self.didMove(toParentViewController: nil)
        
       // dismiss(animated: true, completion: nil)
    }
    
}
