//
//  LoginViewController.swift
//  VideoPhotoSecrete2
//
//  Created by Macmini on 30/05/2023.
//

import UIKit
import PasscodeKit

class LoginViewController: UIViewController {

    let userDefaults = UserDefaults.standard
    let defaultsValue = ["hasCreatedPasscode": false]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userDefaults.register(defaults: defaultsValue)
        print(userDefaults.bool(forKey: "hasCreatedPasscode"))
        //userDefaults.set(false, forKey: "hasCreatedPasscode")
        if !userDefaults.bool(forKey: "hasCreatedPasscode") {
            PasscodeKit.createPasscode(self)
            userDefaults.set(true, forKey: "hasCreatedPasscode")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        performSegue(withIdentifier: "menuSegue", sender: self)
    }
    
}
