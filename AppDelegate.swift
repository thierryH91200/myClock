//
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

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed (_ sender: NSApplication) -> Bool
    {
        return true
    }
    
    func didReceiveRemoteNotification ()
    {
        print("didReceiveRemoteNotification")
    }
    
    
    func applicationWillBecomeActive(_ notification: Notification) {
        print("applicationWillBecomeActive")
        
        let vc: NSViewController? = getVisibleViewController(NSApplication.shared.keyWindow?.contentViewController) as? ViewController

        var clockTimer = ClockTimer(interval: 1.0)
       
//        vc.clockTimer.start { date in
//            vc.clockRetro.time = date as NSDate
//            
//        }
    }
    
    func applicationWillResignActive(_ notification: Notification)
    {
        print("applicationWillResignActive")
    }
    
    func getVisibleViewController(_ rootViewController: NSViewController?) -> NSViewController? {
        
        var rootVC = rootViewController
        if rootVC == nil {
            rootVC = NSApplication.shared.keyWindow?.contentViewController
        }
        
        if rootVC?.childViewControllers == nil {
            return rootVC
        }
        
        if let presented = rootVC {
            if presented.isKind(of: NSViewController.self) {
                let navigationController = presented
                return navigationController
            }
            
            return getVisibleViewController(presented)
        }
        return nil
    }
    

}

