//
//  EmptyVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 05.09.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class EmptyVC: UIViewController {
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var mainLabel: UILabel!
    @IBOutlet private var detailsLabel: UILabel!
    @IBOutlet private var stackView: UIStackView!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .overCurrentContext
    }
    
    func remove() {
        dismiss(animated: true, completion: nil)
    }
    
}
