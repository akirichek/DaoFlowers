//
//  MenuHiddenView.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/13/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class MenuHiddenView: UIView {
    
    weak var menuContainerView: UIView!
    weak var menuContainerLeadingConstraint: NSLayoutConstraint!
    var dragging: Bool = false
    var previousTouchPoint: CGPoint!

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.menuContainerView.touchesBegan(touches, withEvent: event)
        
        //let view = first() as! UIView
        //print(#function)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.menuContainerView.touchesCancelled(touches, withEvent: event)
        let touch = touches.first!
        let point: CGPoint = touch.locationInView(self)
        
        if abs(self.menuContainerLeadingConstraint.constant) > (self.menuContainerView.frame.width / 2) {
            if self.previousTouchPoint == nil {
                self.previousTouchPoint = touches.first!.locationInView(self)
            }
            
            let newOriginX = point.x - self.previousTouchPoint.x
            if newOriginX <= 0 {
                self.menuContainerLeadingConstraint.constant = newOriginX
            }
        }
        
        

        
        print(touch.locationInView(self))
//        super.touchesMoved(touches, withEvent: event)
//        self.menuContainerView.touchesMoved(touches, withEvent: event)
        //print(#function)
        
        //self.previousTouchPoint = point
    }
    
    func animateMenu() {
        var newConstant: CGFloat;
        
        if abs(self.menuContainerLeadingConstraint.constant) > (self.menuContainerView.frame.width / 2) {
            newConstant = -(self.menuContainerView.bounds.size.width)
        } else {
            newConstant = 0
        }
        
        self.menuContainerLeadingConstraint.constant = newConstant
        
        UIView.animateWithDuration(0.3) {
            self.superview!.layoutIfNeeded()
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        super.touchesEnded(touches, withEvent: event)
        self.menuContainerView.touchesEnded(touches, withEvent: event)
        self.previousTouchPoint = nil
        self.animateMenu()
        //print(#function)
    }
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
//        super.touchesCancelled(touches, withEvent: event)
        self.menuContainerView.touchesCancelled(touches, withEvent: event)
        self.previousTouchPoint = nil
        self.animateMenu()
        //print(#function)
    }
}
