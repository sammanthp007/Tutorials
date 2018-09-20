//
//  AuthenticatedViewController.swift
//  Touch ID With LocalAuthentication
//
//  Created by Samman Thapa on 9/20/18.
//  Copyright © 2018 Samman Thapa. All rights reserved.
//

import UIKit
import LocalAuthentication

class AuthenticatedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTappingAuthenticateMeButton(_ sender: Any) {
        print (">> show touch id for authentication")
        self.authenticateUserWithTouchID()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AuthenticatedViewController {
    func authenticateUserWithTouchID () {
        let context: LAContext = LAContext()
        
        // reason for authentication
        let myLocalizedReasonString = "Authenticate to access your app account."
        
        // error variable
        var authError: NSError?
        
        // XXX: so there should be a else statement too, check it out
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError)
        {
            print ("Authentication Possible")
            
            // if closure uses self, ensure that there is no ratain cycle
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: myLocalizedReasonString) { (successBool, evaluateError) in
                // if touch id authentication is successful
                if successBool
                {
                    // always do UI activity in UI thread so that eventhough this is in a closure, it gets high priority
                    DispatchQueue.main.async {
                        print (">> Authentication successful")
                        // do things here
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
