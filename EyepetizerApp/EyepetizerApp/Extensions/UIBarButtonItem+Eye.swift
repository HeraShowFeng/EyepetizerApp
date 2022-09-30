//
//  UIBarButtonItem+Eye.swift
//  EyepetizerApp
//
//  Created by 梁亦明 on 16/3/13.
//  Copyright © 2016年 xiaoming. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    class func barButtonItemWithImg(image : UIImage!, selectorImg : UIImage?, target : AnyObject!, action : Selector!) -> UIBarButtonItem {
        
        let view = UIView()
        view.frame = CGRect.init(x: 0, y: 0, width: 80, height: 40)
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect.init(x: -10, y: 0, width: 40, height: 40)
        view.addSubview(imageView)
        
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        button.addTarget(target, action: action, for: .touchUpInside)
        view.addSubview(button)
        
        return UIBarButtonItem(customView: view)
    }
}
