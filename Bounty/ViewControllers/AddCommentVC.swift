//
//  AddCommentVC.swift
//  Bounty
//
//  Created by Keleabe M. on 7/17/20.
//  Copyright © 2020 FireflyGlobe. All rights reserved.
//

import UIKit
import Stripe

class AddCommentVC: UIViewController {
    
    var selectedComment : Comment!
    var paymentContext: STPPaymentContext!

    @IBOutlet weak var bountyAmountTF: UITextField!
    
    @IBOutlet weak var commentImage: UIImageView!
    @IBOutlet weak var commentText: UILabel!
    
    @IBAction func addBounty(_ sender: Any) {
        
        guard let amount = Int(bountyAmountTF.text ?? "0") else{
            showSimpleAlert(Message: "Please input an acceptable amount")
            return
        }
        if(amount <= 0){
            showSimpleAlert(Message: "Please input an acceptable amount")
                       return
        }
        // amount needs to be in pennies
        paymentContext.paymentAmount = (amount  * 100)
        //paymentContext.pushPaymentOptionsViewController()
        
        paymentContext.requestPayment()
        showSpinner()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStripeConfig()
        
        commentImage.layer.cornerRadius = commentImage.frame.size.width/2
        
        if let url = URL(string: selectedComment.Image){
            commentImage.kf.setImage(with: url)
        }
        commentText.text = selectedComment.Comment


        
    }
    
    func checkAccountInfo(){
        
    }
    func addAmountToBounty(){
        
    }
    func increaceTheSupporterCount(){
        
    }
    
    func setupStripeConfig(){
        let config = STPPaymentConfiguration.shared()
        config.requiredBillingAddressFields = .none
        
        let customerContext = STPCustomerContext(keyProvider: StripeApi)
        
        paymentContext = STPPaymentContext(customerContext: customerContext, configuration: config, theme: .default())
        
        paymentContext.delegate = self
        paymentContext.hostViewController = self
        
    }
}

extension AddCommentVC : STPPaymentContextDelegate{
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
    
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.navigationController?.popViewController(animated: true)
        }
        let retry = UIAlertAction(title: "Retry", style: .default) { (action) in
                self.paymentContext.retryLoading()
            }
            
        alertController.addAction(cancel)
        alertController.addAction(retry)
        present(alertController,animated: true,completion: nil)
        
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        
    }
    
    
}
