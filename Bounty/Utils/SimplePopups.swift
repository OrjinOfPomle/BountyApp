//
//  SimplePopups.swift
//  Bounty
//
//  Created by Keleabe M. on 6/30/20.
//  Copyright © 2020 FireflyGlobe. All rights reserved.
//

import UIKit

extension UIViewController{
    func showSimpleAlert(Message : String) {
        
        let alert = UIAlertController(title: Message, message: "",         preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}


