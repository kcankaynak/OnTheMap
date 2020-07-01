//
//  AppDelegate.swift
//  OnTheMap
//
//  Created by Kemal Kaynak on 29.06.20.
//  Copyright © 2020 Kemal Kaynak. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var students = StudentResponse(results: []) {
        didSet {
            NotificationCenter.default.post(name: NotificationName.updateStudents, object: nil)
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
}

