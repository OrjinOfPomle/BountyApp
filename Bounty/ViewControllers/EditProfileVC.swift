//
//  EditProfileVC.swift
//  Bounty
//
//  Created by Keleabe M. on 6/25/20.
//  Copyright © 2020 FireflyGlobe. All rights reserved.
//

import UIKit
import FirebaseStorage
import Firebase
import Kingfisher

class EditProfileVC: UIViewController {
    
    var uId : String!
    var db : Firestore!
    var newProfilePicSelected = false
    var currentNameString = ""
    
    
    @IBOutlet weak var newName: UITextField!
    @IBOutlet weak var currentName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    
    @IBAction func ChangeImage(_ sender: Any) {
        launchImagepicker()
    }
    
    @IBAction func updateInfo(_ sender: Any) {
        checkAndUpdateNewName( completion: { (isSucceeded) in
            if isSucceeded {
                if(self.newProfilePicSelected){
                    self.uploadImageThenDocument()
                }
            } else {
                //user does not exist, do something else
            }
        })
        

    }
    override func viewWillAppear(_ animated: Bool) {
        uId = Auth.auth().currentUser?.uid
        db = Firestore.firestore()
        fetchCurrentUserProfile()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
  

        // Do any additional setup after loading the view.
    }
    func checkAndUpdateNewName(completion: @escaping (Bool) -> Void){
        let newProfileName = newName.text ?? ""
        let restricted = CharacterSet(charactersIn: "=.$[]#/")
        
        if(currentNameString.count >= 1 || newProfileName.count > 0){
            if(newProfileName.count <= 0){
            completion(true)
            }else{
                if newProfileName.rangeOfCharacter(from: restricted) != nil {
                    showSimpleAlert(Message: ".$[]#/ are not allowd ")
                    completion(false)
                }else if newProfileName.count > 25{
                    showSimpleAlert(Message: "Username needs to be less than 25 characters")
                    completion(false)
                }else{
                    let ref = db.collection("users").document(uId)
                    let email = Auth.auth().currentUser?.email ?? ""
                    let data :[String : Any] = [
                        "name" : newProfileName,
                        "email" : email,
                        "id" : uId!
                    ]
                    ref.setData(data, merge: true)
                    currentName.text = newProfileName
                    completion(true)
                }
            }
            
            
        }else{
            showSimpleAlert(Message: "A profile name is required")
            completion(false)
        }

            
    }
    
    func uploadImageThenDocument() {
           guard let image = profileImage.image else{
               print("error with the selected image")
               return
           }
           guard let imageData = image.jpegData(compressionQuality: 0.2) else{ return }
           
           let imageRef = Storage.storage().reference().child("/Profile/\(uId ?? "udi").jpg")
           
           let metadata = StorageMetadata()
           metadata.contentType = "image/jpg"
           
           imageRef.putData(imageData, metadata: metadata){(metadata, error) in
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
                
                let ref = self.db.collection("users").document(self.uId)
                ref.setData(["image" : url.absoluteString], merge: true)
                   //we update name if provided
                   self.removeSpinner()
               }
           }
        removeSpinner()
       }
    
    func fetchCurrentUserProfile(){
        
        let ref = db.collection("users").document(uId)
        ref.getDocument { (snap, error) in
            guard let data = snap?.data() else {
            print(error.debugDescription)
            return}
            let name = data["name"] as? String ?? ""
            let image = data["image"] as? String ?? ""
            if(name.count >= 1){
                self.currentName.text = name
            }
            if(image.count >= 1){
                if let url = URL(string: image){
                    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2
                    self.profileImage.kf.setImage(with: url)
                }
                
            }
        }
    }

}

extension EditProfileVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func launchImagepicker(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self

        present(imagePicker,animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        guard let image = info[.originalImage] as? UIImage else {
            return
        }

            profileImage.contentMode = .scaleAspectFill
            profileImage.layer.cornerRadius = profileImage.frame.size.width/2
            profileImage.image = image
            newProfilePicSelected = true
            
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
