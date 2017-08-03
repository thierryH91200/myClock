//
//  ViewController.swift
//  myClock
//
//  Created by thierryH24A on 06/07/2017.
//  Copyright © 2017 thierryH24A. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var clockLayer: ClockLayer!
    @IBOutlet weak var clockCG: ClockCG!
    
    var clockTimer = ClockTimer(interval: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clockCG.startTimer()
        
        clockTimer.start { date in
            self.clockLayer.time = date as NSDate
        }
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}

class ClockTimer {
    let interval: TimeInterval
    var timer: DispatchSource?
    
    init(interval: TimeInterval) {
        self.interval = interval
    }
    
    func start(_ callback: @escaping (Date) -> ())
    {
        if let t = timer
        {
            t.cancel()
        }

        let timer1 = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: 0), queue: DispatchQueue.main)
        _ = DispatchTime.now() + Double(Int64(interval)) / Double(NSEC_PER_SEC)
        
        timer1.schedule(deadline: DispatchTime.init(uptimeNanoseconds: UInt64(100000)), repeating: DispatchTimeInterval.seconds(1), leeway: DispatchTimeInterval.seconds(0))
        
        timer1.setEventHandler { callback(Date()) }
        timer1.resume()
        
        timer = timer1 as? DispatchSource
    }
    
    func stop()
    {
        if let t = timer {
            t.cancel()
        }
        timer = nil
    }
}


