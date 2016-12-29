//
//  UserCollectionViewController.swift
//  Messenger Clone 2.0
//
//  Created by Rey Cerio on 2016-11-22.
//  Copyright © 2016 CeriOS. All rights reserved.
//

//HAVE TO USE A STRUCT TO POPULATE THE UICOLLECTIONVIEW!!!!!!!!!!!!!!!!*******************************

//Or maybe not.....this works too

import UIKit
import Firebase

class UserCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    /*
    struct userObject {
        
        var userName: String
        var userEmail: String
        var userProfilePicture: String?
        
    }
    */
    var user: [User] = []
    
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        collectionView.delegate = self
        
        collectionView.dataSource = self
        
        fetchUser()

    }
    
    func fetchUser() {
        
        FIRDatabase.database().reference().child("users").observe(FIRDataEventType.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let users = User()
                
                users.name = dictionary["name"] as! String?
                users.profileImageURL = dictionary["profileImageURL"] as! String?
                users.email = dictionary["email"] as! String?
                users.password = dictionary["password"] as! String?
                
                self.user.append(users)
                
                 DispatchQueue.main.async(execute: {
                 
                 
                 self.collectionView?.reloadData()
                 
                 })
                 
                
            }
            
            print(snapshot)
            
        }, withCancel: nil)
        
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return user.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userCell", for: indexPath) as! UserCollectionViewCell
        
        let cellUsers = user[indexPath.row]
        
        cell.userNameLabel.text = cellUsers.name
        
        if let profileImageURL =  cellUsers.profileImageURL {
            
            cell.userImageView?.loadImageUsingCacheWithUrlString(urlString: profileImageURL)
        }

        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        
    }
    
}
