//
//  AppDelegate.swift
//  S4AEnvironmentalMonitor
//
//  Created by Carl Peto on 05/08/2019.
//  Copyright © 2019 Carl Peto. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var environmentModel: EnvironmentModel?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")

        let environmentModel = EnvironmentModel()
        environmentModel.monitoring = true
        self.environmentModel = environmentModel

        window.contentView = NSHostingView(rootView: ContentView(environmentValues: environmentModel))
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

