//
//  NewMessageController.swift
//  ChitChat
//
//  Created by sangita singh on 10/30/17.
//  Copyright © 2017 sangita singh. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {
    
    let cellId = "cellId"
    var users  = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self,
                                                           action: #selector(handleCancelClick))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        fetchUser()
        }
    
    func fetchUser()  {
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject]{
                let user = User()
                user.id=snapshot.key
                user.name=dictionary["name"] as? String
                user.email=dictionary["email"] as? String
                user.profileImage=dictionary["profileImage"] as? String
                self.users.append(user)
                print(self.users.count, user.name ?? "suman")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
    }
    
    @objc func handleCancelClick() {
//        print("clicked cancel")
        dismiss(animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.textLabel?.text=user.name
        cell.detailTextLabel?.text=user.email
        cell.profileImageView.image=UIImage(named: "pp_dummy")
        cell.timeLabel.isHidden=true
        cell.profileImageView.contentMode = .scaleAspectFill
        if let image = user.profileImage {
            cell.profileImageView.loadImageUsingCacheFromUrl(urlString: image)
            }
        return cell
    }
    var messageController : MessageController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true, completion: nil)
        let user = users[indexPath.row]
        self.messageController?.showChatControllerForUser(user: user)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
}
