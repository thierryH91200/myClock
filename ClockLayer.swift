import Cocoa

@IBDesignable
class ClockLayer : NSView
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

    var hourLayer =  CALayer()
    var minuteLayer =  CALayer()
    var secondsLayer =  CALayer()
    let rootLayer = CALayer()
    let imageLayer = CALayer()
    
    var clockFace = CATextLayer()
    var clockTimer: Timer = Timer()
    
    var radius               = CGFloat(100.0)
    var offset               = CGFloat(5.0)
    var center               = CGPoint()
    var textRadiusMultiplier = CGFloat(0.8)
    
    var time: NSDate = NSDate() {
        didSet {
            clockFace.string = formatter.string(from: time as Date)
        }
    }
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE dd MMM\nHH:mm:ss"
        formatter.timeZone = NSTimeZone.system
        return formatter
    }()
    
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
        
        center = CGPoint(x: r, y: r + 100)
 
        rootLayer.frame = self.frame
        rootLayer.anchorPoint = CGPoint(x:0, y:0)
        
        self.layer = rootLayer
        self.wantsLayer = true
        
        drawBorder()
        drawCentre()
        if showNumbers
        {
            drawNumbers()
        }
        drawTicks()
        
        clockFace = setupClockFaceLayer()
        layer?.addSublayer(clockFace)
        
        let timeAnimation = CABasicAnimation(keyPath: "transform.rotation.x")
        timeAnimation.repeatCount = .greatestFiniteMagnitude
        timeAnimation.duration = 60.0
        timeAnimation.isRemovedOnCompletion = false
        timeAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        timeAnimation.fromValue = 0.0
        timeAnimation.byValue = (2 * Double.pi)
        clockFace.add(timeAnimation, forKey: "timeAnimationKey")

        //Draw the hours layer
        hourLayer = CALayer()
        hourLayer.backgroundColor = hourhandColor.cgColor
        hourLayer.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        hourLayer.position = CGPoint(x: CGFloat((frame.size.width) / 2), y: 200)
        hourLayer.bounds = CGRect(x: 0, y: 0, width: 4.0, height: CGFloat(radius * 0.70))
        layer?.addSublayer(hourLayer)
        
        minuteLayer = CALayer()
        minuteLayer.backgroundColor = minutehandColor.cgColor
        minuteLayer.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        minuteLayer.position = CGPoint(x: CGFloat(frame.size.width / 2), y: 200)
        minuteLayer.bounds = CGRect(x: 0, y: 0, width: 2.0, height: CGFloat(radius * 0.90))
        layer?.addSublayer(minuteLayer)
        
        secondsLayer = CALayer()
        secondsLayer.backgroundColor = secondhandColor.cgColor
        secondsLayer.anchorPoint = CGPoint(x: 0.5, y: 0)
        secondsLayer.position = CGPoint(x: CGFloat(frame.size.width / 2), y: 200)
        secondsLayer.bounds = CGRect(x: 0, y: 0, width: 1.0, height: CGFloat(radius * 0.90))
        secondsLayer.borderColor = NSColor.red.cgColor
        layer?.addSublayer(secondsLayer)
        
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
        hoursAnimation.duration = 60 * 60 * 12
        hoursAnimation.isRemovedOnCompletion = false
        hoursAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        hoursAnimation.fromValue = (-hourAngle * .pi / 180)
        hoursAnimation.byValue = (-2 * Double.pi)
        hourLayer.add(hoursAnimation, forKey: "HoursAnimationKey")
        
        let minutesAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        minutesAnimation.repeatCount = .greatestFiniteMagnitude
        minutesAnimation.duration = 60 * 60
        minutesAnimation.isRemovedOnCompletion = false
        minutesAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        minutesAnimation.fromValue = -(minuteAngle * .pi / 180)
        minutesAnimation.byValue = (-2 * Double.pi)
        minuteLayer.add(minutesAnimation, forKey: "MinutesAnimationKey")
        
        let secondsAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        secondsAnimation.repeatCount = .greatestFiniteMagnitude
        secondsAnimation.duration = 60
        secondsAnimation.isRemovedOnCompletion = false
        secondsAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        secondsAnimation.fromValue = -(secondsAngle * .pi / 180)
        secondsAnimation.byValue = (-2 * Double.pi)
        secondsLayer.add(secondsAnimation, forKey: "SecondAnimationKey")
    }
    
    func setupClockFaceLayer() -> CATextLayer
    {
        let clockFace = CATextLayer()
        
        clockFace.font = "Menlo" as CFTypeRef
        clockFace.fontSize = 18.0
        clockFace.shadowOpacity = 0.0
        clockFace.anchorPoint = CGPoint(x: 0, y: 0)
        clockFace.allowsFontSubpixelQuantization = true
        clockFace.foregroundColor = CGColor(red: 13.0/255.0, green: 116.0/255.0, blue: 1.0, alpha: 1.0)
        clockFace.bounds = CGRect(x: 0, y: 0, width: 200, height: 50)
        clockFace.position = CGPoint(x:0, y:0)
        clockFace.alignmentMode = kCAAlignmentCenter
        clockFace.truncationMode = kCATruncationStart
        
        clockFace.addConstraint(constraint(attribute: .midX, relativeTo: "superlayer", attribute2: .midX))
        clockFace.addConstraint(constraint(attribute: .midY, relativeTo: "superlayer", attribute2: .midY))
        
        clockFace.string = formatter.string(from: time as Date)
        return clockFace
    }
    
    func doInitSetup() {
        
        //        let app = NSApplication.shared
        //
        //        let enterForegroundNotification = NotificationCenter.default.addObserver (
        //            forName : NSNotification.Name.didBecomeActiveNotification ,
        //            object: nil, queue: nil, using: {(_ note: Notification) -> Void in
        //                //NSLog(@"Returning from background");
        //                self.setTimeToNow(animated: false)
        //                if isRunning
        //                {
        //                    isRunning = true
        //                }
        //        })
        //        let enterBackground           = NotificationCenter.default.addObserver( forName: NSNotification.Name., object: nil, queue: nil, using: {(_ note: Notification) -> Void in
        //            //NSLog(@"Exiting to background");
        //            clockTimer.invalidate()
        //        })
    }
    
    func setTimeToNow(animated: Bool) {
//        setTime(Date(), animated: animated)
    }
    
 
    func drawBorder(){
        let layerBorder = CAShapeLayer()
        let path = CGMutablePath()
        
        path.addArc(center: center, radius: radius, startAngle: CGFloat(0.0), endAngle: CGFloat(Double.pi) * 2, clockwise: true)
        layerBorder.path = path
        layerBorder.strokeColor = NSColor.darkGray.cgColor
        layerBorder.lineWidth = 1.0
        layerBorder.fillColor = NSColor.white.cgColor
        rootLayer.addSublayer(layerBorder)
    }
    
    func drawTicks()
    {
        var start = CGPoint()
        var end = CGPoint()
        var length : CGFloat = 0.90
        var stroke = NSColor.black.cgColor
        for i in 1...60
        {
            let layer = CAShapeLayer()
            let path = CGMutablePath()

            let angle = CGFloat(Double(i) * 6.0 * Double.pi / 180)
            
            start.x = center.x + cos(angle) * radius
            start.y = center.y + sin(angle) * radius
            
            if (i%5 == 0)
            {
                stroke = NSColor.black.cgColor
                length = 0.90
                
            } else {
                stroke = NSColor.lightGray.cgColor
                length = 0.95
            }
            end.x = center.x + cos(angle) * radius * length
            end.y = center.y + sin(angle) * radius * length
            
            path.addLines(between: [start , end])
            layer.path = path
            layer.strokeColor = stroke
            rootLayer.addSublayer(layer)
        }
    }
    
    func drawNumbers()
    {
        let txtRadius = radius * textRadiusMultiplier
        
        for i in 1...12
        {
            let textLayer = CATextLayer()
            let str = roman ? i.toRoman() : String(i)
            
            let numberAttr = NSAttributedString(string: str, attributes:[
                NSAttributedStringKey.foregroundColor : NSColor.black,
                NSAttributedStringKey.font : digitFont])
            
            let angle = CGFloat((-(Double(i) * 30.0) + 90) * Double.pi / 180)
            let numberRect =  CGRect(
                x: center.x + cos(angle) * txtRadius - numberAttr.size().width/2.0,
                y: center.y + sin(angle) * txtRadius - numberAttr.size().height/2,
                width: numberAttr.size().width,
                height: numberAttr.size().height)
            
            textLayer.foregroundColor = NSColor.black.cgColor
            
            textLayer.frame = numberRect
            textLayer.string = numberAttr
            
            rootLayer.addSublayer(textLayer)
        }
    }
    
    func drawCentre(){
        let layer = CAShapeLayer()
        let path = CGMutablePath()
        
        path.addArc(center: center, radius: radius * 0.05, startAngle: 0.0, endAngle: 2.0 * CGFloat.pi, clockwise: true)
        layer.path = path
        layer.strokeColor = centerColor.cgColor
        layer.fillColor = centerColor.cgColor
        rootLayer.addSublayer(layer)
    }

    func setImage()
    {
        let image = NSImage(named: NSImage.Name(rawValue: "ClockFace.jpg"))
        let size = NSSize(width: 200, height: 200)
        image?.size = size
        imageLayer.anchorPoint = CGPoint(x:0,y:0)
        imageLayer.bounds = CGRect(x: 0, y: 0, width: 200, height: 200)
        imageLayer.position = CGPoint(x: 0, y: 100)
        imageLayer.contents = image
        
        layer?.addSublayer(imageLayer)
    }
}

func constraint(attribute: CAConstraintAttribute, relativeTo: String, attribute2: CAConstraintAttribute) -> CAConstraint
{
    return CAConstraint(attribute: attribute, relativeTo: "superlayer", attribute: attribute2)
}

extension NSImage {
    var CGImage: CGImage {
        let imageSource = CGImageSourceCreateWithData(self.tiffRepresentation! as CFData, nil)
        return CGImageSourceCreateImageAtIndex(imageSource!, 0, nil)!
    }
}





