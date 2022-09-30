//
//  EYELaunchView.swift
//  EyepetizerApp
//
//  Created by 梁亦明 on 16/4/8.
//  Copyright © 2016年 xiaoming. All rights reserved.
//

import UIKit

class EYELaunchView: UIView {
    // 图片
    @IBOutlet weak var imageView: UIImageView!
    // 黑色背景
    @IBOutlet weak var blackBgView: UIView!
    // 动画完成回调
    typealias AnimationDidStopCallBack = (_ launchView : EYELaunchView) -> Void
    var callBack : AnimationDidStopCallBack?
    
    class func launchView() -> EYELaunchView {
        return Bundle.main.loadNibNamed("EYELaunchView", owner: nil, options: nil)?.first as! EYELaunchView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        startAnimation()
    }
    
    // 黑色背景渐变动画和图片放大动画
    private func startAnimation() {
        UIView.animate(withDuration: 5, delay: 1, options: .curveEaseInOut, animations: {
    
            self.imageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.blackBgView.alpha = 0
            }) { [unowned self](_) in
                
                self.blackBgView.removeFromSuperview()
                if let cb = self.callBack {
                    cb(self)
                }
        }
    }
    
    /**
     动画完成时回调
     */
    func animationDidStop(callBack: AnimationDidStopCallBack?) {
        self.callBack = callBack
    }
}
