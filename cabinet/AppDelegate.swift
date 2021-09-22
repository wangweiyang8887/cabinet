//
//  AppDelegate.swift
//  cabinet
//
//  Created by 菲律宾街头流浪汉 on 2021/8/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        updateUserDefaultsIfNeeded()
        window?.rootViewController = BaseNavigationController(rootViewController: HomePageVC())
        window?.makeKeyAndVisible()
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .all
    }
    
    private func updateUserDefaultsIfNeeded() {
        if UserDefaults.shared[.eventName] == nil {
            UserDefaults.shared[.eventName] = "春节"
        }
        if UserDefaults.shared[.eventDate] == nil {
            UserDefaults.shared[.eventDate] = "2022.02.01"
        }
        if UserDefaults.shared[.shuffledDay] == nil {
            UserDefaults.shared[.shuffledDay] = CalendarDate.today(in: .current).day - 1
        }
    }
}

