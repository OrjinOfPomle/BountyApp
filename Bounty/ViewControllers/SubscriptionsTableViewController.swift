//
//  SubscriptionsTableViewController.swift
//  Bounty
//
//  Created by Keleabe M. on 6/8/20.
//  Copyright © 2020 FireflyGlobe. All rights reserved.
//

import UIKit
import Firebase

class SubscriptionsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    var db : Firestore!
    var Subs = [ChannelInfo]()
    var listener: ListenerRegistration!
    
    @IBOutlet weak var SubscriptionViewController: UITableView!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Subs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIDs.SubscriptionCell, for: indexPath)
        as? SubscriptionsTableViewCell else{
            fatalError("Bad Cell - ==========================================Could not cast")
        }
        cell.configureSubscriptionCell(channelInfo: Subs[indexPath.row])
        return cell
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func setSubs(){
        guard let uId = Auth.auth().currentUser?.uid else {
            return}
        print("here 4")
        
        //------>
        
        let ref = db.collection("users").document(uId).collection("Subscriptions")
           listener = ref.addSnapshotListener{ (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            print("snap count")
            print(snap?.documentChanges.count)
                
            snap?.documentChanges.reversed().forEach({ (change) in
                let data = change.document.data()
                
                switch change.type{
                case .added:
                    self.onDocumentAdded(data: data, change: change)
                case .modified:
                    self.onDocumentModified(change: change)
                case .removed:
                    self.onDocumentRemoved(change: change)
                }
            })
                
        }
    }
    
    func onDocumentAdded(data : [String: Any] ,change: DocumentChange){
        let newIndex = Int(change.newIndex)
        print("new index")
        print(newIndex)
        GetSingleChannelInfo(data: data, newIndex: newIndex)
    }
    
    func onDocumentModified(change: DocumentChange){
    }
    func onDocumentRemoved(change: DocumentChange){
        let oldIndex = Int(change.oldIndex)
        Subs.remove(at: oldIndex)
        SubscriptionViewController.deleteRows(at: [IndexPath(row: oldIndex, section: 0)], with: UITableView.RowAnimation.fade)
    }
            

    func GetSingleChannelInfo(data : [String: Any], newIndex : Int){
        print("8")
        let id = data["channelId"] as? String ?? ""
        print("ID - ")
        print(id)
        let ref = db.collection("channels").document(id)
        
        ref.getDocument { (snap, error) in
            guard let data = snap?.data() else {
            print(error.debugDescription)
            return}
            
            let newSub = ChannelInfo.init(data: data)
            print(newSub.channelName)
            print("subs count")
            print(self.Subs.count)
            print("new Index")
            print(newIndex)
                        
            if(newSub.isActive){
                self.Subs.insert(newSub, at: newIndex)
                //this needs to be here because this whole thing is done independatn of each other.
                
                print(self.Subs.count)
                self.SubscriptionViewController.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: UITableView.RowAnimation.fade)
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let clickedChannel = Subs[indexPath.row]
        let vc = storyboard?.instantiateViewController(withIdentifier: "CommentsTableView") as? CommentsTableViewController
        vc?.modalPresentationStyle = .fullScreen
        vc?.selectedChannel = clickedChannel
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        print("listener was removed")
        listener.remove()
    }

    override func viewDidDisappear(_ animated: Bool) {
        Subs.removeAll()
        SubscriptionViewController.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        setSubs()
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

}
