//
//  ExtraViewController.swift
//  Bounty
//
//  Created by Keleabe M. on 6/24/20.
//  Copyright © 2020 FireflyGlobe. All rights reserved.
//

import UIKit
import Firebase

class ExtraViewController: UIViewController {
    @IBAction func channelButton(_ sender: Any) {
        performSegue(withIdentifier: Segue.extraToYourChannel , sender: self)
    }
    
    
    @IBAction func profileButton(_ sender: Any) {
        performSegue(withIdentifier: Segue.extraToProfile, sender: self)
    }
    
    
    
    fileprivate func presentLogin() {
        let controller = storyboard?.instantiateViewController(withIdentifier: StoryboardIds.login) as? ViewController
        present(controller!, animated: true, completion: nil)
    }
    
    @IBAction func logOutButton(_ sender: Any) {
        
        if let _ = Auth.auth().currentUser{
            do {
                try Auth.auth().signOut()
                presentLogin()
            }catch{
                debugPrint(error.localizedDescription)
            }
        }else{
            presentLogin()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
