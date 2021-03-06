//
//  PassViewTransition.swift
//  ETNews
//
//  Created by Millman YANG on 2017/5/16.
//  Copyright © 2017年 Sen Informatoin co. All rights reserved.
//

import UIKit

class PassViewPresentTransition: BasePresentTransition, UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return config.duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        if self.isPresent {
            let toVC = transitionContext.viewController(forKey: .to)!
            guard let pass = (self.source as? PassViewFromProtocol)?.passView else {
                print("Need Called setView")
                return
            }            
            guard let passContainer = (toVC as? PassViewToProtocol)?.containerView else {
                print("Need implement PassViewPresentedProtocol")
                return
            }
            if let c = self.config as? PassViewPresentConfig {
                c.pass = pass
                c.passOriginalSuper = pass.superview
                pass.superview?.isHidden = true
            }
            let convertRect:CGRect = pass.superview?.convert(pass.superview!.frame, to: nil) ?? .zero
            let finalFrame = transitionContext.finalFrame(for: toVC)
            let originalColor = toVC.view.backgroundColor
            toVC.view.backgroundColor = UIColor.clear
            toVC.view.frame = finalFrame
//            passContainer.addSubview(pass)
            container.addSubview(toVC.view)
            toVC.view.addSubview(pass)
            toVC.view.layoutIfNeeded()
            pass.frame = convertRect
            (toVC as? PassViewToProtocol)?.transitionWillStart(passView: pass)
            self.animate(animations: {
                pass.frame = passContainer.frame
            }, completion: { (finish) in
                passContainer.addSubview(pass)
                toVC.view.backgroundColor = originalColor
                (toVC as? PassViewToProtocol)?.transitionCompleted(passView: pass)
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
            
        } else {
            
            let from = transitionContext.viewController(forKey: .from)
            guard let config = self.config as? PassViewPresentConfig else {
                return
            }
            
            guard let pass = config.pass  else {
                return
            }
            
            guard let source = (self.source as? PassViewFromProtocol) else {
                print("Need Implement PassViewPresentingProtocol")
                return
            }
//            let convertRect:CGRect = superV.convert(superV.frame, to: nil)
//            pass.frame = convertRect
//            container.addSubview(pass)
//            container.layoutIfNeeded()
//            from?.view.backgroundColor = UIColor.clear
//            self.animate(animations: {
//            }, completion: { (finish) in
//                config.passOriginalSuper?.addSubview(pass)
//                superV.isHidden = false
//                source.completed(passView: pass, superV: superV)
//                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
//            })
            
            
            let superV = source.backReplaceSuperView?(original: config.passOriginalSuper) ?? config.passOriginalSuper
            let original:CGRect = pass.superview?.convert(pass.superview!.frame, to: nil) ?? .zero
            
            let convertRect:CGRect = (superV != nil ) ? superV!.convert(superV!.frame, to: nil) : .zero
            
            if superV != nil {
                container.addSubview(pass)
            }
            container.layoutIfNeeded()
            pass.frame = original
            UIView.animate(withDuration: self.config.duration, animations: {
                from?.view.alpha = 0.0
                pass.frame = convertRect
            }, completion: { (finish) in
                superV?.addSubview(pass)
                source.completed(passView: pass, superV: superV)
                superV?.isHidden = false
                from?.view.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                
            })

        }
    }
}
