//
// AppDelegate.swift
//
// Copyright (c) 2021 Cognitive Technology Research Laboratory (CTRLab)

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
		UIApplication.shared.isIdleTimerDisabled = true
        return true
    }

}

