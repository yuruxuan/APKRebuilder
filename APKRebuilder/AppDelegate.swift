//
//  AppDelegate.swift
//  APKRebuilder
//
//  Created by Yu. on 2020/1/31.
//  Copyright © 2020年 Yu. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        let mainViewController = MainViewController(nibName: "MainViewController", bundle: nil)
        
        let mainWindow = NSWindow(contentViewController: mainViewController)
        mainWindow.title = "APKRebuilder"
        mainWindow.styleMask.remove(.resizable)
        mainWindow.center()
        mainWindow.orderFront(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }


}

