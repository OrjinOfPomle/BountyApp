//
//  EditChannelVC.swift
//  Bounty
//
//  Created by Keleabe M. on 6/23/20.
//  Copyright © 2020 FireflyGlobe. All rights reserved.
//

import UIKit
import FirebaseStorage
import Firebase
import Kingfisher
import SafariServices

class EditChannelVC: UIViewController {
    
    var imageHolder : UIImage!
    var lastClicked : String!
    let banner = "Banner"
    let profile = "Profile"
    var uId : String!
    var db: Firestore!
    var newProfileSelected = false
    var newBannerSelected = false
    var newNameSelected = false

    
    @IBOutlet weak var currentName: UILabel!
    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var newChannelNameTF: UITextField!
    @IBOutlet weak var setpPaymentSystem: UIButton!
    
    @IBAction func SetupPayment(_ sender: Any) {
        
        
    }
    @IBAction func updateProfileImage(_ sender: Any) {
        lastClicked = profile
        launchImagepicker()
    }
    @IBAction func PaymentSystem(_ sender: Any) {
    }

    @IBAction func updateInfo(_ sender: Any) {
        
        checkAndUpdateNewName( completion: { (isSucceeded) in
             if isSucceeded {
                self.uploadImageThenDocument()
             } else {
                 //user does not exist, do something else
             }
         })
        //showSpinner()
        //uploadImageThenDocument()
        
    }
    
   
    
    @IBAction func updateBannerImage(_ sender: Any) {
        lastClicked = banner
        launchImagepicker()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        uId = Auth.auth().currentUser?.uid
        db = Firestore.firestore()
        fetchCurrentUsersChannel()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func fetchCurrentUsersChannel(){
        let ref = db.collection("channels").whereField("uId", isEqualTo: uId ?? "").limit(to: 1)
        
        ref.getDocuments { (snap, error) in
            guard let data = snap?.documents else {
                print(error.debugDescription)
                return
            }
            print("this far 5")
            print(data.count)
            if(data.count >= 1){
                        print("this far 4")
                self.newChannelNameTF.isHidden = true
                let newChannel = ChannelInfo.init(data: ((data[0]).data()))
                if(newChannel.image.count > 4){
                    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2
                    if let url = URL(string: newChannel.image){
                        self.profileImage.kf.setImage(with: url)
                    }
                }
                if(newChannel.Banner.count > 4){
                    if let url = URL(string: newChannel.Banner){
                        self.bannerImage.kf.setImage(with: url)
                    }
                }
                if(newChannel.channelName.count >= 1){
                    self.currentName.text = newChannel.channelName
                }else{
                    self.showSimpleAlert(Message: "new Account")
                }
            }else{
                self.showSimpleAlert(Message: "data didnt exist == ")
            }
        }
    }
    
    //needed to use completion because i had to return out of a method
    //https://stackoverflow.com/questions/54129443/unexpected-non-void-return-value-in-void-function-swift-4-firebase-firestore
    
    func checkAndUpdateNewName(completion: @escaping (Bool) -> Void){
                print("this far 2")
        let newName = newChannelNameTF.text ?? ""
        let restricted = CharacterSet(charactersIn: "=.$[]#/")
        
        if(newChannelNameTF.isHidden){
                completion(true)
                
        }else if(newName.count <= 0){
            showSimpleAlert(Message: "A channel name is required")
            completion(false)
        }else{
            if newName.rangeOfCharacter(from: restricted) != nil {
                showSimpleAlert(Message: ".$[]#/ are not allowd ")
                completion(false)
            }
            if newName.count > 25{
                showSimpleAlert(Message: "Channel name needs to be less than 25 characters")
                completion(false)
            }
                
                // check if the new string is unique
                // then if it is update if not ask for a new name
                
                let ref = db.collection("channels").document(newName)
            ref.getDocument { (snap, error) in
                if let document = snap{
                    if document.exists{
                        self.showSimpleAlert(Message: "This channel name already exists please choose another and try again")
                        completion(false)
                    }else {
                        self.currentName.text = newName
                        //update the database
                        var newRef = self.db.collection("channels").document(newName)
                        let data :[String : Any] = [
                            "uId": self.uId ?? "",
                            "Id" : newName,
                            "Name" : newName,
                            "IsActive" : true,
                            "SubsCount" : 0
                        ]
                        newRef.setData(data, merge: true) { (error) in
                            if let error = error{
                                debugPrint(error.localizedDescription)
                                return
                            }
                        }
                        
                        newRef = self.db.collection("ChannelInfo+Comments").document(newName)
                        
                        let dataTwo :[String : Any] = [
                        "owner": self.uId ?? "",
                        "Name" : newName
                        ]
                        
                        newRef.setData(dataTwo, merge: true) { (error) in
                            if let error = error{
                                debugPrint(error.localizedDescription)
                                return
                            }
                        }
                       
                        


                        completion(true)
                    }
                }
            }
            }
            
    }
    
    func uploadImageThenDocument() {
        print("this far 3")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
    
        if(bannerImage.image != nil && newBannerSelected){
            print("bannerImage is not nil" )
            guard let image = bannerImage.image else{
                print("error with banner selected image")
                return
            }
            guard let imageData = image.jpegData(compressionQuality: 0.2) else{ return }
            
            let imageRef = Storage.storage().reference().child("/Channel/\(uId ?? "udi")/Banner.jpg")
            
            print("here 1")
            imageRef.putData(imageData, metadata: metadata){
                (metadata, error) in
                if let error = error{
                    debugPrint(error.localizedDescription)
                    self.removeSpinner()
                    return
                    
                }
                imageRef.downloadURL { (url, error) in
                    print("this is where i am")
                    if let error = error{
                        debugPrint(error.localizedDescription)
                        self.removeSpinner()
                        return
                    }
                    
                    guard let url = url else{
                        return
                    }
                    var ref = self.db.collection("ChannelInfo+Comments").document(self.currentName.text!)
                                       
                    ref.setData(["bannerImage" : url.absoluteString], merge: true)
                    
                    ref = self.db.collection("channels").document(self.currentName.text!)
                    ref.setData(["Banner" : url.absoluteString], merge: true)
                                       
                                       
                    
//                    let ref = self.db.collection("ChannelInfo+Comments").whereField("owner", isEqualTo:  self.uId ?? "").limit(to: 1)
//                    ref.getDocuments{ (snap, error) in
//                        guard let data = snap?.documents else {
//                            print(error.debugDescription)
//                            return
//                        }
//                        if(data[0].exists){
//                            data[0].reference.setData(["bannerImage" : url.absoluteString], merge: true)
//                        }else{
//                            print("error data did not exist")
//                        }
//                    }
                    //we update the url into the database
                    print(url)
                    //we update name if provided
                    self.removeSpinner()
                }
                
                
            }
            
        }else{
            print("banner was empty")
        }
        
        
        if(profileImage.image != nil && newProfileSelected){
            print("profileimage is not nil")
            guard let image = profileImage.image else{
                print("error with the selected image")
                return
            }
            guard let imageData = image.jpegData(compressionQuality: 0.2) else{ return }
            
            let imageRef = Storage.storage().reference().child("/Channel/\(uId ?? "uIi")/Profile.jpg")
            
            
            imageRef.putData(imageData, metadata: metadata){
                (metadata, error) in
                if let error = error{
                    debugPrint(error.localizedDescription)
                    self.removeSpinner()
                    return
                }
                imageRef.downloadURL { (url, error) in
                    if let error = error{
                        debugPrint(error.localizedDescription)
                        self.removeSpinner()
                        return
                    }
                    
                    guard let url = url else{
                        return
                    }
                    //we update the url into the database
                    print(url)
                    
                    let ref = self.db.collection("channels").document(self.currentName.text!)
                    
                    ref.setData(["Image" : url.absoluteString], merge: true)
                    
                    
//                    let ref = self.db.collection("channels").whereField("uId", isEqualTo:  self.uId ?? "").limit(to: 1)
//                    ref.getDocuments{ (snap, error) in
//                        guard let data = snap?.documents else {
//                            print(error.debugDescription)
//                            return
//                        }
//                        if(data[0].exists){
//                            data[0].reference.setData(["Image" : url.absoluteString], merge: true)
//                        }else{
//                            print("error data did not exist")
//                        }
//                    }
                    
                    //we update name if provided
                     self.showSimpleAlert(Message: "Information has been updated")
                    self.removeSpinner()
                }
                
            }
        }else{
        print("profile image was nil")
        }
        removeSpinner()
        
    }
    


}
extension EditChannelVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func launchImagepicker(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self


        present(imagePicker,animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        guard let image = info[.originalImage] as? UIImage else {
            return
        }

        if(lastClicked.elementsEqual(banner)){
            bannerImage.contentMode = .scaleAspectFill
            bannerImage.image = image
            newBannerSelected = true
            
        }else if(lastClicked.elementsEqual(profile)){
            profileImage.contentMode = .scaleAspectFill
            profileImage.layer.cornerRadius = profileImage.frame.size.width/2
            profileImage.image = image
            newProfileSelected  = true
        }else{
            return
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
