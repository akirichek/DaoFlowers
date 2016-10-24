//
//  RBHUD.swift
//
//  Created by Robert Bojor on 23/09/15.
//  Copyright © 2015 Robert Bojor. All rights reserved.
//

import UIKit
import QuartzCore

public class RBHUD: NSObject {
    
    public static let sharedInstance = RBHUD()
    
    // MARK: - Vars
    private var overlayView:UIView = UIView()
    private var parentView:UIView = UIView()
    private var progressView:UIImageView!
    private var errorView:UIImageView!
    private var successView:UIImageView!
    private var titleLabel:UILabel!
    private var subtitleLabel:UILabel!
    private var subviewArray:Array<UIView>!
    
    private var finishedAnimations = false
    private var isLoaderShown = false
    private var wasTitleLabelInitialised = false
    private var wasSubtitleLabelInitialised = false
    private var wasProgressViewInitialised = false
    private var wasErrorViewInitialised = false
    private var wasSuccessViewInitialised = false
    
    private var titleLabelCurrentRect:CGRect!
    private var titleLabelTargetRect:CGRect!
    private var subtitleLabelCurrentRect:CGRect!
    private var subtitleLabelTargetRect:CGRect!
    private var progressViewCurrentRect:CGRect!
    private var progressViewTargetRect:CGRect!
    private var errorViewCurrentRect:CGRect!
    private var errorViewTargetRect:CGRect!
    private var successViewCurrentRect:CGRect!
    private var successViewTargetRect:CGRect!
    
    private let progressAnimationRepeatCount = 500.0
    private let progressAnimationDuration = 0.8
    
    public var backdropOpacity:CGFloat = 0.8
    public var backdropUsesBlur:Bool = true
    public var backdropBlurStyle:UIBlurEffectStyle = UIBlurEffectStyle.Dark
    public var backdropColor:UIColor = UIColor(red:0.23, green:0.26, blue:0.29, alpha:1)
    public var progressViewLineWidth:CGFloat = 1
    public var progressViewSize:CGFloat = 64.0
    public var progressViewPadding:CGFloat = 10.0
    public var progressViewStrokeColor:UIColor = UIColor.whiteColor()
    public var progressViewFillColor:UIColor = UIColor.clearColor()
    public var successViewStrokeColor:UIColor = UIColor.whiteColor()
    public var successViewLineWidth:CGFloat = 1.0
    public var errorViewStrokeColor:UIColor = UIColor.redColor()
    public var errorViewLineWidth:CGFloat = 1.0
    public var labelAnimationDistance:CGFloat = 50.0
    public var labelFontName:String = "HelveticaNeue-Light"
    public var labelTitleFontSize:CGFloat = 20.0
    public var labelTitleTextColor:UIColor = UIColor.whiteColor()
    public var labelSubtitleFontSize:CGFloat = 13.0
    public var labelSubtitleTextColor:UIColor = UIColor.whiteColor()
    public var errorViewRemovalInterval:NSTimeInterval = 5
    public var successViewRemovalInterval:NSTimeInterval = 5
    
    public override init()
    {
        self.overlayView.alpha = 0
        
        self.progressView = UIImageView(frame: CGRectMake(0, 0, self.progressViewSize, self.progressViewSize))
        self.progressView.alpha = 0
        
        self.errorView = UIImageView(frame: CGRectMake(0, 0, self.progressViewSize, self.progressViewSize))
        self.errorView.alpha = 0
        
        self.successView = UIImageView(frame: CGRectMake(0, 0, self.progressViewSize, self.progressViewSize))
        self.successView.alpha = 0
        
        self.titleLabel = UILabel()
        self.titleLabel.numberOfLines = 0
        self.titleLabel.font = UIFont(name: self.labelFontName, size: self.labelTitleFontSize)
        self.titleLabel.tintColor = self.labelTitleTextColor
        self.titleLabel.textColor = self.labelTitleTextColor
        self.titleLabel.backgroundColor = UIColor.clearColor()
        self.titleLabel.textAlignment = NSTextAlignment.Center
        
        self.subtitleLabel = UILabel()
        self.subtitleLabel.numberOfLines = 0
        self.subtitleLabel.font = UIFont(name: self.labelFontName, size: self.labelSubtitleFontSize)
        self.subtitleLabel.tintColor = self.labelSubtitleTextColor
        self.subtitleLabel.textColor = self.labelSubtitleTextColor
        self.subtitleLabel.backgroundColor = UIColor.clearColor()
        self.subtitleLabel.textAlignment = NSTextAlignment.Center
    }
    
    // MARK: - Public methods
    public func showLoader(inView:UIView, withTitle:String?, withSubTitle:String?, withProgress:Bool)
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
    
    public func showWithSuccess(inView:UIView, withTitle:String?, withSubTitle:String?)
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
        NSTimer.scheduledTimerWithTimeInterval(self.successViewRemovalInterval, target: self, selector: #selector(RBHUD.hideLoader), userInfo: nil, repeats: false)
    }
    
    public func showWithError(inView:UIView, withTitle:String?, withSubTitle:String?)
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
        NSTimer.scheduledTimerWithTimeInterval(self.errorViewRemovalInterval, target: self, selector: #selector(RBHUD.hideLoader), userInfo: nil, repeats: false)
    }
    
    public func hideLoader()
    {
        self.removeFromView()
    }
    
    // MARK: - Private functions
    private func setupOverlayView(inView:UIView)
    {
        if !self.isLoaderShown && self.overlayView.superview == nil {
            self.parentView = inView;
            self.overlayView = UIView(frame: inView.frame)
            self.overlayView.translatesAutoresizingMaskIntoConstraints = false
            if self.backdropUsesBlur {
                let blurEffect = UIBlurEffect(style: self.backdropBlurStyle)
                let blurView = UIVisualEffectView(frame: inView.frame)
                blurView.effect = blurEffect
                let vibrancyView: UIVisualEffectView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: blurEffect))
                blurView.contentView.addSubview(vibrancyView)
                self.overlayView.addSubview(blurView)
            } else {
                self.overlayView.backgroundColor = self.backdropColor
            }
            self.overlayView.alpha = 0;
        }
    }
    
    private func setupSuccessView()
    {
        if !self.wasSuccessViewInitialised {
            self.successView = UIImageView(frame: CGRectMake(0, 0, self.progressViewSize, self.progressViewSize))
            self.successView.layer.addSublayer(self.setupSuccessViewLayer())
            
            let successWidth:CGFloat = self.progressViewSize
            let successHeight:CGFloat = self.progressViewSize
            let successX:CGFloat = (self.parentView.frame.size.width / 2) - (successWidth / 2)
            let successY:CGFloat = (self.parentView.frame.size.height / 2) - (successHeight / 2)
            self.successViewCurrentRect = CGRectMake(successX, successY, successWidth, successHeight)
            self.successViewTargetRect = CGRectMake(successX, successY, successWidth, successHeight)
            self.successView.frame = self.successViewCurrentRect
            self.wasSuccessViewInitialised = true
        }
    }
    
    private func setupSuccessViewLayer() -> CAShapeLayer
    {
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPointMake(0, self.progressViewSize * 0.56))
        bezierPath.addLineToPoint(CGPointMake(self.progressViewSize * 0.42, self.progressViewSize))
        
        let compoundLayer = CAShapeLayer()
        let layer_1 = CAShapeLayer()
        layer_1.path = bezierPath.CGPath
        layer_1.bounds = CGPathGetBoundingBox(layer_1.path)
        layer_1.strokeColor = self.successViewStrokeColor.CGColor
        layer_1.fillColor = UIColor.clearColor().CGColor
        layer_1.lineWidth = self.successViewLineWidth
        layer_1.position = CGPointMake(0, self.progressViewSize * 0.56)
        layer_1.anchorPoint = CGPointMake(0, 0)
        
        let animation_1 = CABasicAnimation(keyPath: "strokeEnd")
        animation_1.duration = 0.2
        animation_1.fromValue = NSNumber(float: 0.0)
        animation_1.toValue = NSNumber(float: 1.0)
        animation_1.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        layer_1.addAnimation(animation_1, forKey: "strokeEnd")
        
        let bezier2Path = UIBezierPath()
        bezier2Path.moveToPoint(CGPointMake(self.progressViewSize * 0.42, self.progressViewSize))
        bezier2Path.addLineToPoint(CGPointMake(self.progressViewSize, 0))
        
        let layer_2 = CAShapeLayer()
        layer_2.path = bezier2Path.CGPath
        layer_2.bounds = CGPathGetBoundingBox(layer_2.path)
        layer_2.strokeColor = self.successViewStrokeColor.CGColor
        layer_2.fillColor = UIColor.clearColor().CGColor
        layer_2.lineWidth = self.successViewLineWidth
        layer_2.position = CGPointMake(self.progressViewSize * 0.42, 0)
        layer_2.anchorPoint = CGPointMake(0, 0)
        let animation_2 = CABasicAnimation(keyPath: "strokeEnd")
        animation_2.duration = 0.3
        animation_2.timeOffset = 0.3
        animation_2.fromValue = NSNumber(float: 0.0)
        animation_2.toValue = NSNumber(float: 1.0)
        animation_2.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        layer_2.addAnimation(animation_2, forKey: "strokeEnd")
        
        compoundLayer.addSublayer(layer_1)
        compoundLayer.addSublayer(layer_2)
        
        return compoundLayer
    }
    
    private func setupErrorView()
    {
        if !self.wasErrorViewInitialised {
            self.errorView = UIImageView(frame: CGRectMake(0, 0, self.progressViewSize, self.progressViewSize))
            self.errorView.layer.addSublayer(self.setupErrorViewLayer())
            
            let errorWidth:CGFloat = self.progressViewSize
            let errorHeight:CGFloat = self.progressViewSize
            let errorX:CGFloat = (self.parentView.frame.size.width / 2) - (errorWidth / 2)
            let errorY:CGFloat = (self.parentView.frame.size.height / 2) - (errorHeight / 2)
            self.errorViewCurrentRect = CGRectMake(errorX, errorY, errorWidth, errorHeight)
            self.errorViewTargetRect = CGRectMake(errorX, errorY, errorWidth, errorHeight)
            self.errorView.frame = self.errorViewCurrentRect
            self.wasErrorViewInitialised = true
        }
    }
    
    private func setupErrorViewLayer() -> CAShapeLayer
    {
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPointMake(10, 10))
        bezierPath.addLineToPoint(CGPointMake(self.progressViewSize - 10, self.progressViewSize - 10))
        
        let bezier2Path = UIBezierPath()
        bezier2Path.moveToPoint(CGPointMake(self.progressViewSize - 10, 10))
        bezier2Path.addLineToPoint(CGPointMake(10, self.progressViewSize - 10))
        
        let compoundLayer = CAShapeLayer()
        let layer_1 = CAShapeLayer()
        layer_1.path = bezierPath.CGPath
        layer_1.bounds = CGPathGetBoundingBox(layer_1.path)
        layer_1.strokeColor = self.errorViewStrokeColor.CGColor
        layer_1.fillColor = UIColor.clearColor().CGColor
        layer_1.lineWidth = self.errorViewLineWidth
        layer_1.position = CGPointMake(10, 10)
        layer_1.anchorPoint = CGPointMake(0, 0)
        
        let animation_1 = CABasicAnimation(keyPath: "strokeEnd")
        animation_1.duration = 0.3
        animation_1.fromValue = NSNumber(float: 0.0)
        animation_1.toValue = NSNumber(float: 1.0)
        layer_1.addAnimation(animation_1, forKey: "strokeEnd")
        
        
        let layer_2 = CAShapeLayer()
        layer_2.path = bezier2Path.CGPath
        layer_2.bounds = CGPathGetBoundingBox(layer_2.path)
        layer_2.strokeColor = self.errorViewStrokeColor.CGColor
        layer_2.fillColor = UIColor.clearColor().CGColor
        layer_2.lineWidth = self.errorViewLineWidth
        layer_2.position = CGPointMake(10, 10)
        layer_2.anchorPoint = CGPointMake(0, 0)
        let animation_2 = CABasicAnimation(keyPath: "strokeEnd")
        animation_2.duration = 0.1
        animation_2.timeOffset = 0.1
        animation_2.fromValue = NSNumber(float: 0.0)
        animation_2.toValue = NSNumber(float: 1.0)
        layer_2.addAnimation(animation_2, forKey: "strokeEnd")
        
        
        compoundLayer.addSublayer(layer_1)
        compoundLayer.addSublayer(layer_2)
        
        return compoundLayer
    }
    
    private func setupProgressView()
    {
        if !self.wasProgressViewInitialised {
            self.progressView = UIImageView(frame: CGRectMake(0, 0, self.progressViewSize, self.progressViewSize))
            self.progressView.layer.addSublayer(self.setupProgressViewLayer())
            
            let progressWidth:CGFloat = self.progressView.frame.size.width
            let progressHeight:CGFloat = self.progressView.frame.size.height
            let progressX:CGFloat = (self.parentView.frame.size.width / 2) - (progressWidth / 2)
            let progressY:CGFloat = (self.parentView.frame.size.height / 2) - (progressHeight / 2)
            self.progressViewCurrentRect = CGRectMake(progressX, progressY, progressWidth, progressHeight)
            self.progressViewTargetRect = CGRectMake(progressX, progressY, progressWidth, progressHeight)
            self.progressView.frame = self.progressViewCurrentRect
        }
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = M_PI
        rotationAnimation.duration = self.progressAnimationDuration
        rotationAnimation.cumulative = true
        rotationAnimation.repeatCount = Float(self.progressAnimationRepeatCount)
        self.progressView.layer.addAnimation(rotationAnimation, forKey: "rotation")
        self.progressView.transform = CGAffineTransformMakeScale(0, 0)
        self.wasProgressViewInitialised = true
    }
    
    private func setupProgressViewLayer() -> CAShapeLayer
    {
        let boundsRect = CGRectMake(0, 0, self.progressViewSize, self.progressViewSize)
        let partialPath = UIBezierPath()
        partialPath.addArcWithCenter(CGPointMake(boundsRect.midX, boundsRect.midY), radius: boundsRect.width / 2, startAngle: 0 * CGFloat(M_PI)/180, endAngle: -45 * CGFloat(M_PI)/180, clockwise: true)
        
        let fullPath = UIBezierPath(ovalInRect: boundsRect)
        
        let fullCircle = CAShapeLayer()
        fullCircle.path = fullPath.CGPath
        fullCircle.bounds = CGPathGetBoundingBox(fullCircle.path)
        fullCircle.strokeColor = UIColor.clearColor().CGColor
        fullCircle.fillColor = self.progressViewFillColor.CGColor
        fullCircle.lineWidth = 0.0
        fullCircle.position = CGPointMake(0, 0)
        fullCircle.anchorPoint = CGPointMake(0, 0)
        
        let strokeLine = CAShapeLayer()
        strokeLine.path = partialPath.CGPath
        strokeLine.bounds = CGPathGetBoundingBox(strokeLine.path)
        strokeLine.strokeColor = self.progressViewStrokeColor.CGColor
        strokeLine.fillColor = UIColor.clearColor().CGColor
        strokeLine.lineWidth = self.progressViewLineWidth
        strokeLine.position = CGPointMake(0, 0)
        strokeLine.anchorPoint = CGPointMake(0, 0)
        strokeLine.addSublayer(fullCircle)
        
        return strokeLine
    }
    
    private func setupTitleLabel(havingTitle:String, withProgressView:Bool, withSubtitle:Bool)
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
                self.progressView.transform = CGAffineTransformMakeScale(1, 1)
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
        self.titleLabelTargetRect = CGRectMake(titleLabelX, titleLabelY, titleLabelWidth, titleLabelHeight)
        self.titleLabelCurrentRect = self.titleLabel.frame
        
        if !self.wasTitleLabelInitialised {
            self.titleLabelCurrentRect = CGRectMake(titleLabelX, titleLabelY - self.labelAnimationDistance, titleLabelWidth, titleLabelHeight)
            self.titleLabel.frame = self.titleLabelCurrentRect
            self.titleLabel.alpha = 0
            wasTitleLabelInitialised = true
        }
    }
    
    private func setupSubtitleLabel(havingSubtitle:String, withProgressView:Bool)
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
                self.progressView.transform = CGAffineTransformMakeScale(1, 1)
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
        self.subtitleLabelTargetRect = CGRectMake(subtitleLabelX, subtitleLabelY, subtitleLabelWidth, subtitleLabelHeight)
        self.subtitleLabelCurrentRect = self.subtitleLabel.frame
        
        if !self.wasSubtitleLabelInitialised {
            self.subtitleLabelCurrentRect = CGRectMake(subtitleLabelX, subtitleLabelY + self.labelAnimationDistance, subtitleLabelWidth, subtitleLabelHeight)
            self.subtitleLabel.frame = subtitleLabelCurrentRect
            self.subtitleLabel.alpha = 0
            self.wasSubtitleLabelInitialised = true
        }
        
    }
    
    private func addSubviews()
    {
        
        for (_,subview) in self.subviewArray.enumerate() {
            if !self.overlayView.subviews.contains(subview) {
                self.overlayView.addSubview(subview)
            }
        }
        if !self.parentView.subviews.contains(self.overlayView) {
            self.parentView.addSubview(self.overlayView)
        }
    }
    
    private func bringIntoView()
    {
        self.finishedAnimations = false
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if !self.isLoaderShown {
                UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                    self.overlayView.alpha = self.backdropOpacity
                    }) { (Bool) -> Void in
                        self.finishedAnimations = true
                        self.isLoaderShown = true
                        self.parentView.userInteractionEnabled = false
                }
            }
            if self.subviewArray.contains(self.titleLabel) {
                UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                    self.titleLabel.frame = self.titleLabelTargetRect
                    self.titleLabel.alpha = 1
                    }, completion:nil)
            } else {
                UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                    self.titleLabel.alpha = 0
                    self.wasTitleLabelInitialised = false
                    }, completion:nil)
            }
            if self.subviewArray.contains(self.subtitleLabel) {
                UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                    self.subtitleLabel.frame = self.subtitleLabelTargetRect
                    self.subtitleLabel.alpha = 1
                    }, completion:nil)
            } else {
                UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                    self.subtitleLabel.alpha = 0
                    self.wasSubtitleLabelInitialised = false
                    }, completion:nil)
            }
            if self.subviewArray.contains(self.progressView) {
                UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                    self.progressView.transform = CGAffineTransformMakeScale(1, 1)
                    self.progressView.frame = self.progressViewTargetRect
                    self.progressView.alpha = 1
                    }, completion:nil)
            } else {
                self.progressView.transform = CGAffineTransformMakeScale(1, 1)
                UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                    self.progressView.alpha = 0
                    }, completion:nil)
            }
            if self.subviewArray.contains(self.errorView) {
                UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                    self.errorView.frame = self.errorViewTargetRect
                    self.errorView.alpha = 1
                    }, completion:nil)
            } else {
                UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                    self.errorView.alpha = 0
                    }, completion:nil)
            }
        })
    }
    
    private func removeFromView()
    {
        if self.parentView.subviews.contains(self.overlayView) {
            self.finishedAnimations = false
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                    self.overlayView.alpha = 0
                    }) { (Bool) -> Void in
                        self.parentView.userInteractionEnabled = true
                        
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
