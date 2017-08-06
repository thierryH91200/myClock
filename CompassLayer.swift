//
//  TRACompass.swift
//  Compass
//
//
//  Copyright © 2017 thierry Hentic.
//
//  Licensed under Apache License 2.0
//
//  https://github.com/thierryH91200/myClock

import Cocoa

class CompassLayer: NSView {
    
    let rootLayer    = CALayer()
    var backGroundLayer   = CALayer()
    var arrowLayer   = CALayer()
    
    var center               = CGPoint()
    
     public var compassHeading: CGFloat {
        get {
            var heading = atan2f(Float(arrowLayer.transform.m12), Float(arrowLayer.transform.m11))
            heading = Float(RadiansToDegrees(Double(heading)))
            
            if heading < 0 {
                heading += 360.0
            }
            
            return CGFloat(round(heading))
        }
        set(newHeading) {
            
            if newHeading >= 0 && newHeading <= 360 {
               
                // This animation DOES rotate the compass as it should.
                let animation = CABasicAnimation()
                let fromValue = DegreesToRadians(Double(compassHeading))
                let toValue = DegreesToRadians(Double( newHeading ))
                
                animation.fromValue = fromValue
                animation.toValue = toValue
                animation.byValue = (-2 * Double.pi)
                
                animation.keyPath = "transform.rotation.z"
                animation.isRemovedOnCompletion = false
                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                animation.duration = 2
                
                arrowLayer.transform = CATransform3DMakeRotation(CGFloat(toValue), 0, 0, 1)
                arrowLayer.add(animation, forKey:"rotateAnimation")
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame);
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func commonInit()
    {
        let r = CGFloat(self.frame.width / 2)
        center = CGPoint(x: r, y: r)
        
        rootLayer.frame = self.frame
        rootLayer.anchorPoint = CGPoint(x:0.5, y:0.5)
        rootLayer.position = center
        
        self.layer = rootLayer
        self.wantsLayer = true
        
        backGroundLayer = setImage(name: "digital-compass.png")
        layer?.addSublayer(backGroundLayer)
        
        arrowLayer = setImage(name: "compasshi.png")
        arrowLayer.borderColor = NSColor.black.cgColor
        layer?.addSublayer(arrowLayer)
    }
    
    func rotateArrowView ( degrees: Double)
    {
        let rads = DegreesToRadians(degrees)
        
        arrowLayer.transform = CATransform3DMakeRotation(CGFloat(rads), 0, 0, 1)
        
        // This animation DOES rotate the compass as it should.
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = rads
        
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.duration = 2
        animation.isRemovedOnCompletion = false
        
        arrowLayer.removeAnimation(forKey: "rotateAnimation")
        arrowLayer.add(animation, forKey:"rotateAnimation")
    }
    
    func DegreesToRadians (_ value:Double) -> Double {
        return value * .pi / 180.0
    }
    
    func RadiansToDegrees (_ value:Double) -> Double {
        return value * 180.0 / .pi
    }
    
    func setImage(name: String)->CALayer
    {
        let imageLayer =  CALayer()
        
        let image = NSImage(named: NSImage.Name(rawValue: name))
        imageLayer.contents = image?.CGImage
        
        imageLayer.anchorPoint = CGPoint(x:0.5,y:0.5)
        imageLayer.bounds = self.frame
        imageLayer.position = center
        
        return imageLayer
    }
}
