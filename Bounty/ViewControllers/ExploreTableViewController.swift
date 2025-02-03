//
//  ExploreTableViewController.swift
//  Bounty
//
//  Created by Keleabe M. on 6/7/20.
//  Copyright © 2020 FireflyGlobe. All rights reserved.
//

import UIKit
import Firebase

class ExploreTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var searchOff = true
    let searchbar = UISearchBar()
    var db : Firestore!
    var ExploreSubs = [ChannelInfo]()
    
    @IBOutlet weak var ExploreTableView: UITableView!
    
    @IBAction func searchclicked(_ sender: Any) {
        searchbar.delegate = self
        searchbar.sizeToFit()
        if(searchOff){
            
            searchbar.isHidden = false
            navigationItem.titleView = searchbar
            searchOff = false
        }else{
            searchOff = true
            searchbar.isHidden = true
            navigationItem.titleView = nil
        }
    }
    

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ExploreSubs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {        //let cell = UITableViewCell(style: UITableViewCell.CellStyle.default , reuseIdentifier: CellIDs.ExploreCell)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIDs.ExploreCell, for: indexPath)
        as? ExploreTableViewCell else{
            fatalError("Bad Cell - ==========================================Could not cast")
        }
        cell.configureExploreCell(channelInfo: ExploreSubs[indexPath.row])

        return cell
    }



    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        setChannels()
        preLoadAllViews()

        //fetchDoc()
//        fetchCollection()
        
        
    }
//
//    func fetchDoc(){
//        let ref = db.collection("channels").document("FGAJsElWLqMZEwFluTAg")
//        print("here 1 ")
//        ref.getDocument { (snap, Error) in
//            print("did get in here ======================")
//            guard let data = snap?.data() else {
//                print(Error.debugDescription)
//                return}
//
//            let newChannel = ChannelInfo.init(data: data)
//
//            if(newChannel.isActive){
//                self.ExploreSubs.append(newChannel)
//                self.ExploreTableView.reloadData()
//            }
//        }
//
//
//    }
    func setChannels(){
        // search/filter catoagoris and documents by what they contain ->
        //.whereField("Name", isEqualTo: "Garyvee")
        // order by ->
        //
        let ref = db.collection("channels")
        ref.getDocuments{ (snap, error) in
            if let error = error{
                debugPrint(error.localizedDescription)
                return
            }
            guard let documents = snap?.documents else {return}
            for doc in documents {
                print("\n reloaded information")
                let data = doc.data()
                let channel = ChannelInfo.init(data: data)
                if(channel.isActive){
                        self.ExploreSubs.append(channel)
                    }
                self.ExploreTableView.reloadData()
                }
                    
        }
    }
    
    func fetchCollection(){
        let ref = db.collection("channels")
        ref.getDocuments { (snap, error) in
            guard let documents = snap?.documents else {return}
            for doc in documents {
                let data = doc.data()
                let newChannel = ChannelInfo.init(data: data)
                if(newChannel.isActive){
                    self.ExploreSubs.append(newChannel)
                }
            self.ExploreTableView.reloadData()
            }
        }
        
    }
    
    func fetchCollectionInRealTime(){
        
    }
    
    func onDocumentAdded(change: DocumentChange, channel: ChannelInfo){
        let newIndex = Int(change.newIndex)
        ExploreSubs.insert(channel, at: newIndex)
        ExploreTableView.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: UITableView.RowAnimation.fade)
    }
    
    func onDocumentModified(change: DocumentChange, channel: ChannelInfo){
        if change.newIndex == change.oldIndex{
            let index = Int(change.newIndex)
            ExploreSubs[index] = channel
            ExploreTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: UITableView.RowAnimation.fade)
        }else{
            let oldIndex = Int(change.oldIndex)
            let newIndex = Int(change.newIndex)
            ExploreSubs.remove(at: oldIndex)
            ExploreSubs.insert(channel, at: newIndex)
            
            ExploreTableView.moveRow(at: IndexPath(row: oldIndex, section: 0), to: IndexPath(row: newIndex, section: 0))
        }
    }
    func onDocumentRemoved(change: DocumentChange){
        let oldIndex = Int(change.oldIndex)
        ExploreSubs.remove(at: oldIndex)
        ExploreTableView.deleteRows(at: [IndexPath(row: oldIndex, section: 0)], with: UITableView.RowAnimation.fade)
    }
    
    
    func preLoadAllViews(){
        for viewController in tabBarController?.viewControllers ?? [] {
            if let navigationVC = viewController as? UINavigationController, let rootVC = navigationVC.viewControllers.first {
                let _ = rootVC.view
            } else {
                let _ = viewController.view
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let clickedChannel = ExploreSubs[indexPath.row]
        let vc = storyboard?.instantiateViewController(withIdentifier: "CommentsTableView") as? CommentsTableViewController
        vc?.modalPresentationStyle = .fullScreen
        vc?.selectedChannel = clickedChannel
        self.tabBarController?.tabBar.isHidden = true
        
        self.navigationController?.pushViewController(vc!, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {

    }
    
//*********************************
        // If you use a ui view with a table view in it, this is required
        
        //ExploreTV.delegate = self
        //ExploreTV.dataSource = self
       
        //this can be done in storyboard by connecting the tableview from the menu to the ref outlet
        
        
//*********************************ć
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

    // MARK: - Table view data source

   /* override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
     */
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
