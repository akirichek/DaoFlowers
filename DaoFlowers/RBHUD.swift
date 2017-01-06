//
//  RBHUD.swift
//
//  Created by Robert Bojor on 23/09/15.
//  Copyright © 2015 Robert Bojor. All rights reserved.
//

import UIKit
import QuartzCore

open class RBHUD: NSObject {
    
    open static let sharedInstance = RBHUD()
    
    // MARK: - Vars
    fileprivate var overlayView:UIView = UIView()
    fileprivate var parentView:UIView = UIView()
    fileprivate var progressView:UIImageView!
    fileprivate var errorView:UIImageView!
    fileprivate var successView:UIImageView!
    fileprivate var titleLabel:UILabel!
    fileprivate var subtitleLabel:UILabel!
    fileprivate var subviewArray:Array<UIView>!
    
    fileprivate var finishedAnimations = false
    fileprivate var isLoaderShown = false
    fileprivate var wasTitleLabelInitialised = false
    fileprivate var wasSubtitleLabelInitialised = false
    fileprivate var wasProgressViewInitialised = false
    fileprivate var wasErrorViewInitialised = false
    fileprivate var wasSuccessViewInitialised = false
    
    fileprivate var titleLabelCurrentRect:CGRect!
    fileprivate var titleLabelTargetRect:CGRect!
    fileprivate var subtitleLabelCurrentRect:CGRect!
    fileprivate var subtitleLabelTargetRect:CGRect!
    fileprivate var progressViewCurrentRect:CGRect!
    fileprivate var progressViewTargetRect:CGRect!
    fileprivate var errorViewCurrentRect:CGRect!
    fileprivate var errorViewTargetRect:CGRect!
    fileprivate var successViewCurrentRect:CGRect!
    fileprivate var successViewTargetRect:CGRect!
    
    fileprivate let progressAnimationRepeatCount = 500.0
    fileprivate let progressAnimationDuration = 0.8
    
    open var backdropOpacity:CGFloat = 0.8
    open var backdropUsesBlur:Bool = true
    open var backdropBlurStyle:UIBlurEffectStyle = UIBlurEffectStyle.dark
    open var backdropColor:UIColor = UIColor(red:0.23, green:0.26, blue:0.29, alpha:1)
    open var progressViewLineWidth:CGFloat = 1
    open var progressViewSize:CGFloat = 64.0
    open var progressViewPadding:CGFloat = 10.0
    open var progressViewStrokeColor:UIColor = UIColor.white
    open var progressViewFillColor:UIColor = UIColor.clear
    open var successViewStrokeColor:UIColor = UIColor.white
    open var successViewLineWidth:CGFloat = 1.0
    open var errorViewStrokeColor:UIColor = UIColor.red
    open var errorViewLineWidth:CGFloat = 1.0
    open var labelAnimationDistance:CGFloat = 50.0
    open var labelFontName:String = "HelveticaNeue-Light"
    open var labelTitleFontSize:CGFloat = 20.0
    open var labelTitleTextColor:UIColor = UIColor.white
    open var labelSubtitleFontSize:CGFloat = 13.0
    open var labelSubtitleTextColor:UIColor = UIColor.white
    open var errorViewRemovalInterval:TimeInterval = 5
    open var successViewRemovalInterval:TimeInterval = 5
    
    public override init()
    {
        self.overlayView.alpha = 0
        
        self.progressView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.progressViewSize, height: self.progressViewSize))
        self.progressView.alpha = 0
        
        self.errorView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.progressViewSize, height: self.progressViewSize))
        self.errorView.alpha = 0
        
        self.successView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.progressViewSize, height: self.progressViewSize))
        self.successView.alpha = 0
        
        self.titleLabel = UILabel()
        self.titleLabel.numberOfLines = 0
        self.titleLabel.font = UIFont(name: self.labelFontName, size: self.labelTitleFontSize)
        self.titleLabel.tintColor = self.labelTitleTextColor
        self.titleLabel.textColor = self.labelTitleTextColor
        self.titleLabel.backgroundColor = UIColor.clear
        self.titleLabel.textAlignment = NSTextAlignment.center
        
        self.subtitleLabel = UILabel()
        self.subtitleLabel.numberOfLines = 0
        self.subtitleLabel.font = UIFont(name: self.labelFontName, size: self.labelSubtitleFontSize)
        self.subtitleLabel.tintColor = self.labelSubtitleTextColor
        self.subtitleLabel.textColor = self.labelSubtitleTextColor
        self.subtitleLabel.backgroundColor = UIColor.clear
        self.subtitleLabel.textAlignment = NSTextAlignment.center
    }
    
    // MARK: - Public methods
    open func showLoader(_ inView:UIView, withTitle:String?, withSubTitle:String?, withProgress:Bool)
    {
        self.setupOverlayView(inView)
        
        let willHaveTitle = (withTitle != nil) ? true : false
        let willHaveSubtitle = withSubTitle != nil ? true : false
        
        self.subviewArray = []
        if withProgress {
            self.setupProgressView()
            self.subviewArray.append(self.progressView)
        }
        if willHaveTitle {
            self.setupTitleLabel(withTitle!, withProgressView: withProgress, withSubtitle: willHaveSubtitle)
            self.subviewArray.append(self.titleLabel)
        }
        if willHaveSubtitle {
            self.setupSubtitleLabel(withSubTitle!, withProgressView: withProgress)
            self.subviewArray.append(self.subtitleLabel)
        }
        self.addSubviews()
        self.bringIntoView()
    }
    
    open func showWithSuccess(_ inView:UIView, withTitle:String?, withSubTitle:String?)
    {
        self.setupOverlayView(inView)
        let willHaveTitle = (withTitle != nil) ? true : false
        let willHaveSubtitle = withSubTitle != nil ? true : false
        
        self.subviewArray = []
        self.setupSuccessView()
        self.subviewArray.append(self.successView)
        
        if willHaveTitle {
            self.setupTitleLabel(withTitle!, withProgressView: true, withSubtitle: willHaveSubtitle)
            self.subviewArray.append(self.titleLabel)
        }
        if willHaveSubtitle {
            self.setupSubtitleLabel(withSubTitle!, withProgressView: true)
            self.subviewArray.append(self.subtitleLabel)
        }
        self.addSubviews()
        self.bringIntoView()
        Timer.scheduledTimer(timeInterval: self.successViewRemovalInterval, target: self, selector: #selector(RBHUD.hideLoader), userInfo: nil, repeats: false)
    }
    
    open func showWithError(_ inView:UIView, withTitle:String?, withSubTitle:String?)
    {
        self.setupOverlayView(inView)
        let willHaveTitle = (withTitle != nil) ? true : false
        let willHaveSubtitle = withSubTitle != nil ? true : false
        
        self.subviewArray = []
        self.setupErrorView()
        self.subviewArray.append(self.errorView)
        
        if willHaveTitle {
            self.setupTitleLabel(withTitle!, withProgressView: true, withSubtitle: willHaveSubtitle)
            self.subviewArray.append(self.titleLabel)
        }
        if willHaveSubtitle {
            self.setupSubtitleLabel(withSubTitle!, withProgressView: true)
            self.subviewArray.append(self.subtitleLabel)
        }
        self.addSubviews()
        self.bringIntoView()
        Timer.scheduledTimer(timeInterval: self.errorViewRemovalInterval, target: self, selector: #selector(RBHUD.hideLoader), userInfo: nil, repeats: false)
    }
    
    open func hideLoader()
    {
        self.removeFromView()
    }
    
    // MARK: - Private functions
    fileprivate func setupOverlayView(_ inView:UIView)
    {
        if !self.isLoaderShown && self.overlayView.superview == nil {
            self.parentView = inView;
            self.overlayView = UIView(frame: inView.frame)
            self.overlayView.translatesAutoresizingMaskIntoConstraints = false
            if self.backdropUsesBlur {
                let blurEffect = UIBlurEffect(style: self.backdropBlurStyle)
                let blurView = UIVisualEffectView(frame: inView.frame)
                blurView.effect = blurEffect
                let vibrancyView: UIVisualEffectView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
                blurView.contentView.addSubview(vibrancyView)
                self.overlayView.addSubview(blurView)
            } else {
                self.overlayView.backgroundColor = self.backdropColor
            }
            self.overlayView.alpha = 0;
        }
    }
    
    fileprivate func setupSuccessView()
    {
        if !self.wasSuccessViewInitialised {
            self.successView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.progressViewSize, height: self.progressViewSize))
            self.successView.layer.addSublayer(self.setupSuccessViewLayer())
            
            let successWidth:CGFloat = self.progressViewSize
            let successHeight:CGFloat = self.progressViewSize
            let successX:CGFloat = (self.parentView.frame.size.width / 2) - (successWidth / 2)
            let successY:CGFloat = (self.parentView.frame.size.height / 2) - (successHeight / 2)
            self.successViewCurrentRect = CGRect(x: successX, y: successY, width: successWidth, height: successHeight)
            self.successViewTargetRect = CGRect(x: successX, y: successY, width: successWidth, height: successHeight)
            self.successView.frame = self.successViewCurrentRect
            self.wasSuccessViewInitialised = true
        }
    }
    
    fileprivate func setupSuccessViewLayer() -> CAShapeLayer
    {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 0, y: self.progressViewSize * 0.56))
        bezierPath.addLine(to: CGPoint(x: self.progressViewSize * 0.42, y: self.progressViewSize))
        
        let compoundLayer = CAShapeLayer()
        let layer_1 = CAShapeLayer()
        layer_1.path = bezierPath.cgPath
        layer_1.bounds = (layer_1.path?.boundingBox)!
        layer_1.strokeColor = self.successViewStrokeColor.cgColor
        layer_1.fillColor = UIColor.clear.cgColor
        layer_1.lineWidth = self.successViewLineWidth
        layer_1.position = CGPoint(x: 0, y: self.progressViewSize * 0.56)
        layer_1.anchorPoint = CGPoint(x: 0, y: 0)
        
        let animation_1 = CABasicAnimation(keyPath: "strokeEnd")
        animation_1.duration = 0.2
        animation_1.fromValue = NSNumber(value: 0.0 as Float)
        animation_1.toValue = NSNumber(value: 1.0 as Float)
        animation_1.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        layer_1.add(animation_1, forKey: "strokeEnd")
        
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: self.progressViewSize * 0.42, y: self.progressViewSize))
        bezier2Path.addLine(to: CGPoint(x: self.progressViewSize, y: 0))
        
        let layer_2 = CAShapeLayer()
        layer_2.path = bezier2Path.cgPath
        layer_2.bounds = (layer_2.path?.boundingBox)!
        layer_2.strokeColor = self.successViewStrokeColor.cgColor
        layer_2.fillColor = UIColor.clear.cgColor
        layer_2.lineWidth = self.successViewLineWidth
        layer_2.position = CGPoint(x: self.progressViewSize * 0.42, y: 0)
        layer_2.anchorPoint = CGPoint(x: 0, y: 0)
        let animation_2 = CABasicAnimation(keyPath: "strokeEnd")
        animation_2.duration = 0.3
        animation_2.timeOffset = 0.3
        animation_2.fromValue = NSNumber(value: 0.0 as Float)
        animation_2.toValue = NSNumber(value: 1.0 as Float)
        animation_2.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        layer_2.add(animation_2, forKey: "strokeEnd")
        
        compoundLayer.addSublayer(layer_1)
        compoundLayer.addSublayer(layer_2)
        
        return compoundLayer
    }
    
    fileprivate func setupErrorView()
    {
        if !self.wasErrorViewInitialised {
            self.errorView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.progressViewSize, height: self.progressViewSize))
            self.errorView.layer.addSublayer(self.setupErrorViewLayer())
            
            let errorWidth:CGFloat = self.progressViewSize
            let errorHeight:CGFloat = self.progressViewSize
            let errorX:CGFloat = (self.parentView.frame.size.width / 2) - (errorWidth / 2)
            let errorY:CGFloat = (self.parentView.frame.size.height / 2) - (errorHeight / 2)
            self.errorViewCurrentRect = CGRect(x: errorX, y: errorY, width: errorWidth, height: errorHeight)
            self.errorViewTargetRect = CGRect(x: errorX, y: errorY, width: errorWidth, height: errorHeight)
            self.errorView.frame = self.errorViewCurrentRect
            self.wasErrorViewInitialised = true
        }
    }
    
    fileprivate func setupErrorViewLayer() -> CAShapeLayer
    {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 10, y: 10))
        bezierPath.addLine(to: CGPoint(x: self.progressViewSize - 10, y: self.progressViewSize - 10))
        
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: self.progressViewSize - 10, y: 10))
        bezier2Path.addLine(to: CGPoint(x: 10, y: self.progressViewSize - 10))
        
        let compoundLayer = CAShapeLayer()
        let layer_1 = CAShapeLayer()
        layer_1.path = bezierPath.cgPath
        layer_1.bounds = (layer_1.path?.boundingBox)!
        layer_1.strokeColor = self.errorViewStrokeColor.cgColor
        layer_1.fillColor = UIColor.clear.cgColor
        layer_1.lineWidth = self.errorViewLineWidth
        layer_1.position = CGPoint(x: 10, y: 10)
        layer_1.anchorPoint = CGPoint(x: 0, y: 0)
        
        let animation_1 = CABasicAnimation(keyPath: "strokeEnd")
        animation_1.duration = 0.3
        animation_1.fromValue = NSNumber(value: 0.0 as Float)
        animation_1.toValue = NSNumber(value: 1.0 as Float)
        layer_1.add(animation_1, forKey: "strokeEnd")
        
        
        let layer_2 = CAShapeLayer()
        layer_2.path = bezier2Path.cgPath
        layer_2.bounds = (layer_2.path?.boundingBox)!
        layer_2.strokeColor = self.errorViewStrokeColor.cgColor
        layer_2.fillColor = UIColor.clear.cgColor
        layer_2.lineWidth = self.errorViewLineWidth
        layer_2.position = CGPoint(x: 10, y: 10)
        layer_2.anchorPoint = CGPoint(x: 0, y: 0)
        let animation_2 = CABasicAnimation(keyPath: "strokeEnd")
        animation_2.duration = 0.1
        animation_2.timeOffset = 0.1
        animation_2.fromValue = NSNumber(value: 0.0 as Float)
        animation_2.toValue = NSNumber(value: 1.0 as Float)
        layer_2.add(animation_2, forKey: "strokeEnd")
        
        
        compoundLayer.addSublayer(layer_1)
        compoundLayer.addSublayer(layer_2)
        
        return compoundLayer
    }
    
    fileprivate func setupProgressView()
    {
        if !self.wasProgressViewInitialised {
            self.progressView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.progressViewSize, height: self.progressViewSize))
            self.progressView.layer.addSublayer(self.setupProgressViewLayer())
            
            let progressWidth:CGFloat = self.progressView.frame.size.width
            let progressHeight:CGFloat = self.progressView.frame.size.height
            let progressX:CGFloat = (self.parentView.frame.size.width / 2) - (progressWidth / 2)
            let progressY:CGFloat = (self.parentView.frame.size.height / 2) - (progressHeight / 2)
            self.progressViewCurrentRect = CGRect(x: progressX, y: progressY, width: progressWidth, height: progressHeight)
            self.progressViewTargetRect = CGRect(x: progressX, y: progressY, width: progressWidth, height: progressHeight)
            self.progressView.frame = self.progressViewCurrentRect
        }
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = M_PI
        rotationAnimation.duration = self.progressAnimationDuration
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = Float(self.progressAnimationRepeatCount)
        self.progressView.layer.add(rotationAnimation, forKey: "rotation")
        self.progressView.transform = CGAffineTransform(scaleX: 0, y: 0)
        self.wasProgressViewInitialised = true
    }
    
    fileprivate func setupProgressViewLayer() -> CAShapeLayer
    {
        let boundsRect = CGRect(x: 0, y: 0, width: self.progressViewSize, height: self.progressViewSize)
        let partialPath = UIBezierPath()
        partialPath.addArc(withCenter: CGPoint(x: boundsRect.midX, y: boundsRect.midY), radius: boundsRect.width / 2, startAngle: 0 * CGFloat(M_PI)/180, endAngle: -45 * CGFloat(M_PI)/180, clockwise: true)
        
        let fullPath = UIBezierPath(ovalIn: boundsRect)
        
        let fullCircle = CAShapeLayer()
        fullCircle.path = fullPath.cgPath
        fullCircle.bounds = (fullCircle.path?.boundingBox)!
        fullCircle.strokeColor = UIColor.clear.cgColor
        fullCircle.fillColor = self.progressViewFillColor.cgColor
        fullCircle.lineWidth = 0.0
        fullCircle.position = CGPoint(x: 0, y: 0)
        fullCircle.anchorPoint = CGPoint(x: 0, y: 0)
        
        let strokeLine = CAShapeLayer()
        strokeLine.path = partialPath.cgPath
        strokeLine.bounds = (strokeLine.path?.boundingBox)!
        strokeLine.strokeColor = self.progressViewStrokeColor.cgColor
        strokeLine.fillColor = UIColor.clear.cgColor
        strokeLine.lineWidth = self.progressViewLineWidth
        strokeLine.position = CGPoint(x: 0, y: 0)
        strokeLine.anchorPoint = CGPoint(x: 0, y: 0)
        strokeLine.addSublayer(fullCircle)
        
        return strokeLine
    }
    
    fileprivate func setupTitleLabel(_ havingTitle:String, withProgressView:Bool, withSubtitle:Bool)
    {
        self.titleLabel.text = havingTitle
        self.titleLabel.sizeToFit()
        let titleLabelWidth:CGFloat = self.parentView.frame.size.width - 40.0
        let titleLabelHeight:CGFloat = self.titleLabel.frame.size.height
        let titleLabelX:CGFloat = 20.0
        var titleLabelY:CGFloat = (self.parentView.frame.size.height / 2) - titleLabelHeight / 2
        
        if withSubtitle {
            titleLabelY -= titleLabelHeight / 2
        }
        if withProgressView {
            if !withSubtitle {
                titleLabelY -= titleLabelHeight / 2
            }
            if self.subviewArray.contains(self.progressView) {
                let prevTransform = self.progressView.transform
                self.progressView.transform = CGAffineTransform(scaleX: 1, y: 1)
                titleLabelY -= self.progressView.frame.size.height / 2
                self.progressView.transform = prevTransform
                titleLabelY -= self.progressViewPadding
            } else if self.subviewArray.contains(self.errorView) {
                titleLabelY -= self.errorView.frame.size.height / 2
                titleLabelY -= self.progressViewPadding
            } else if self.subviewArray.contains(self.successView) {
                titleLabelY -= self.successView.frame.size.height / 2
                titleLabelY -= self.progressViewPadding
            }
        }
        self.titleLabelTargetRect = CGRect(x: titleLabelX, y: titleLabelY, width: titleLabelWidth, height: titleLabelHeight)
        self.titleLabelCurrentRect = self.titleLabel.frame
        
        if !self.wasTitleLabelInitialised {
            self.titleLabelCurrentRect = CGRect(x: titleLabelX, y: titleLabelY - self.labelAnimationDistance, width: titleLabelWidth, height: titleLabelHeight)
            self.titleLabel.frame = self.titleLabelCurrentRect
            self.titleLabel.alpha = 0
            wasTitleLabelInitialised = true
        }
    }
    
    fileprivate func setupSubtitleLabel(_ havingSubtitle:String, withProgressView:Bool)
    {
        self.subtitleLabel.text = havingSubtitle
        self.subtitleLabel.sizeToFit()
        
        let subtitleLabelWidth:CGFloat = self.parentView.frame.size.width - 40.0
        let subtitleLabelHeight:CGFloat = self.subtitleLabel.frame.size.height
        let subtitleLabelX:CGFloat = 20.0
        var subtitleLabelY:CGFloat = self.parentView.frame.size.height / 2
        if withProgressView {
            if self.subviewArray.contains(self.progressView) {
                let prevTransform = self.progressView.transform
                self.progressView.transform = CGAffineTransform(scaleX: 1, y: 1)
                subtitleLabelY += self.progressView.frame.size.height / 2
                self.progressView.transform = prevTransform
                subtitleLabelY += self.progressViewPadding
            } else if self.subviewArray.contains(self.errorView) {
                subtitleLabelY += self.errorView.frame.size.height / 2
                subtitleLabelY += self.progressViewPadding
            } else if self.subviewArray.contains(self.successView) {
                subtitleLabelY += self.successView.frame.size.height / 2
                subtitleLabelY += self.progressViewPadding
            }
        }
        self.subtitleLabelTargetRect = CGRect(x: subtitleLabelX, y: subtitleLabelY, width: subtitleLabelWidth, height: subtitleLabelHeight)
        self.subtitleLabelCurrentRect = self.subtitleLabel.frame
        
        if !self.wasSubtitleLabelInitialised {
            self.subtitleLabelCurrentRect = CGRect(x: subtitleLabelX, y: subtitleLabelY + self.labelAnimationDistance, width: subtitleLabelWidth, height: subtitleLabelHeight)
            self.subtitleLabel.frame = subtitleLabelCurrentRect
            self.subtitleLabel.alpha = 0
            self.wasSubtitleLabelInitialised = true
        }
        
    }
    
    fileprivate func addSubviews()
    {
        
        for (_,subview) in self.subviewArray.enumerated() {
            if !self.overlayView.subviews.contains(subview) {
                self.overlayView.addSubview(subview)
            }
        }
        if !self.parentView.subviews.contains(self.overlayView) {
            self.parentView.addSubview(self.overlayView)
        }
    }
    
    fileprivate func bringIntoView()
    {
        self.finishedAnimations = false
        DispatchQueue.main.async(execute: { () -> Void in
            if !self.isLoaderShown {
                UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
                    self.overlayView.alpha = self.backdropOpacity
                    }) { (Bool) -> Void in
                        self.finishedAnimations = true
                        self.isLoaderShown = true
                        self.parentView.isUserInteractionEnabled = false
                }
            }
            if self.subviewArray.contains(self.titleLabel) {
                UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
                    self.titleLabel.frame = self.titleLabelTargetRect
                    self.titleLabel.alpha = 1
                    }, completion:nil)
            } else {
                UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
                    self.titleLabel.alpha = 0
                    self.wasTitleLabelInitialised = false
                    }, completion:nil)
            }
            if self.subviewArray.contains(self.subtitleLabel) {
                UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
                    self.subtitleLabel.frame = self.subtitleLabelTargetRect
                    self.subtitleLabel.alpha = 1
                    }, completion:nil)
            } else {
                UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
                    self.subtitleLabel.alpha = 0
                    self.wasSubtitleLabelInitialised = false
                    }, completion:nil)
            }
            if self.subviewArray.contains(self.progressView) {
                UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
                    self.progressView.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self.progressView.frame = self.progressViewTargetRect
                    self.progressView.alpha = 1
                    }, completion:nil)
            } else {
                self.progressView.transform = CGAffineTransform(scaleX: 1, y: 1)
                UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
                    self.progressView.alpha = 0
                    }, completion:nil)
            }
            if self.subviewArray.contains(self.errorView) {
                UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
                    self.errorView.frame = self.errorViewTargetRect
                    self.errorView.alpha = 1
                    }, completion:nil)
            } else {
                UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
                    self.errorView.alpha = 0
                    }, completion:nil)
            }
        })
    }
    
    fileprivate func removeFromView()
    {
        if self.parentView.subviews.contains(self.overlayView) {
            self.finishedAnimations = false
            DispatchQueue.main.async(execute: { () -> Void in
                UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                    self.overlayView.alpha = 0
                    }) { (Bool) -> Void in
                        self.parentView.isUserInteractionEnabled = true
                        
                        self.finishedAnimations = true
                        self.isLoaderShown = false
                        
                        self.wasSuccessViewInitialised = false
                        self.wasErrorViewInitialised = false
                        self.wasProgressViewInitialised = false
                        self.wasSubtitleLabelInitialised = false
                        self.wasTitleLabelInitialised = false
                        
                        self.overlayView.removeFromSuperview()
                }
            })
        }
    }
}
