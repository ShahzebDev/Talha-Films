//
//  Login.swift
//  Talha Films
//
//  Created by shahzeb yousaf on 12/07/2019.
//  Copyright © 2019 Moazzam Tahir. All rights reserved.
//

import UIKit
import GoogleSignIn
import FacebookCore
import FacebookLogin
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth

class Login: UIViewController,LoginButtonDelegate,GIDSignInUIDelegate{
    @IBOutlet weak var label: UILabel!
    
    
    let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "user-1")
        return iv
    }()
    
    let ValueLabel: UILabel = {
        let val = UILabel()
        val.contentMode = .scaleAspectFit
        val.clipsToBounds = true
        val.text = "Please Login"
        val.textAlignment = .center
        val.font = UIFont(name: "HelveticaNeue-Bold", size: 20.0)
        return val
    }()
    

    
    
    func createEmailLabel(){
        if UserDefaults.standard.value(forKey: "email") != nil{
            
            ValueLabel.isHidden = true
            let emailval = UserDefaults.standard.string(forKey: "email")
            let label = UILabel(frame: CGRect(x: 30, y: 400, width: 200, height: 21))
            let maillabel = UILabel(frame: CGRect(x: 110, y: 400, width: 200, height: 21))
            //label.center = CGPoint(x: 160, y: 284)
            label.textAlignment = .left
            label.text = "Email:"
            //maillabel.text = "shahzeby68@gmail.com"
            maillabel.text = emailval
            maillabel.adjustsFontSizeToFitWidth = true
            maillabel.minimumScaleFactor = 0.6
            label.font = UIFont(name: "HelveticaNeue-Bold", size: 16.0)
            maillabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20.0)
            self.view.addSubview(label)
            self.view.addSubview(maillabel)
        }
        else{
            let _: UILabel = {
                let val = UILabel()
                val.contentMode = .scaleAspectFit
                val.clipsToBounds = true
                val.text = "Please Login"
                val.textAlignment = .center
                val.font = UIFont(name: "HelveticaNeue-Bold", size: 20.0)
                return val
            }()
            
            
        }
        
    }
    
    func configration(){
        view.addSubview(logoImageView)
        logoImageView.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 150, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 150, height: 150)
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(ValueLabel)
        ValueLabel.anchor(top: logoImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       createEmailLabel()
       configration()
        
        navigationItem.title = "Profile"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        //Intilized Google SignIn Default button.
        GIDSignIn.sharedInstance().uiDelegate = self
        let GoogleButton = GIDSignInButton(frame: CGRect(x: 16, y: 550, width: view.frame.width - 27, height: 50))
        view.addSubview(GoogleButton)
        
        // Section: 1 This piece of code will create UI Button for facebook
        
        let loginButton = FBLoginButton()
        view.addSubview(loginButton)
        loginButton.frame = CGRect(x: 16, y: 490, width: view.frame.width - 32, height: 50)
        loginButton.delegate = self
        loginButton.permissions = ["email","public_profile"]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Reachability.isConnectedToNetwork() == true
        {
            print("App is Connected with internet")
        }
        else
        {
            let controller = UIAlertController(title: "Internet Connection Required", message: "Please connect to the WiFi or Cellular Network.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            controller.addAction(ok)
            controller.addAction(cancel)
            
            present(controller, animated: true, completion: nil)
        }

    }
    
    //Will use if it is required :/
//    @objc func SignOut (_ sender: UIButton){
//        GIDSignIn.sharedInstance()?.signOut()
//    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("User is sucessfully logout")
        //Changing views from current VC back to LoginVC.
            UserDefaults.standard.removeObject(forKey: "email")
            let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "UserProfile")
            let nvc = UINavigationController(rootViewController: vc)
            let share = UIApplication.shared.delegate as? AppDelegate
            share?.window?.rootViewController = nvc
            share?.window?.makeKeyAndVisible()
    }
    
    //Method:- Facebook Button Functionality
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        //Section: 2 Starting facebook login credentials.
        
        if error != nil{
            print("Error ")
            return
        }
        print("Sucessfully logged in with facebook...")
        let accessToken = AccessToken.current
        
        guard let access = accessToken?.tokenString else {return}
        let credential = FacebookAuthProvider.credential(withAccessToken: access)
        
        
        //Get the user email and save into firebase.
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil{
                //print("Error",error?.localizedDescription)
                return
            }
            //print("sucessfully logged in with user",user)
            //Changing views from current VC back to NavVC.
            let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "navStory")
            let nvc = UINavigationController(rootViewController: vc)
            let share = UIApplication.shared.delegate as? AppDelegate
            share?.window?.rootViewController = nvc
            share?.window?.makeKeyAndVisible()
            
            //Get the current user email.
            guard let userId = Auth.auth().currentUser?.uid else {return}
            let emailval = Auth.auth().currentUser?.email
            let values = ["email": emailval]
            
            //Save the current user email to firebase database.
            Database.database().reference().child("users").child(userId).updateChildValues(values, withCompletionBlock: { (error, ref) in
                if let err =  error{
                    print("ERROR WHILE UPLOADING VALUE IN DATABASE",err.localizedDescription)
                    return
                }
                guard let uid = Auth.auth().currentUser?.uid else { return }
                print(uid)
                
                //Retrieving email from database and safely store into UserDefaults.
                Database.database().reference().child("users").child(uid).observe(.childAdded) { (snapshot) in
                    guard let email = snapshot.value as? String else{return}
                    print(email)
                    UserDefaults.standard.set(email, forKey: "email")
//                    self.label.text = email
                }
            })
         
        }
        //This piece of code will grab the user email,name,and unqiue id from facebook.
        
        GraphRequest(graphPath: "/me", parameters: ["fields": "id, name,email"]).start { (connection, result, error) in
            if error != nil{
                print(error?.localizedDescription ?? "nil")
                return
            }
            print(result.debugDescription)
        }
    }
    
}

