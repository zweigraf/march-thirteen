//
//  AppDelegate.swift
//  MarchThirteen
//
//  Created by Luis Reisewitz on 13.03.17.
//  Copyright © 2017 ZweiGraf. All rights reserved.
//

import UIKit
import SuperDelegate

@UIApplicationMain
class AppDelegate: SuperDelegate, ApplicationLaunched {
    var window: UIWindow?
    func setupApplication() {
        
    }
    func loadInterface(launchItem: LaunchItem) {
        let window = UIWindow()
        window.rootViewController = ViewController()
        setup(mainWindow: window)
        self.window = window
    }
}
