//
//  EYETabbarTransition.swift
//  EyepetizerApp
//
//  Created by 梁亦明 on 16/3/19.
//  Copyright © 2016年 xiaoming. All rights reserved.
//

import UIKit

/// tabbar切换动画
class EYETabbarTransition: NSObject, UIViewControllerAnimatedTransitioning {
    let duration : TimeInterval = 0.4
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView : UIView = transitionContext.containerView
        let fromView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)?.view
        let toView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)?.view
        
        containerView.addSubview(toView!)
        toView?.alpha = 0
        fromView?.alpha = 1
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { () -> Void in
            toView?.alpha = 1
            fromView?.alpha = 0
            
            }) { (_) -> Void in
                
                transitionContext.completeTransition(true)
        }
        
    }
}
