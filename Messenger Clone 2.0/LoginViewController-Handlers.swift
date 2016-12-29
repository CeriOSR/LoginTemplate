//
//  LoginViewController-Handlers.swift
//  Messenger Clone 2.0
//
//  Created by Rey Cerio on 2016-11-19.
//  Copyright © 2016 CeriOS. All rights reserved.
//

import UIKit
import Firebase

extension LoginViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    func handleRegister(){
        
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text
            
            else {
                
                createAlert(title: "Form Invalid", message: "Please a valid email and password")
                
                return
                
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
            
            if let error = error as? NSError {
                
                self.createAlert(title: "Error Authenticating!", message: String(describing: error))
                print(error)
                
                return
                
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            let imageName = NSUUID().uuidString
            
            let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).jpg")
            
            
            if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
 
                storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                    
                    if error != nil {
                        print(error ?? "No image found.")
                        return
                    }
                    
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                        
                        let values = ["name": name, "email": email, "password": password, "profileImageURL": profileImageUrl]
                                            
                        self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])
                        
                    }
                    
                })
                
            }
            
        })
        
    }
    
    private func registerUserIntoDatabaseWithUID(uid:String, values: [String: AnyObject]) {
        
        let ref = FIRDatabase.database().reference(fromURL: "https://chatclone-e6fec.firebaseio.com/")
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
            
            if let error = error as? NSError {
                
                self.createAlert(title: "Error Authenticating!", message: String(describing: error))
                print(error)
                
                return
                
            }
            
            let user = User()
            user.setValuesForKeys(values)
            //self.messageController?.setupNavBarWithUser(user: user)
            
            //self.dismiss(animated: true, completion: nil)
            print("User Successfully Saved Into Firebase!")
            
        })
        
        
    }
    
    
    func handleSelectProfileImageView() {
        
        let picker = UIImagePickerController()
        
        picker.delegate = self
        
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
        
    }
    //if you make this private, profileImageView will not update when you pick a picture...dumbasses!
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        var selectedImageFromPicker: UIImage?
        
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            
            selectedImageFromPicker = editedImage
            
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker {
            
            profileImageView.image = selectedImage
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
}
