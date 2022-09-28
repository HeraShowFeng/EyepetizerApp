//
//  EYENavigationController.swift
//  EyepetizerApp
//
//  Created by 梁亦明 on 16/3/13.
//  Copyright © 2016年 xiaoming. All rights reserved.
//

import UIKit

/// 自定义导航栏控制器。。 集成子UINavigationController 实现手势返回操作
class EYENavigationController : UINavigationController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    override func viewDidLoad() {
        if self.delegate!.responds(to: Selector("interactivePopGestureRecognizer")) {
            interactivePopGestureRecognizer?.delegate = self
            self.navigationBar.titleTextAttributes = [NSAttributedStringKey.init(rawValue: "Font") : UIFont.customFont_Lobster(fontSize: UIConstant.UI_FONT_16)]
            delegate = self
        }
        navigationBar.tintColor = UIColor.black
        navigationBar.barStyle = UIBarStyle.default
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.delegate!.responds(to: Selector("interactivePopGestureRecognizer")) && animated {
            interactivePopGestureRecognizer?.isEnabled = false
        }
        
        super.pushViewController(viewController, animated: animated)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        return super.popViewController(animated: animated)
    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        if self.delegate!.responds(to: Selector("interactivePopGestureRecognizer")) && animated {
            interactivePopGestureRecognizer?.isEnabled = false
        }
        
        return super.popToRootViewController(animated: animated)
    }
    
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        if self.delegate!.responds(to: Selector("interactivePopGestureRecognizer")) && animated {
            interactivePopGestureRecognizer?.isEnabled = false
        }
        
        return super.popToViewController(viewController, animated: false)
    }
    
    //MARK: - UINavigationControllerDelegate
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        if self.delegate!.responds(to: Selector("interactivePopGestureRecognizer")) {
            interactivePopGestureRecognizer?.isEnabled = true
        }
    }
    //MARK: - UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == interactivePopGestureRecognizer {
            if self.viewControllers.count < 2 || self.visibleViewController == self.viewControllers[0] {
                return false
            }
        }
        
        return true
    }
}
