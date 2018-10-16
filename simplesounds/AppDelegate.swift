//
//  AppDelegate.swift
//  simplesounds
//
//  Created by Eric Marschner on 9/27/17.
//  Copyright © 2017 Eric Marschner. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    public static var highlightTag: Int = -1

    var window: UIWindow?
    
    static func groupDefaults() -> UserDefaults {
        let defaults = UserDefaults.init(suiteName: "group.com.simplesounds.share")
        return defaults!
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UINavigationBar.appearance().barTintColor = UIColor.black
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]

        
        setupInitial()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func setupInitial() {
        if let _ = AppDelegate.groupDefaults().string(forKey: "0") {
            print("already initialized")
        } else {
            AppDelegate.groupDefaults().set("shame", forKey: "0")
            AppDelegate.groupDefaults().set("dilly2", forKey: "1")
            copyFromBundle(filename: "shame.mp3")
            copyFromBundle(filename: "dilly2.mp3")
        }
    }
    
    func copyFromBundle(filename: String) {
        let fm = FileManager.default
        let documentUrl = fm.groupDirectory
        let fileBundleUrl = Bundle.main.resourceURL?.appendingPathComponent(filename)
        
        if fm.fileExists(atPath: (fileBundleUrl?.path)!) {
            let fileDocumentUrl = documentUrl.appendingPathComponent(filename)
            
            do {
                if !(fm.fileExists(atPath: fileDocumentUrl.path)) {
                    try fm.copyItem(at: fileBundleUrl!, to: fileDocumentUrl)
                }
            } catch let error as NSError {
                print("\(error.debugDescription)")
            }
        } else {
            print("\(filename) does not exist in bundle")
        }
        
    }


}

