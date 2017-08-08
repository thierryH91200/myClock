//
//  ClockLayer.swift
//  myClock
//
//
//  Copyright © 2017 thierry Hentic.
//
//  Licensed under Apache License 2.0
//
//  https://github.com/thierryH91200/myClock


import Cocoa

@IBDesignable
class ClockLayer2 : NSView
{
    @IBInspectable var hourhandColor   :NSColor = NSColor.black
    @IBInspectable var minutehandColor :NSColor = NSColor.black
    @IBInspectable var secondhandColor :NSColor = NSColor.red
    
    @IBInspectable var backgroundColor :NSColor = NSColor.white
    @IBInspectable var borderColor     :NSColor = NSColor.darkGray
    @IBInspectable var centerColor     :NSColor = NSColor.black
    @IBInspectable var showNumbers     :Bool    = true
    @IBInspectable var roman           :Bool    = false
    
    let digitFont  = NSFont(name : "HelveticaNeue-Thin", size  : CGFloat(15))!
    
    var hourLayer    =  CALayer()
    var minuteLayer  =  CALayer()
    var secondsLayer =  CALayer()
    let rootLayer    = CALayer()
    
    var clockFace = CATextLayer()
    var clockTimer = Timer()
    
    var radius               = CGFloat(100.0)
    var offset               = CGFloat(5.0)
    var center               = CGPoint()
    var textRadiusMultiplier = CGFloat(0.8)
    
    override init(frame frameRect: NSRect) {
        super.init(frame:frameRect)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        let r = CGFloat(self.frame.width / 2)
        radius = CGFloat(r * 0.9)
        offset = CGFloat(r - radius)
        
        center = CGPoint(x: r, y: r )
        
        rootLayer.frame = self.frame
        rootLayer.anchorPoint = CGPoint(x:0.5, y:0.5)
        
        self.layer = rootLayer
        self.wantsLayer = true
        
        let layerClock = setImage(name: "ClockFace1")
        layer?.addSublayer(layerClock)
        
        hourLayer = setImage2(name: "Hour hand")
        layer?.addSublayer(hourLayer)
        
        minuteLayer = setImage2(name: "Minute hand")
        layer?.addSublayer(minuteLayer)
        
        secondsLayer = setImage2(name: "Second hand")
        layer?.addSublayer(secondsLayer)

        initAnimation()
    }
    
    func initAnimation()
    {
        //Place the hands at correct location
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.second, .minute, .hour], from: Date())
        let seconds = dateComponents.second
        let minutes = dateComponents.minute
        let hours = dateComponents.hour
        
        let h1 = CGFloat(hours!) * CGFloat(360.0 / 12.0)
        let h2 = CGFloat(minutes!) * CGFloat(1.0 / 60.0) * (360.0 / 12.0)
        let h3 = CGFloat(seconds!) * CGFloat(1.0 / 60.0) * (360.0 / 60.0)
        let hourAngle  = h1 + h2
        let minuteAngle = CGFloat(minutes!) * CGFloat(360.0 / 60.0) + h3
        let secondsAngle = CGFloat(seconds!) * CGFloat(360.0 / 60.0)
        
        hourLayer.transform = CATransform3DMakeRotation(hourAngle / 180.0 * CGFloat.pi, 0, 0, 1)
        minuteLayer.transform = CATransform3DMakeRotation(minuteAngle / 180 * CGFloat.pi, 0, 0, 1)
        secondsLayer.transform = CATransform3DMakeRotation(secondsAngle / 180 * CGFloat.pi, 0, 0, 1)
        
        let hoursAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        hoursAnimation.repeatCount = .greatestFiniteMagnitude
        hoursAnimation.duration = (60 * 60 * 12) // 10000
        hoursAnimation.isRemovedOnCompletion = false
        hoursAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        hoursAnimation.fromValue = (-hourAngle * CGFloat.pi / 180)
        hoursAnimation.byValue = (-2 * Double.pi)
        hourLayer.add(hoursAnimation, forKey: "HoursAnimationKey")
        
        let minutesAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        minutesAnimation.repeatCount = .greatestFiniteMagnitude
        minutesAnimation.duration = (60 * 60) // 10000
        minutesAnimation.isRemovedOnCompletion = false
        minutesAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        minutesAnimation.fromValue = -(minuteAngle * CGFloat.pi / 180)
        minutesAnimation.byValue = (-2 * Double.pi)
        minuteLayer.add(minutesAnimation, forKey: "MinutesAnimationKey")
        
        let secondsAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        secondsAnimation.repeatCount = .greatestFiniteMagnitude
        secondsAnimation.duration = 60
        secondsAnimation.isRemovedOnCompletion = false
        secondsAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        secondsAnimation.fromValue = -(secondsAngle * CGFloat.pi / 180)
        secondsAnimation.byValue = (-2 * Double.pi)
        secondsLayer.add(secondsAnimation, forKey: "SecondAnimationKey")
    }

    func setImage(name : String)-> CALayer
    {
        let imageLayer   = CALayer()
        
        let image = NSImage(named: NSImage.Name(rawValue: name))
        imageLayer.anchorPoint = CGPoint(x:0.5,y:0.5)
        imageLayer.bounds = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)
        imageLayer.position = center
        imageLayer.contents = image
        
        return imageLayer
    }
    
    func setImage2(name : String)-> CALayer
    {
        let imageLayer   = CALayer()
        
        let image = NSImage(named: NSImage.Name(rawValue: name))
        //let size = NSSize(width: 15, height: radius )
        //image?.size = size
        imageLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        imageLayer.bounds = CGRect(x: 0, y: 0, width: radius * 0.10, height: radius * 2)
        imageLayer.position = center
        imageLayer.contents = image
        
        return imageLayer
    }
}

extension NSImage {
    var CGImage: CGImage {
        let imageSource = CGImageSourceCreateWithData(self.tiffRepresentation! as CFData, nil)
        return CGImageSourceCreateImageAtIndex(imageSource!, 0, nil)!
    }
}





