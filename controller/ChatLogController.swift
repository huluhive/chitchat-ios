//
//  ChatLogController.swift
//  ChitChat
//
//  Created by sangita singh on 10/31/17.
//  Copyright © 2017 sangita singh. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class ChatLogController: UICollectionViewController, UITextFieldDelegate , UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    var inputContainerBottomAnchor : NSLayoutConstraint?
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
    
    let imageGetButton : UIButton = {
       let imageButton = UIButton()
        let image = UIImage(named: "gallery")
        imageButton.setImage(image, for: .normal)
        imageButton.translatesAutoresizingMaskIntoConstraints=false
        imageButton.addTarget(self, action: #selector(handleUploadImage), for: .touchUpInside)
        return imageButton
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
    
    lazy var inputContainerView : UIView = {
       let containerView = UIView()
        containerView.frame=CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50 )
        containerView.backgroundColor=UIColor.white
        
        containerView.addSubview(self.imageGetButton)
        imageGetButton.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 4).isActive=true
        imageGetButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive=true
        imageGetButton.widthAnchor.constraint(equalToConstant: 44).isActive=true
        imageGetButton.heightAnchor.constraint(equalToConstant: 44).isActive=true
        
        containerView.addSubview(self.sendButton)
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive=true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive=true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive=true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive=true
        
        containerView.addSubview(self.textField)
        textField.leftAnchor.constraint(equalTo: imageGetButton.rightAnchor,constant: 8).isActive=true
        textField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive=true
        textField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive=true
        textField.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: 8).isActive=true
        
        containerView.addSubview(self.separatorView)
        separatorView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive=true
        separatorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive=true
        separatorView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive=true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive=true
    
        return containerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.contentInset=UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView?.alwaysBounceVertical=true
        collectionView?.backgroundColor=UIColor.white
        collectionView?.register(MessageViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive
    
        setUpKeyboardObservers()
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }

    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    func setUpKeyboardObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: .UIKeyboardDidShow, object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//         NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func handleKeyboardDidShow() {
        if(messages.count>0){
        let indexPath = NSIndexPath(item: self.messages.count-1, section: 0)
        self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .top, animated: true)
    }
    }
    
    @objc func handleKeyboardWillShow(notification :NSNotification){
        let keyboardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
         let duration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        inputContainerBottomAnchor?.constant = -keyboardFrame.height
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func handleKeyboardWillHide(notification :NSNotification){
        inputContainerBottomAnchor?.constant = 0
        let duration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func handleUploadImage() {
        let photoPickerController = UIImagePickerController ()
        photoPickerController.delegate = self
        photoPickerController.mediaTypes = [kUTTypeImage as String , kUTTypeVideo as String]
        present(photoPickerController, animated: true, completion: nil  )
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendMessage()
        return true
    }
    
    func  observeMessages(){
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.id else {
            return
        }
        let chatMessageRef = Database.database().reference().child("user-messages").child(uid).child(toId)
        chatMessageRef.observe(.childAdded) { (snapshot) in
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String : AnyObject] else {
                    return
                }
                self.messages.append(Message(dictionary: dictionary))
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    let indexPath = NSIndexPath(item: self.messages.count-1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
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
    
     private func setupCellType(message: Message,cell: MessageViewCell) {
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
        if let imageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCacheFromUrl(urlString: imageUrl)
            cell.messageImageView.isHidden=false
            cell.bubbleView.backgroundColor=UIColor.clear
        }else{
            cell.messageImageView.isHidden=true
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MessageViewCell
        cell.chatLogController = self
        let message = messages[indexPath.row]
        cell.textView.text = message.text
        setupCellType(message: message, cell: cell)
        if let text = message.text {
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
            cell.textView.isHidden=false
            
        } else if message.imageUrl != nil{
            cell.textView.isHidden=true
            cell.bubbleWidthAnchor?.constant = 200
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height : CGFloat = 80
        let message = messages[indexPath.row]
        if let text = message.text {
        height = estimateFrameForText(text: text).height + 30
        } else if let imageHeight = message.imageHeight?.floatValue , let imageWidth = message.imageWidth?.floatValue {
            height = CGFloat(imageHeight/imageWidth*200)
        }
        return CGSize(width: UIScreen.main.bounds.width, height: height)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker : UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let  originalImage  = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker{
            uploadImageToFirebase(image: selectedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleSendMessage() {
        let properties : [String : Any ] = ["text" : textField.text!]
        sendMessageWithProperties(properties: properties)
    }
    
    func handleSendWithImageUrl(imageUrl:String, image: UIImage){
        let properties : [String : Any] = ["imageUrl":imageUrl , "imageHeight" : image.size.height,
                                                "imageWidth": image.size.width ]
        sendMessageWithProperties(properties: properties)
    }
    
    func sendMessageWithProperties(properties : [String : Any])  {
        let ref=Database.database().reference().child("messages")
        let childRef=ref.childByAutoId()
        let toId=user!.id!
        let fromId=Auth.auth().currentUser!.uid
        let timeStamp = NSDate().timeIntervalSince1970
        
        var values : [String : Any] = ["toId" : toId,
        "fromId" : fromId,"timeStamp" : timeStamp]
        
        properties.forEach({values[$0] = $1})
        
        childRef.updateChildValues(values) { (error, ref) in
            if(error != nil) {
                print(error!)
                return
            }
            let messageId = childRef.key
            let userMessageReference = Database.database().reference().child("user-messages").child(fromId).child(toId)
            userMessageReference.updateChildValues([messageId:1])
            let reciepentMessageReference = Database.database().reference().child("user-messages").child(toId).child(fromId)
            reciepentMessageReference.updateChildValues([messageId:1])
            self.textField.text=""
        }
    }
    
    func uploadImageToFirebase(image:UIImage)  {
        let imageName = NSUUID().uuidString
        let storageReference  = Storage.storage().reference().child("message-images").child("\(imageName).jpg")
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            storageReference.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if(error != nil){
                    print(error ?? "error")
                    return
                }
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    self.handleSendWithImageUrl(imageUrl: imageUrl, image: image)
                }
            })
        }
    }
    
    var startingFrame : CGRect?
    var blackBackgroundView : UIView?
    var startingImageView : UIImageView?
    
    func handleImageTappedForZoom(imageView : UIImageView) {
        startingImageView = imageView
        startingImageView?.isHidden=true
        startingFrame = imageView.superview?.convert(imageView.frame, to: nil)
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.image=imageView.image
        zoomingImageView.isUserInteractionEnabled=true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let window = UIApplication.shared.keyWindow {
            let height = startingFrame!.height/startingFrame!.width*window.frame.width
             blackBackgroundView = UIView(frame: window.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            window.addSubview(blackBackgroundView!)
            window.addSubview(zoomingImageView)
        
            self.inputContainerView.alpha=0
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.blackBackgroundView?.alpha=1
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: height)
                zoomingImageView.center=window.center
            }, completion: nil)

        }
            }
    
    @objc func handleZoomOut(gesture : UITapGestureRecognizer){
        if let zoomOutImage=gesture.view{
            zoomOutImage.layer.cornerRadius=16
            zoomOutImage.clipsToBounds=true
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            zoomOutImage.frame=self.startingFrame!
            self.blackBackgroundView?.alpha=0
            self.inputContainerView.alpha=1
        }, completion: {(completed: Bool) in
            zoomOutImage.removeFromSuperview()
            self.startingImageView?.isHidden=false
        })
        }
    }
}
