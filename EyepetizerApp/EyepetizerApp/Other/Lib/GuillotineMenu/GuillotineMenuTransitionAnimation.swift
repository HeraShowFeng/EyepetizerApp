//
//  GuillotineTransitionAnimation.swift
//  GuillotineMenu
//
//  Created by Maksym Lazebnyi on 3/24/15.
//  Copyright (c) 2015 Yalantis. All rights reserved.
//

import UIKit

@objc
protocol GuillotineMenu: NSObjectProtocol {
	
    @objc optional var dismissButton: UIButton! { get }
    @objc optional var titleLabel: UILabel! { get }
}

@objc
protocol GuillotineAnimationDelegate: NSObjectProtocol {
	
    @objc optional func animatorDidFinishPresentation(animator: GuillotineTransitionAnimation)
    @objc optional func animatorDidFinishDismissal(animator: GuillotineTransitionAnimation)
    @objc optional func animatorWillStartPresentation(animator: GuillotineTransitionAnimation)
    @objc optional func animatorWillStartDismissal(animator: GuillotineTransitionAnimation)
}

class GuillotineTransitionAnimation: NSObject {
	
    enum Mode { case Presentation, Dismissal }
    
    //MARK: - Public properties
    weak var animationDelegate: GuillotineAnimationDelegate?
    var mode: Mode = .Presentation
    var supportView: UIView?
    var presentButton: UIView?
    var duration = 0.6
    
    //MARK: - Private properties
    private var chromeView: UIView?
    private var containerMenuButton: UIButton? {
        didSet {
            presentButton?.addObserver(self, forKeyPath: "frame", options: .New, context: myContext)
        }
    }
    private var displayLink: CADisplayLink!
    private var vectorDY: CGFloat = 1500
    private var fromYPresentationLandscapeAdjustment: CGFloat = 1.0
    private var fromYDismissalLandscapeAdjustment: CGFloat = 1.0
    private var toYDismissalLandscapeAdjustment: CGFloat = 1.0
    private var fromYPresentationAdjustment: CGFloat = 1.0
    private var fromYDismissalAdjustment: CGFloat = 1.0
    private var toXPresentationLandscapeAdjustment: CGFloat = 1.0
    private let initialMenuRotationAngle: CGFloat = -90
    private let menuElasticity: CGFloat = 0.6
    private let vectorDYCoefficient: Double = 2 / M_PI
    private var topOffset: CGFloat = 0
    private var anchorPoint: CGPoint!
    private var menu: UIViewController!
    private var animationContext: UIViewControllerContextTransitioning!
    private var animator: UIDynamicAnimator!
    private let myContext = UnsafeMutablePointer<()>()
    
    //MARK: - Deinitialization
    deinit {
        displayLink.invalidate()
        presentButton?.removeObserver(self, forKeyPath: "frame")
    }
    
    //MARK: - Initialization
    override init() {
        super.init()
        setupDisplayLink()
        setupSystemVersionAdjustment()
    }
    
    //MARK: - Private methods
    private func animatePresentation(context: UIViewControllerContextTransitioning) {
        menu = context.viewController(forKey: UITransitionContextViewControllerKey.to)!
        context.containerView.addSubview(menu.view)
        
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            updateChromeView()
            menu.view.addSubview(chromeView!)
        }
        
        if menu is GuillotineMenu {
            if supportView != nil  && presentButton != nil {
                let guillotineMenu = menu as! GuillotineMenu
                containerMenuButton = guillotineMenu.dismissButton
                setupContainerMenuButtonFrameAndTopOffset()
                context.containerView.addSubview(containerMenuButton!)
            }
        }
        
        let fromVC = context.viewController(forKey: UITransitionContextViewControllerKey.from)
        fromVC?.beginAppearanceTransition(false, animated: true)
        
        animationDelegate?.animatorWillStartPresentation?(animator: self)
        
        animateMenu(view: menu.view, context: context)
    }
    
    private func animateDismissal(context: UIViewControllerContextTransitioning) {
        menu = context.viewController(forKey: UITransitionContextViewControllerKey.from)!
        if menu.navigationController != nil {
            let toVC = context.viewController(forKey: UITransitionContextViewControllerKey.to)!
            context.containerView.addSubview(toVC.view)
            context.containerView.sendSubview(toBack: toVC.view)
        }
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            updateChromeView()
            menu.view.addSubview(chromeView!)
        }
        
        let toVC = context.viewController(forKey: UITransitionContextViewControllerKey.to)
        toVC?.beginAppearanceTransition(true, animated: true)

        animationDelegate?.animatorWillStartDismissal?(animator: self)
        
        animateMenu(view: menu.view, context: context)
    }
    
    private func animateMenu(view: UIView, context:UIViewControllerContextTransitioning) {
        animationContext = context
        animator = UIDynamicAnimator(referenceView: context.containerView)
        animator.delegate = self
        vectorDY = CGFloat(vectorDYCoefficient * Double(UIScreen.main.bounds.size.height) / duration)
        
        var rotationDirection = CGVector.init(dx: 0, dy: -vectorDY)
        var fromX: CGFloat
        var fromY: CGFloat
        var toX: CGFloat
        var toY: CGFloat
        if self.mode == .Presentation {
            if supportView != nil {
                showHostTitleLabel(show: false, animated: true)
            }
            view.transform = CGAffineTransform.init(rotationAngle: degreesToRadians(degrees: initialMenuRotationAngle))
            view.frame = CGRect.init(x: 0, y: -view.frame.height+topOffset, width: view.frame.width, height: view.frame.height)
            rotationDirection = CGVector.init(dx: 0, dy: vectorDY)
            
            if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {

                fromX = context.containerView.frame.width - 1
                fromY = context.containerView.frame.height + fromYPresentationLandscapeAdjustment
                toX = fromX + toXPresentationLandscapeAdjustment
                toY = fromY
            } else {
                fromX = -1
                fromY = context.containerView.frame.height + fromYPresentationAdjustment
                toX = fromX
                toY = fromY + 1
            }
        } else {
            if supportView != nil {
                showHostTitleLabel(show: true, animated: true)
            }
            if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
                fromX = -1
                fromY = -context.containerView.frame.width + topOffset + fromYDismissalLandscapeAdjustment
                toX = fromX
                toY = fromY + toYDismissalLandscapeAdjustment
            } else {
                fromX = context.containerView.frame.height - 1
                fromY = -context.containerView.frame.width + topOffset + fromYDismissalAdjustment
                toX = fromX + 1
                toY = fromY
            }
        }
        
        let anchorPoint = CGPoint.init(x: topOffset / 2, y: topOffset / 2)
        let viewOffset = UIOffsetMake(-view.bounds.size.width / 2 + anchorPoint.x, -view.bounds.size.height / 2 + anchorPoint.y)
        let attachmentBehaviour = UIAttachmentBehavior(item: view, offsetFromCenter: viewOffset, attachedToAnchor: anchorPoint)
        animator.addBehavior(attachmentBehaviour)

        let collisionBehaviour = UICollisionBehavior()
        collisionBehaviour.addBoundary(withIdentifier: "collide" as NSCopying, from: CGPoint.init(x: fromX, y:fromY), to: CGPoint.init(x: toX, y: toY))
        collisionBehaviour.addItem(view)
        animator.addBehavior(collisionBehaviour)
        
        let itemBehaviour = UIDynamicItemBehavior(items: [view])
        itemBehaviour.elasticity = menuElasticity
        animator.addBehavior(itemBehaviour)
        
        let fallBehaviour = UIPushBehavior(items:[view], mode: .continuous)
        fallBehaviour.pushDirection = rotationDirection
        animator.addBehavior(fallBehaviour)
        //Start displayLink
        displayLink.isPaused = false
    }
    
    private func showHostTitleLabel(show: Bool, animated: Bool) {
        if let guillotineMenu = menu as? GuillotineMenu {
            guard guillotineMenu.titleLabel != nil else { return }
            guillotineMenu.titleLabel!.center = CGPoint.init(x: supportView!.frame.height / 2, y: supportView!.frame.width / 2)
            guillotineMenu.titleLabel!.transform = CGAffineTransform(rotationAngle: degreesToRadians(degrees: 90));
            menu.view.addSubview(guillotineMenu.titleLabel!)
            if mode == .Presentation {
                guillotineMenu.titleLabel!.alpha = 1;
            } else {
                guillotineMenu.titleLabel!.alpha = 0;
            }
            
            let alpha = show ? 1.0 : 0
            if animated {
                UIView.animate(withDuration: duration, animations: {
                    guillotineMenu.titleLabel!.alpha = alpha
                    }, completion: nil)
            } else {
                guillotineMenu.titleLabel!.alpha = alpha
            }
        }
    }
    
    private func updateChromeView() {
        chromeView = UIView(frame: CGRect.init(x: 0, y: menu.view.frame.height, width: menu.view.frame.width, height: menu.view.frame.height))
        chromeView!.backgroundColor = menu.view.backgroundColor
    }
    
    private func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(GuillotineTransitionAnimation.updateContainerMenuButton))
        displayLink.add(to: RunLoop.current, forMode: RunLoop.Mode.commonModes)
        displayLink.isPaused = true
    }
    
    private func setupSystemVersionAdjustment() {
        let device = UIDevice.current
        let iosVersion = Double(device.systemVersion) ?? 0
        let iOS9 = iosVersion >= 9
        
        if (iOS9) {
            fromYPresentationLandscapeAdjustment = 1.5
            fromYDismissalLandscapeAdjustment = 1.0
            fromYPresentationAdjustment = -1.0
            fromYDismissalAdjustment = -1.0
            toXPresentationLandscapeAdjustment = 1.0
            toYDismissalLandscapeAdjustment = -1.0
        } else {
            fromYPresentationLandscapeAdjustment = 0.5
            fromYDismissalLandscapeAdjustment = 0.0
            fromYPresentationAdjustment = -1.5
            fromYDismissalAdjustment = 1.0
            toXPresentationLandscapeAdjustment = -1.0
            toYDismissalLandscapeAdjustment = 1.5
        }
    }
    
    private func degreesToRadians(degrees: CGFloat) -> CGFloat {
        return degrees / 180.0 * CGFloat(M_PI)
    }
	
    private func radiansToDegrees(radians: CGFloat) -> CGFloat {
        return radians * 180.0 / CGFloat(M_PI)
    }
	
    @objc
		private func updateContainerMenuButton() {
            let rotationTransform: CATransform3D = menu.view.layer.presentation()!.transform
        var angle: CGFloat = 0
        if (rotationTransform.m11 < 0.0) {
            angle = 180.0 - radiansToDegrees(radians: asin(rotationTransform.m12))
        } else {
            angle = radiansToDegrees(radians: asin(rotationTransform.m12))
        }
        let degrees: CGFloat = 90 - abs(angle)
            containerMenuButton?.layer.transform = CATransform3DRotate(CATransform3DIdentity, degreesToRadians(degrees: degrees), 0, 0, 1)
    }
    
    func setupContainerMenuButtonFrameAndTopOffset() {
        topOffset = supportView!.frame.origin.y + supportView!.bounds.height
        let senderRect = supportView!.convert(presentButton!.frame, to: nil)
        containerMenuButton?.frame = senderRect
    }
    
    //MARK: - Observer
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &myContext {
            setupContainerMenuButtonFrameAndTopOffset()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

//MARK: - UIViewControllerAnimatedTransitioning protocol implementation
extension GuillotineTransitionAnimation: UIViewControllerAnimatedTransitioning {
	
    func animateTransition(using context: UIViewControllerContextTransitioning) {
        switch mode {
        case .Presentation:
            animatePresentation(context: context)
        case .Dismissal:
            animateDismissal(context: context)
        }
    }
    
    func transitionDuration(using context: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
}

//MARK: - UIDynamicAnimatorDelegate protocol implementation
extension GuillotineTransitionAnimation: UIDynamicAnimatorDelegate {
	
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        if self.mode == .Presentation {
            self.animator.removeAllBehaviors()
            menu.view.transform = CGAffineTransform.identity
            menu.view.frame = animationContext.containerView.bounds
            anchorPoint = CGPoint.zero
        }

        chromeView?.removeFromSuperview()
        animationContext.completeTransition(true)
        
        if self.mode == .Presentation {
            let fromVC = animationContext.viewController(forKey: UITransitionContextViewControllerKey.from)
            fromVC?.endAppearanceTransition()
            animationDelegate?.animatorDidFinishPresentation?(animator: self)
        } else {
            let toVC = animationContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            toVC?.endAppearanceTransition()
            animationDelegate?.animatorDidFinishDismissal?(animator: self)
        }
        //Stop displayLink
        displayLink.isPaused = true
    }
}
