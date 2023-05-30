//
//  SettingViewController.swift
//  VideoPhotoSecrete2
//
//  Created by Macmini on 30/05/2023.
//

import UIKit
import PasscodeKit

class SettingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
       
    }
    
    @IBAction func creatPCBtn(_ sender: UIButton) {
        if PasscodeKit.enabled() {
            let alert = UIAlertController(title: "PassCode has existed", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
        else {
            PasscodeKit.createPasscode(self)
        }
    }
    
    @IBAction func changePCBtn(_ sender: UIButton) {
        if !PasscodeKit.enabled() {
            let alert = UIAlertController(title: "PassCode does not exist", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
        else {
            PasscodeKit.changePasscode(self)
        }
    }
    
    @IBAction func removePcBtn(_ sender: UIButton) {
        if !PasscodeKit.enabled() {
            let alert = UIAlertController(title: "PassCode does not exist", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
        else {
            PasscodeKit.removePasscode(self)
        }
    }
    
}
