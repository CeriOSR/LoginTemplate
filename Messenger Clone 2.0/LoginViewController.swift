//
//  LoginViewController.swift
//  Messenger Clone 2.0
//
//  Created by Rey Cerio on 2016-11-19.
//  Copyright © 2016 CeriOS. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet var nameTextField: UITextField!
    
    @IBOutlet var emailTextField: UITextField!
    
    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var loginRegisterSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var profileImageView: UIImageView!    

    @IBOutlet var loginRegisterButton: UIButton!
    
    @IBAction func loginRegisterSC(_ sender: Any) {
        
        if loginRegisterSegmentedControl.selectedSegmentIndex == 1 {
            
            loginRegisterButton.setTitle("Register", for: .normal)
            nameTextField.isHidden = false
            
        } else {
            
            loginRegisterButton.setTitle("Login", for: .normal)
            nameTextField.isHidden = true
            
        }
        
    }
    
    @IBAction func loginRegister(_ sender: Any) {
        
        handleLoginRegister()
        
    }
    
    func createAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func handleLoginRegister() {
        
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            
            handleLogin()
            
        } else {
            
            handleRegister()
            
        }
        
    }
    
    func handleLogin() {
        
        
        
        guard let email = emailTextField.text, let password = passwordTextField.text
            else {
                createAlert(title: "Form Invalid", message: "Please a valid email and password")
                return
        }
        
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if let error = error as? NSError {
                self.createAlert(title: "Error On Login", message: String(describing: error))
            }
            
            //let userController = UserCollectionViewController()
            //self.messageController?.fetchUserAndSetupNavBarTitle()
            print("USER LOGGED IN!!!")
            //self.dismiss(animated: true, completion: nil) //REINSTATE THIS AND DELETE THE PRESENT BELOW
            //self.present(userController, animated: true, completion: nil)
            self.performSegue(withIdentifier: "loginSegue", sender: self)
        })

        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        
    }

}



















