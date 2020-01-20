//
//  FriendCollectionViewController.swift
//  Evently
//
//  Created by Pieter De Vries on 1/7/20.
//  Copyright © 2020 Pieter De Vries. All rights reserved.
//

import UIKit

class FriendTableViewController: UITableViewController {

    var friends = [Friend]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Load the sample data.
        loadSampleFriends()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        guard let friendProfileViewController = segue.destination as? FriendProfileViewController else{
            return
        }
        
        guard let selectedEventCell = sender as? FriendTableViewCell else {
            return
        }
        
        guard let indexPath = tableView.indexPath(for: selectedEventCell) else {
            return
        }
        
        let selectedEvent = friends[indexPath.row]
        
        friendProfileViewController.friend = selectedEvent
    }
    
    // MARK: UICollectionViewDataSource

  override func numberOfSections(in tableView: UITableView) -> Int {
      return 1
  }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        // Configure the cell...
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "FriendsCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FriendTableViewCell  else {
            fatalError("The dequeued cell is not an instance of FriendsCell.")
        }
        
        // Fetches the appropriate events for the data source layout.
        let friend = friends[indexPath.row]
        
        cell.friendProfileImage.image = friend.friendProfileImage
        cell.friendName.text = friend.friendFirstName + " " + friend.friendLastName
        
        cell.selectionStyle = .none
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
     private func loadSampleFriends() {
        let photo1 = UIImage(named: "profile1")!
        let photo2 = UIImage(named: "profile2")!
        let photo3 = UIImage(named: "profile3")!
        
        guard let friend1 = Friend(friendProfileImage: photo1, friendFirstName: "John", friendLastName: "Stamos")
        else {
            fatalError("Unable to instantiate meal1")
        }
        
        guard let friend2 = Friend(friendProfileImage: photo2, friendFirstName: "Annabel", friendLastName: "Friedman")
        else {
            fatalError("Unable to instantiate meal1")
        }
            
        guard let friend3 = Friend(friendProfileImage: photo3, friendFirstName: "Harry", friendLastName: "Kip")
        else {
            fatalError("Unable to instantiate meal1")
        }
        
        friends += [friend1, friend2, friend3]
    }

}
