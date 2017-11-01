//
//  ChatLogController.swift
//  ChitChat
//
//  Created by sangita singh on 10/31/17.
//  Copyright © 2017 sangita singh. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate , UICollectionViewDelegateFlowLayout{
    let cellId = "ChatLogCellId"
    var messages = [Message]()
    var user : User? {
        didSet {
            navigationItem.title=user?.name
            observeMessages()
        }
    }
    
    let inputComponent : UIView = {
        let inputComponent = UIView()
        inputComponent.translatesAutoresizingMaskIntoConstraints=false
        inputComponent.backgroundColor=UIColor.white
        return inputComponent
    }()
    
    let sendButton :UIButton = {
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints=false
        sendButton.addTarget(self, action: #selector(handleSendMessage), for: .touchUpInside)
        return sendButton
    }()
    
    lazy var textField : UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints=false
        textField.placeholder = "Enter message"
        textField.delegate=self
        return textField
    }()
    
    let separatorView : UIView = {
        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints=false
        separatorView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        return separatorView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.contentInset=UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        collectionView?.scrollIndicatorInsets=UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView?.alwaysBounceVertical=true
        collectionView?.backgroundColor=UIColor.white
        collectionView?.register(MessageViewCell.self, forCellWithReuseIdentifier: cellId)
        setUpInputComponents()
    }
    
    func setUpInputComponents() {
        view.addSubview(inputComponent)
        inputComponent.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive=true
        inputComponent.leftAnchor.constraint(equalTo: view.leftAnchor).isActive=true
        inputComponent.widthAnchor.constraint(equalTo: view.widthAnchor).isActive=true
        inputComponent.heightAnchor.constraint(equalToConstant: 50).isActive=true
        
        inputComponent.addSubview(sendButton)
        sendButton.rightAnchor.constraint(equalTo: inputComponent.rightAnchor).isActive=true
        sendButton.centerYAnchor.constraint(equalTo: inputComponent.centerYAnchor).isActive=true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive=true
        sendButton.heightAnchor.constraint(equalTo: inputComponent.heightAnchor).isActive=true
        
        inputComponent.addSubview(textField)
        textField.leftAnchor.constraint(equalTo: inputComponent.leftAnchor,constant: 8).isActive=true
        textField.centerYAnchor.constraint(equalTo: inputComponent.centerYAnchor).isActive=true
        textField.heightAnchor.constraint(equalTo: inputComponent.heightAnchor).isActive=true
        textField.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: 8).isActive=true
       
        inputComponent.addSubview(separatorView)
        separatorView.topAnchor.constraint(equalTo: inputComponent.topAnchor).isActive=true
        separatorView.leftAnchor.constraint(equalTo: inputComponent.leftAnchor).isActive=true
        separatorView.widthAnchor.constraint(equalTo: inputComponent.widthAnchor).isActive=true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive=true
    
    }
    
    @objc func handleSendMessage() {
        let ref=Database.database().reference().child("messages")
        let childRef=ref.childByAutoId()
        let toId=user!.id!
        let fromId=Auth.auth().currentUser!.uid
        let timeStamp = NSDate().timeIntervalSince1970
        let values = ["text":textField.text! , "toId" : toId,"fromId" : fromId,"timeStamp" : timeStamp] as [String : Any]
        childRef.updateChildValues(values) { (error, ref) in
            if(error != nil) {
                print(error!)
                return
        }
            let messageId = childRef.key
            let userMessageReference = Database.database().reference().child("user-messages").child(fromId)
            userMessageReference.updateChildValues([messageId:1])
            let reciepentMessageReference = Database.database().reference().child("user-messages").child(toId)
            reciepentMessageReference.updateChildValues([messageId:1])
        self.textField.text=""
    }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendMessage()
        return true
    }
    
    func  observeMessages(){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let chatMessageRef = Database.database().reference().child("user-messages").child(uid)
        chatMessageRef.observe(.childAdded) { (snapshot) in
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String : AnyObject] else {
                    return
                }
                let message = Message()
                message.fromId = dictionary["fromId"] as? String
                message.toId = dictionary["toId"] as? String
                message.text = dictionary["text"] as? String
                message.timeStamp = dictionary["timeStamp"] as? NSNumber
                if(message.chatPartnerId() == self.user?.id){
                self.messages.append(message)
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
                }
            })
        }
    }
    
    func estimateFrameForText(text: String) -> CGRect{
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16)], context: nil )
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
        
    }
    
    fileprivate func setupCellType(message: Message,cell: MessageViewCell) {
        if let userProfileImage = self.user?.profileImage {
            cell.profileImageView.loadImageUsingCacheFromUrl(urlString: userProfileImage)
        }
        
        if( message.fromId == Auth.auth().currentUser?.uid){
            //blue hunxa
            cell.bubbleView.backgroundColor=UIColor(r: 0, g: 137, b: 249)
            cell.textView.textColor=UIColor.white
            cell.profileImageView.isHidden=true
            cell.bubbleLeftAnchor?.isActive=false
            cell.bubbleRightAnchor?.isActive=true
        }else {
            //grey hunxa
            cell.bubbleView.backgroundColor=UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor=UIColor.black
            cell.bubbleLeftAnchor?.isActive=true
            cell.bubbleRightAnchor?.isActive=false
            cell.profileImageView.isHidden=false
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MessageViewCell
        let message = messages[indexPath.row]
        cell.textView.text = message.text
        setupCellType(message: message, cell: cell)
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: message.text!).width + 32
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height : CGFloat = 80
        if let text = messages[indexPath.row].text {
        height = estimateFrameForText(text: text).height + 30
        }
        print("Balls")
        print(height)
        return CGSize(width: view.frame.width, height: height)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    

}
