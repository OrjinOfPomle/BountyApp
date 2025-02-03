//
//  ViewController.swift
//  Bounty
//
//  Created by Keleabe M. on 5/24/20.
//  Copyright © 2020 FireflyGlobe. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseUI


class ViewController: UIViewController{
var ref: DatabaseReference!

override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    ref = Database.database().reference()
}

override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(false)
    if CheckInternet.Connection(){
        //self.showSpinner()
        if ref != nil{
            if Auth.auth().currentUser?.uid != nil{
                let uid = Auth.auth().currentUser?.uid
                if UserService.userListener == nil {
                    UserService.getCurrentUser()
                }
                //self.removeSpinner()
                print("ref was not nil and the user was authenticated ---- \(uid ?? "no Auth warning")")
                performSegue(withIdentifier: Segue.loginSegue, sender: self)
            }else{
                print("not Authenticated -------")
            }
        }else{
            print("not authenticated ----- ")
            // do nothing, they have to click the button
        }
    }else{
        let alert = UIAlertController(title: "Check internet Connection and try again", message: "", preferredStyle: .alert)
                   alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                   self.present(alert, animated: true)
    }
}
    

    @IBAction func LoginTapped(_ sender: UIButton) {
        print("here 2")

        // https://www.youtube.com/watch?v=brpt9Thi6GU - firebase setup
            //get the default auth ui
            let authUI = FUIAuth.defaultAuthUI()
            
            // set ourselves as default delegate
            guard authUI != nil else{
                print("here 3")
                //log error
                return
            }
            
            //get a ref to the auth ui view controller
            
            //this causes error until extention is implemented
            authUI?.delegate = self
            
            let providers: [FUIAuthProvider] = [
              FUIGoogleAuth()
            ]
            authUI?.providers = providers
            
            let authViewController = authUI!.authViewController()
            
            authViewController.modalPresentationStyle = .fullScreen
        
            //show it
            present(authViewController, animated: true, completion: nil)
    }
    
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
      if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
        return true
      }
      // other URL handling goes here.
      return false
    }
    
    override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    }

}
extension ViewController: FUIAuthDelegate{
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?){
        
        guard error == nil else {
            return
        }
        performSegue(withIdentifier: Segue.loginSegue, sender: self)
    }
}
    
