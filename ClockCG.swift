import Cocoa


@IBDesignable
class ClockCG: NSView
{
    @IBInspectable var hourhandColor   :NSColor = NSColor.black
    @IBInspectable var minutehandColor :NSColor = NSColor.black
    @IBInspectable var secondhandColor :NSColor = NSColor.red
    
    @IBInspectable var backgroundColor :NSColor = NSColor.white
    @IBInspectable var borderColor     :NSColor = NSColor.darkGray
    @IBInspectable var centreColor     :NSColor = NSColor.black
    @IBInspectable var showNumbers     :Bool    = true
    @IBInspectable var roman           :Bool    = false
    
    var digitFont  = NSFont(name : "HelveticaNeue-Thin", size  : CGFloat(15))!
    
    var textRadiusMultiplier = CGFloat(0.8)
    var radius               = CGFloat(100.0)
    var offset               = CGFloat(5.0)
    var center               = CGPoint()
    
    override init(frame frameRect: NSRect) {
        super.init(frame:frameRect);
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(_ dirtyRect: NSRect)
    {
        let r = CGFloat(self.frame.height / 2)
        radius = CGFloat(r * 0.9)
        offset = CGFloat(r - radius)
        
        center = CGPoint(x: r, y: r)
        
        drawBorder()
        drawTicks()
        
        let cal = Calendar.current
        let units = Set<Calendar.Component>([.hour, .minute, .second])
        let components = cal.dateComponents(units, from: Date())
        
        drawHourHand(hour: components.hour!, minute: components.minute!)
        drawMinuteHand(minute: components.minute!, second: components.second!)
        drawSecondHand(second: components.second!)
        
        drawCentre()
        if showNumbers {
            drawNumbers()
        }
    }
    
    func drawBorder(){
        borderColor.setStroke()
        let face = NSBezierPath(ovalIn: CGRect(x: offset, y: offset, width: radius * 2, height: radius * 2))
        face.stroke()
        backgroundColor.setFill()
        face.fill()
    }
    
    func drawTicks()
    {
        var start = CGPoint()
        var end = CGPoint()
        var length : CGFloat = 0.90
        NSColor.black.set()
        for i in 1...60
        {
            let angle = CGFloat(Double(i) * 6.0 * Double.pi / 180)
            let path = NSBezierPath()
            
            start.x = center.x + cos(angle) * radius
            start.y = center.y + sin(angle) * radius
            
            if (i%5 == 0)
            {
                NSColor.black.setStroke()
                length = 0.90
            }else{
                NSColor.lightGray.setStroke()
                length = 0.95
            }
            end.x = center.x + cos(angle) * radius * length
            end.y = center.y + sin(angle) * radius * length
            
            path.move(to: start)
            path.line(to: end)
            path.stroke()
        }
    }
    
    func drawNumbers()
    {
        let txtRadius = radius * textRadiusMultiplier
        NSColor.black.set()
        for i in 1...12
        {
            let str = roman ? i.toRoman() : String(i)
            
            let number = NSAttributedString(string: str, attributes:[
                NSAttributedStringKey.foregroundColor : NSColor.black,
                NSAttributedStringKey.font : digitFont])
            
            let angle = CGFloat((-(Double(i) * 30.0) + 90) * Double.pi / 180)
            let numberRect =  CGRect(
                x: center.x + cos(angle) * txtRadius - number.size().width/2.0,
                y: center.y + sin(angle) * txtRadius - number.size().height/2.0,
                width:number.size().width,
                height:number.size().height)
            number.draw(in: numberRect)
        }
    }
    
    func drawCentre(){
        centreColor.setFill()
        let path = NSBezierPath()
        path.appendArc(withCenter: center, radius: radius * 0.05, startAngle: 0.0, endAngle: 2.0 * CGFloat.pi, clockwise: true)
        path.stroke()
        path.fill()
    }
    
    
    func drawHourHand(hour: Int, minute: Int)
    {
        let angleHour = -Double(hour%12 * 30) + 90.0
        let angleMinute = -Double(minute) / 10.0 * 5.0
        
        let angle = CGFloat((angleHour + angleMinute) * Double.pi / 180)
        
        var start = CGPoint()
        start.x = center.x - cos(angle) * radius * 0.10
        start.y = center.x - sin(angle) * radius * 0.10
        
        var end = CGPoint()
        end.x = center.x + cos(angle) * radius * 0.70
        end.y = center.y + sin(angle) * radius * 0.70
        
        let path = NSBezierPath()
        path.move(to: start)
        path.line(to: end)
        
        path.lineWidth = CGFloat(4.0)
        hourhandColor.setStroke()
        path.stroke()
        path.close()
    }

    func drawMinuteHand(minute: Int, second: Int)
    {
        let angleMinute = -Double(minute) * 6.0 + 90.0
        let angleSecond = -Double(second) / 6.0 / 2.0
        
        let angle =  CGFloat((angleMinute + angleSecond) * Double.pi / 180)
        
        var start = CGPoint()
        start.x = center.x - cos(angle) * radius * 0.10
        start.y = center.x - sin(angle) * radius * 0.10
        
        var end = CGPoint()
        end.x = center.x + cos(angle) * radius * 0.90
        end.y = center.y + sin(angle) * radius * 0.90
        
        let path = NSBezierPath()
        path.move(to: start)
        path.line(to: end)
        
        path.lineWidth = CGFloat(2)
        minutehandColor.setStroke()
        path.stroke()
        path.close()
    }
    
    func drawSecondHand(second: Int)
    {
        let angle = CGFloat((-Double(second) * 360.0 / 60 + 90) * Double.pi / 180)
        
        var start = CGPoint()
        start.x = center.x - cos(angle) * radius * 0.10
        start.y = center.x - sin(angle) * radius * 0.10
        
        var end = CGPoint()
        end.x = center.x + cos(angle) * radius * 0.90
        end.y = center.y + sin(angle) * radius * 0.90
        
        let path = NSBezierPath()
        path.move(to: start)
        path.line(to: end)
        
        path.lineWidth = CGFloat(1)
        secondhandColor.setStroke()
        path.stroke()
        path.close()
    }
    
    @objc func tick(_ timer: Timer)
    {
        self.needsDisplay = true
        self.display()
    }
    
    func startTimer(){
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.tick(_:)), userInfo: nil, repeats: true)
    }
}

extension Int
{
    func toRoman() -> String {
        
        let romanValues = ["M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"]
        let arabicValues = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1]
        
        var romanValue = ""
        var startingValue = self
        
        for (index, romanChar) in romanValues.enumerated()
        {
            let arabicValue = arabicValues[index]
            let div = startingValue / arabicValue
            
            if (div > 0)
            {
                for _ in 0..<div
                {
                    romanValue += romanChar
                }
                startingValue -= arabicValue * div
            }
        }
        return romanValue
    }
}


