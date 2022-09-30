//
//  EYEVideoDetailController.swift
//  EyepetizerApp
//
//  Created by 梁亦明 on 16/3/23.
//  Copyright © 2016年 xiaoming. All rights reserved.
//

import UIKit

class EYEVideoDetailController: UIViewController {
    //MARK: --------------------------- Life Cycle --------------------------
    var model : ItemModel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        // 隐藏导航栏
        self.navigationController?.isNavigationBarHidden = true
        // 添加view
        self.view.addSubview(detailView)
        detailView.model = model
        navigationController?.delegate = self
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.barButtonItemWithImg(image: UIImage(named: "ic_action_back"), selectorImg: nil, target: self, action: #selector(EYEVideoDetailController.leftBtnDidClick))
        
        //手势监听器
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(EYEVideoDetailController.edgePanGesture(edgePan:)))
        edgePan.edges = UIRectEdge.left
        self.view.addGestureRecognizer(edgePan)
    }
    
    convenience init(model : ItemModel) {
        self.init()
        self.model = model
        
        self.title = "Eyepelizer"
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //MARK: --------------------------- Event or Action --------------------------
    @objc private func leftBtnDidClick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func edgePanGesture(edgePan: UIScreenEdgePanGestureRecognizer) {
        let progress = edgePan.translation(in: self.view).x / self.view.bounds.width
        
        if edgePan.state == UIGestureRecognizerState.began {
            self.percentDrivenTransition = UIPercentDrivenInteractiveTransition()
            self.navigationController?.popViewController(animated: true)
        } else if edgePan.state == UIGestureRecognizerState.changed {
            self.percentDrivenTransition?.update(progress)
        } else if edgePan.state == UIGestureRecognizerState.cancelled || edgePan.state == UIGestureRecognizerState.ended {
            if progress > 0.5 {
                self.percentDrivenTransition?.finish()
                panIsCancel = false
            } else {
                self.percentDrivenTransition?.cancel()
                panIsCancel = true
            }
            self.percentDrivenTransition = nil
        }
    }
    
    //MARK: --------------------------- Getter or Setter --------------------------
    lazy var detailView : EYEVideoDetailView = {
        var detailView : EYEVideoDetailView = EYEVideoDetailView(frame:self.view.bounds)
        detailView.delegate = self
        return detailView
    }()
    
    // 手势
    private var percentDrivenTransition: UIPercentDrivenInteractiveTransition?
    // 记录手势是否取消了
    var panIsCancel: Bool = false
}

extension EYEVideoDetailController: UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .pop {
            return EYEVideoDetailPopTransition()
        } else {
            return nil
        }
    }
    
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if animationController is EYEVideoDetailPopTransition {
            return self.percentDrivenTransition
        } else {
            return nil
        }
    }
}

extension EYEVideoDetailController: EYEVideoDetailViewDelegate {
    /**
     点击播放按钮
     */
    func playImageViewDidClick() {
        let playerController = EYEPlayerController(url: model.playUrl, title: model.title)
        self.navigationController?.pushViewController(playerController, animated: false)
    }
    
    /**
     点击返回按钮
    */
    func backBtnDidClick() {
        self.navigationController?.popViewController(animated: true)
    }
}

