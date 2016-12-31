//
//  LoginViewController.swift
//  Messenger Clone 2.0
//
//  Created by Rey Cerio on 2016-11-19.
//  Copyright © 2016 CeriOS. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import GoogleSignIn
import TwitterKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate {
    
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
        
        setupFacebookButtons()
        
        setupGoogleButtons()
        
        setupTwitterButton()
        
    }
    
    fileprivate func setupTwitterButton() {
        
        let twitterButton = TWTRLogInButton { (session, error) in
            if let err = error {
                
                print("Failed to log in to Twitter:", err)
                return
            }
        
            print("Successfully logged into Twitter!")
            //log in to firebase
            guard let token = session?.authToken else {return}
            guard let secret = session?.authTokenSecret else {return}
            
            let credentials = FIRTwitterAuthProvider.credential(withToken: token, secret: secret)
            
            FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
                
                if let err = error {
                    
                    print("Failed to log into Firebase with Twitter:", err)
                    return
                }
                
                guard let uid = user?.uid else {return}
                print("Successfully created a firebase twitter user:", uid)
                
            })
        
        }
        view.addSubview(twitterButton)
        twitterButton.frame = CGRect(x: 25, y: 512 + 46 + 46, width: view.frame.width - 40, height: 30)
        
    }
    
    fileprivate func setupGoogleButtons() {
        
        //google sign in button
        let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: 25, y: 512, width: view.frame.width - 40, height: 20)
        view.addSubview(googleButton)
        
        
        //custom googleButton, type .system so it has a down state when pressed
        let customGoogleButton = UIButton(type: .system)
        customGoogleButton.frame = CGRect(x: 25, y: 512 + 46 + 1, width: view.frame.width - 40, height: 30)
        customGoogleButton.backgroundColor = UIColor.purple
        customGoogleButton.setTitle("Custom Google Sign In Button", for: .normal)
        customGoogleButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        customGoogleButton.setTitleColor(.white, for: .normal)
        customGoogleButton.addTarget(self, action: #selector(handleCustomGoogleSignin), for: .touchUpInside)
        view.addSubview(customGoogleButton)
        
        //needs GIDsignInUIDelegate as a type for class
        GIDSignIn.sharedInstance().uiDelegate = self

    }
    
    func handleCustomGoogleSignin() {
        //all you need...WTF?!?!?
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    fileprivate func setupFacebookButtons(){
        
        //initiallizing the facebook button
        let loginButton = FBSDKLoginButton()
        view.addSubview(loginButton)
        loginButton.frame = CGRect(x: 25, y: 420, width: view.frame.width - 50, height: 30)
        //if you dont specify this, it wont show the email
        loginButton.readPermissions = ["public_profile", "email"] //add friends list if you want
        //needs FBSDKLoginButtonDelegate
        loginButton.delegate = self
        
        //adding custom FB login button here...adding type: .system gives the button a down state
        let customFBButton = UIButton(type: .system)
        customFBButton.backgroundColor = UIColor.blue
        customFBButton.frame = CGRect(x: 25, y: 466, width: view.frame.width - 50, height: 30)
        customFBButton.setTitle("Custom FB Login Button", for: .normal)
        customFBButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        customFBButton.setTitleColor(.white, for: .normal)
        view.addSubview(customFBButton)
        //calls handleCustomFBLogin when pressed
        customFBButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
        
    }
    
    func handleCustomFBLogin() {
        
        FBSDKLoginManager().logIn(withReadPermissions: ["public_profile", "email"] , from: self) { (result, error) in
            if error != nil {
                
                print("FB custom Login Failed:", error!)
                return
                
            }
            //print out the user info
            print(result!.token.tokenString)
            self.showEmailAddress()
        }
        
    }
    
    //method called when logged out. needed by FBSDKLoginButtonDelegate
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did logout of FACEBOOK!!")
    }
    //method called when logging in. needed by FBSDKLoginButtonDelegate
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            
            print(error)
            return
            
        }
        
        showEmailAddress()
        print("Successfully logged in with facebook!!!!")
        
    }
    
    func showEmailAddress() {
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else {
            return
        }
        
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
            if error != nil {
                
                print("Failed to login with Facebook:", error ?? "")
                return
            }
            print("Successfully logged in with our user:", user ?? "")
            
        })
        
        //graph request retrieves the user info
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start { (connection, result, error) in
            
            if error != nil {
                
                print("Failed to start graph request:", error ?? "")
                return
                
            }
            
            print(result ?? "")
            
        }

        
    }

}



















