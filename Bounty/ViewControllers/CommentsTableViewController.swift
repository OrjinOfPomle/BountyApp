//
//  CommentsTableViewController.swift
//  Bounty
//
//  Created by Keleabe M. on 6/9/20.
//  Copyright © 2020 FireflyGlobe. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class CommentsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CommentCellDelegate {

    
    
    var selectedChannel : ChannelInfo!
    var db: Firestore!
    var listener : ListenerRegistration!
    var commentsArray = [Comment]()
    var subStatus = false // not subbed
    
    @IBOutlet weak var subButton: UIButton!
    @IBAction func buttonClicked(_ sender: Any) {
        
        guard let uId = Auth.auth().currentUser?.uid else {
            return}
        
        //------>
        let ref = db.collection("users").document(uId).collection("Subscriptions").document(selectedChannel.id)
        if(subStatus){
            print("true")
            ref.delete()
            subStatus = false
            self.subButton.setTitle("Subscribe", for: .normal)
        }else{
            print("false")
            ref.setData(["channelId" : selectedChannel.id])
            subStatus = true
             self.subButton.setTitle("Subscribed", for: .normal)
        }
        
        
    }
    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var CommentTableView: UITableView!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIDs.CommentCell, for: indexPath)
        as? CommentsTableViewCell else{
            fatalError("Bad Cell - ==========================================Could not cast")
        }
        cell.configureCommentCell(comment: commentsArray[indexPath.row], delegate: self)
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        checkSubStatus()
        setBannerImage()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func setBannerImage(){
        let ref = db.collection("ChannelInfo+Comments").document(selectedChannel.id)
        ref.getDocument { (snap, error) in
            guard let data = snap?.data() else {
            print(error.debugDescription)
            return}
            
            let image = data["bannerImage"] as? String ?? ""
            
            if let url = URL(string: image){
                // rounds the corners of the link image
                //let processor = RoundCornerImageProcessor(cornerRadius: 20)
                //ExploreImage.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)])
                self.bannerImage.kf.setImage(with: url)
            }
            
        }
    }
    

    
    func checkSubStatus(){
        guard let uId = Auth.auth().currentUser?.uid else {
            return}
        let ref = db.collection("users").document(uId).collection("Subscriptions").document(selectedChannel.id)
        ref.getDocument { (snap, error) in
            if snap?.exists ?? false {
                self.subStatus = true
                self.subButton.setTitle("Subscribed", for: .normal)
            }else{
                self.subStatus = false
                self.subButton.setTitle("Subscribe", for: .normal)
            }
        }
    }
    
    func getBounties(){
        let ref = db.collection("ChannelInfo+Comments").document(selectedChannel.id).collection("comments")
        listener = ref.addSnapshotListener({ (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            snap?.documentChanges.forEach({ (change) in
                let data = change.document.data()
                let comment = Comment.init(data: data)
                
                switch change.type{
                case .added:
                    self.onDocumentAdded(change: change, comment: comment)
                case .modified:
                    self.onDocumentModified(change: change, comment: comment)
                case .removed:
                    self.onDocumentRemoved(change: change)
                }
            })
        })
        
    }
    
    
    
    func onDocumentAdded(change: DocumentChange, comment: Comment){
        let newIndex = Int(change.newIndex)
        commentsArray.insert(comment, at: newIndex)
        CommentTableView.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: UITableView.RowAnimation.fade)
    }
    
    func onDocumentModified(change: DocumentChange, comment: Comment){
        if change.newIndex == change.oldIndex{
            let index = Int(change.newIndex)
            commentsArray[index] = comment
            CommentTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: UITableView.RowAnimation.fade)
        }else{
            let oldIndex = Int(change.oldIndex)
            let newIndex = Int(change.newIndex)
            commentsArray.remove(at: oldIndex)
            commentsArray.insert(comment, at: newIndex)
            
            CommentTableView.moveRow(at: IndexPath(row: oldIndex, section: 0), to: IndexPath(row: newIndex, section: 0))
        }
    }
    func onDocumentRemoved(change: DocumentChange){
        let oldIndex = Int(change.oldIndex)
        commentsArray.remove(at: oldIndex)
        CommentTableView.deleteRows(at: [IndexPath(row: oldIndex, section: 0)], with: UITableView.RowAnimation.fade)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        listener.remove()
        commentsArray.removeAll()
        CommentTableView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        getBounties()
    }
    
    func contributedToComment(comment: Comment) {
        //need to open a new page that allows you to create a comment
        
        let vc = storyboard?.instantiateViewController(withIdentifier: StoryboardIds.AddComment) as? AddCommentVC
        vc?.modalPresentationStyle = .fullScreen
        vc?.selectedComment = comment
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.pushViewController(vc!, animated: true)
        
        print(comment.UserName)
        print("contribute was clicked")
    }
    
}
    // MARK: - Table view data source


    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


