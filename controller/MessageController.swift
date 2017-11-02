//
//  ViewController.swift
//  ChitChat
//
//  Created by sangita singh on 10/30/17.
//  Copyright © 2017 sangita singh. All rights reserved.
//

import UIKit
import Firebase

class MessageController: UITableViewController {
    let cellId = "messageCellId"
    var messages = [Message]()
    var messageDictionary = [String : Message]()
    let logoImage : UIImageView = {
        var rect = CGRect(x: 200, y: 200, width: 200, height: 200)
        var image = UIImageView(frame: rect)
        return image
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserLoggedIn()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log-out", style: .plain, target: self,action: #selector(handleLogout))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        let image = UIImage(named: "icons8-new-message-filled")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
//       observeMessages()
        
    }
    
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        let userMessageRef = Database.database().reference().child("user-messages").child(uid)
        userMessageRef.observe(.childAdded) { (snapshot) in
            let userId = snapshot.key
            
            let messageReference = Database.database().reference().child("user-messages").child(uid).child(userId)
            messageReference.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
                let messageRef = Database.database().reference().child("messages").child(messageId)
                messageRef.observe(.value, with: { (snapshot) in
                    if let dictionary = snapshot.value as? [String : AnyObject] {
                        let message = Message(dictionary: dictionary)
                        if let chatPartnerId = message.chatPartnerId() {
                            self.messageDictionary[chatPartnerId] = message
                        }
                        self.attempReloadTable()
                    }
                })
    
            })
        }
    }
    
    func attempReloadTable()  {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloading), userInfo: nil, repeats: false)
    }
    
    var timer :Timer?
    
    @objc func handleReloading(){
        self.messages=Array(self.messageDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            return message1.timeStamp!.intValue > message2.timeStamp!.intValue
        })
        print("Table being reloaded")
        DispatchQueue.main.async {
    self.tableView.reloadData()
    }
    }
    
    @objc func handleNewMessage(){
        let newMessageController = NewMessageController()
        newMessageController.messageController=self
        let navControler = UINavigationController(rootViewController: newMessageController)
        present(navControler, animated: true, completion: nil)
    }
    
    
    func checkIfUserLoggedIn() {
        messages.removeAll()
        messageDictionary.removeAll()
        tableView.reloadData()

        if(Auth.auth().currentUser?.uid == nil) {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            fetchUserAndSetupNav()
            observeUserMessages()
    }
    }
    
        
    func fetchUserAndSetupNav() {
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(uid!)
            .observeSingleEvent(of: .value, with: {(snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    
                    let titleView =  UIButton(type: .system)
                    titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
                    titleView.setTitle(dictionary["name"] as? String, for: .normal)
                    titleView.setTitleColor(UIColor.black, for: .normal)
//                    titleView.addTarget(self, action: #selector(self.showChatController), for: .touchUpInside)
                    self.navigationItem.titleView = titleView
                                    }
            }, withCancel: nil)
        }
    
    @objc func showChatControllerForUser(user: User) {
        let chatController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatController.user = user
        navigationController?.pushViewController(chatController, animated: true)
    }
    
    @objc func handleLogout(){
    print("Log out clicked")
        do {
         try Auth.auth().signOut()
        } catch let logOutError{
            print(logOutError)
        }
            let loginController = LoginController()
        loginController.messageController=self
        self.present(loginController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let message = self.messages[indexPath.row]
        cell.message = message
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observe(.value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String :AnyObject] else {
                return
            }
            let user = User()
            user.name = dictionary["name"] as? String
            user.email = dictionary["email"] as? String
            user.id = chatPartnerId
            user.profileImage = dictionary["profileImage"] as? String
            self.showChatControllerForUser(user: user)
        }
            }
}

extension UIColor {
    convenience init(r : CGFloat , g : CGFloat , b : CGFloat) {
        self.init(displayP3Red: r/255, green: g/255, blue: b/255, alpha: 1)
        }
}

