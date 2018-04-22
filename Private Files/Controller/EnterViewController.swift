//
//  AddPasswordViewController.swift
//  Private Files
//
//  Created by Egor on 22.04.2018.
//  Copyright © 2018 Chernenko Inc. All rights reserved.
//

import UIKit
import LocalAuthentication

class EnterViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    class var identifier: String {
        return String(describing: self)
    }
    var hasPassword = false
    
    @IBAction func appleButtonPressed(_ sender: UIButton) {
        guard let password = passwordTextField.text, password.count >= 6 else {return}
        
        if !hasPassword{
            UserDefaults.standard.set(password, forKey: "password")
            performSegue(withIdentifier: EnterViewController.identifier, sender: nil)
        } else {
            if let userPassword = UserDefaults.standard.string(forKey: "password") {
                if userPassword == password{
                    performSegue(withIdentifier: EnterViewController.identifier, sender: nil)
                } else {
                    let alert = UIAlertController(title: "Incorrect password", message: nil, preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }

    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.string(forKey: "password") != nil{
            hasPassword = true
            
            let context = LAContext()
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil){
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Use TouchID to enter", reply: { success, error in
                    if success{
                        self.performSegue(withIdentifier: EnterViewController.identifier, sender: nil)
                    } else {
                        let alert = UIAlertController(title: "Use password to get access", message: nil, preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
        } else {
            let alert = UIAlertController(title: "Hello", message: "Please add password to use application", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
}
