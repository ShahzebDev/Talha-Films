//
//  AppDelegate.swift
//  Talha Films
//
//  Created by Moazzam Tahir on 24/05/2019.
//  Copyright © 2019 Moazzam Tahir. All rights reserved.
//

import UIKit
import GoogleSignIn
import FacebookCore
import FacebookLogin
import FBSDKCoreKit
import Firebase
import FirebaseAuth
import Network
import GoogleMobileAds
import SVProgressHUD
import UserNotifications
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,GIDSignInDelegate {

    var window: UIWindow?
    let userCurrent = UNUserNotificationCenter.current()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        check()
        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self
    ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }
//    func register(){
//        let userCurrent = UNUserNotificationCenter.current()
//        userCurrent.requestAuthorization(options: [.alert,.sound,.badge]) { (permission, error) in
//            if !permission{
//                print("User is not granted permissions")
//            }else{
//                print("User has granted permissions")
//            }
//
//        }
//    }

    func check(){
        if UserDefaults.standard.value(forKey: "email") != nil{
            let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "navStory")
            let nvc = UINavigationController(rootViewController: vc)
            let share = UIApplication.shared.delegate as? AppDelegate
            share?.window?.rootViewController = nvc
            share?.window?.makeKeyAndVisible()
        }else{
            let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "UserProfile")
            let nvc = UINavigationController(rootViewController: vc)
            let share = UIApplication.shared.delegate as? AppDelegate
            share?.window?.rootViewController = nvc
            share?.window?.makeKeyAndVisible()
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return ApplicationDelegate.shared.application(app, open: url, options: options)
        return GIDSignIn.sharedInstance().handle(url as URL?,
                                                 sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            // Perform any operations on signed in user here.
            guard let userId = user.userID  else {return}             // For client-side use only!
            guard let idToken = user.authentication.idToken else {return}// Safe to send to the server
            guard let fullName = user.profile.name else {return}
            guard  let givenName = user.profile.givenName else {return}
            guard let familyName = user.profile.familyName else {return}
            guard let email = user.profile.email else {return}
            // ...
            
            print(userId)
            print(idToken)
            print(fullName)
            print(givenName)
            print(familyName)
            print(email)
            UserDefaults.standard.set(email, forKey: "email")
            let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "navStory")
            let nvc = UINavigationController(rootViewController: vc)
            let share = UIApplication.shared.delegate as? AppDelegate
            share?.window?.rootViewController = nvc
            share?.window?.makeKeyAndVisible()
        }
        
        
        guard let authentication = user.authentication else {return}
        let credential =  GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (result, error) in
            if let err = error{
                print("firebase signed in error",err.localizedDescription)
                return
            }
            print("User is signed with firebase")
        }
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("user is disconnected.")
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
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

