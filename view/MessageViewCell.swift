//
//  MessageViewCell.swift
//  ChitChat
//
//  Created by sangita singh on 11/1/17.
//  Copyright © 2017 sangita singh. All rights reserved.
//

import UIKit

class MessageViewCell: UICollectionViewCell {
    var bubbleWidthAnchor : NSLayoutConstraint?
    var bubbleRightAnchor :NSLayoutConstraint?
    var bubbleLeftAnchor :NSLayoutConstraint?
    
    let textView : UILabel = {
        let tv = UILabel()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.backgroundColor = UIColor.clear
        tv.textColor = UIColor.white
        tv.numberOfLines=0
        tv.translatesAutoresizingMaskIntoConstraints=false
        return tv
    }()
    
    let profileImageView: UIImageView = {
        let image = UIImageView()
       image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 16
        image.image = UIImage(named: "pp_dummy")
        image.contentMode = .scaleAspectFill
        image.layer.masksToBounds = true
        return image
    }()
    
    let messageImageView : UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 16
        image.contentMode = .scaleAspectFill
        image.layer.masksToBounds = true
        return image
    }()
    
    let bubbleView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 0, g: 137, b: 249)
        view.translatesAutoresizingMaskIntoConstraints=false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        bubbleView.addSubview(messageImageView)
        
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive=true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive=true
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive=true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive=true
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive=true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive=true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive=true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive=true
        
        bubbleRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor,constant: -8)
        bubbleRightAnchor?.isActive=true
        bubbleLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor,constant: 8)
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive=true
        bubbleWidthAnchor=bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive=true
        bubbleView.layer.cornerRadius = 16
        bubbleView.layer.masksToBounds=true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive=true
        
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive=true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive=true
        textView.widthAnchor.constraint(equalToConstant: 200).isActive=true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive=true
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive=true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
