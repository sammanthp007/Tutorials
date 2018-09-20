//
//  AppDelegate.swift
//  Touch ID With LocalAuthentication
//
//  Created by Samman Thapa on 9/20/18.
//  Copyright © 2018 Samman Thapa. All rights reserved.
//

import UIKit

import LocalAuthentication

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print (">> App was launched")
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
        print (">> App was brought to foreground.")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print (">> App became ACTIVE")
        self.authenticateUserWithTouchID()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

extension AppDelegate {
    func authenticateUserWithTouchID () {
        let context: LAContext = LAContext()
        
        // reason for authentication
        let myLocalizedReasonString = "Authenticate to access your app account."
        
        // error variable
        var authError: NSError?
        
        // XXX: so there should be a else statement too, check it out
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError)
        {
            // if closure uses self, ensure that there is no ratain cycle
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: myLocalizedReasonString) { [weak self] (successBool, evaluateError) in
                // if touch id authentication is successful
                if successBool
                {
                    // always do UI activity in UI thread so that eventhough this is in a closure, it gets high priority
                    DispatchQueue.main.async {
                        print (">> Authentication successful")
                        // load the storyboard and the viewcontroller
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let authenticatedVC = storyBoard.instantiateViewController(withIdentifier: "AuthenticatedViewController") as! AuthenticatedViewController
                        self?.window?.rootViewController = UINavigationController(rootViewController: authenticatedVC)
                        self?.window?.makeKeyAndVisible()
                    }
                }
                else // touch id authentication is not successful
                {
                    if let error = evaluateError {
                        print (error.localizedDescription)
                    }
                }
            }
        }
    }
}
