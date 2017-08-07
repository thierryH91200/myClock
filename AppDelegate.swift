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
        
    func applicationWillBecomeActive(_ notification: Notification)
    {
        print("applicationWillBecomeActive")
    }
    
    func applicationWillResignActive(_ notification: Notification)
    {
        print("applicationWillResignActive")
    }
}

