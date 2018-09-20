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
        self.authenticateUserWithTouchID()
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
        print (">> App became ACTIVE")
//        self.authenticateUserWithTouchID()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

extension AppDelegate {
    func displayAuthenticatedViewController () {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let authenticatedVC = storyboard.instantiateViewController(withIdentifier: "AuthenticatedViewController") as! AuthenticatedViewController
        if let window = self.window {
            let navigationController: UINavigationController = storyboard.instantiateInitialViewController() as! UINavigationController
            navigationController.viewControllers = [authenticatedVC]
            window.rootViewController = navigationController
        }
    }
    
    func authenticateUserWithTouchID () {
        let context: LAContext = LAContext()
        // for cancel button (defaults to "cancel"
        context.localizedCancelTitle = "I give up"
        // for fall back (e.g use passcode that appears after first failure
        context.localizedFallbackTitle = "I prefer Passcode"
        context.maxBiometryFailures = 5
        
        // for reason to ask for authentication
        let myLocalizedReasonString = "So we know you have given consent to access your personal app data."
        
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
                        self?.displayAuthenticatedViewController()
                    }
                }
                else
                {
                    guard let error = evaluateError else {
                        print ("not successful, no error either while doing Touch ID authentication. Hmm")
                        return
                    }
                    
                    print (self?.showErrorMessageForLAErrorCode(errorCode: error._code) ?? "There was error")
                }
            }
        }
        else // touch id authentication is not successful
        {
            if let error = authError
            {
                let message = self.showErrorMessageForLAErrorCode( errorCode: error.code )
                print (">> Auth error message: ", message)
            }
        }
    }
    
    func showErrorMessageForLAErrorCode (errorCode: Int ) -> String {
        var message = ""

        switch errorCode {
        case LAError.appCancel.rawValue:
            message = "Authentication was cancelled by application."
            
        case LAError.authenticationFailed.rawValue:
            message = "User failed to provide valid credentials."
            
        case LAError.invalidContext.rawValue:
            message = "The context is invalid."
            
        case LAError.passcodeNotSet.rawValue:
            message = "Passcode has not been set on the device."
            
        case LAError.systemCancel.rawValue:
            message = "Authentication was canceled by system (e.g. another application went to foreground)."
            
        // XXX: checkout the behavior for this error code and figure how to configure the max touch id
        case LAError.biometryLockout.rawValue:
            message = "Authentication was not successful, because there were too many failed biometry attempts and biometry is now locked."
            
        case LAError.biometryNotEnrolled.rawValue:
            message = "Authentication could not start, because biometry has no enrolled identities."
            
        case LAError.biometryNotAvailable.rawValue:
            message = "Authentication could not start, because biometry is not available on the device."
            
        case LAError.userCancel.rawValue:
            message = "Authentication was canceled by user (e.g. tapped Cancel button)."
            
        case LAError.userFallback.rawValue:
            message = "Authentication was canceled, because the user tapped the fallback button (Enter Password)."
            
        case LAError.notInteractive.rawValue:
            message = "Authentication failed, because it would require showing UI which has been forbidden by using interactionNotAllowed property."
            
        default:
            message = "Authentication with Touch ID failed, but we did not find error code on LAError object."
        }
        
        return message
    }
}
