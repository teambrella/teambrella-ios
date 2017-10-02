//
//  HomePresentationController.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 01.10.2017.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class HomePresentationController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
                return
        }
        
        let containerView =  transitionContext.containerView
        toVC.view.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        toVC.view.alpha = 0
        containerView.addSubview(toVC.view)
        let duration = transitionDuration(using: transitionContext)
        UIView.animateKeyframes(
            withDuration: duration,
            delay: 0,
            options: .calculationModeCubic,
            animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/3, animations: {
                    toVC.view.alpha = 1
                })
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1, animations: {
                    toVC.view.transform = .identity
                })
        }) { completed in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
