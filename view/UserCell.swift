//
//  UserCell.swift
//  ChitChat
//
//  Created by sangita singh on 10/31/17.
//  Copyright © 2017 sangita singh. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    var message: Message? {
        didSet{
            setUpNameAndProfileImage()
            let timeStampDate = NSDate(timeIntervalSince1970: (self.message?.timeStamp?.doubleValue)!)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm:ss a"
            self.timeLabel.text = dateFormatter.string(from: timeStampDate as Date)
            if let text = self.message?.text {
            self.detailTextLabel?.text = text
            }else if self.message?.imageUrl != nil {
                self.detailTextLabel?.text = "Image message"
            }
        }
    }

    func setUpNameAndProfileImage()  {
        if let id = message?.chatPartnerId() {
            Database.database().reference().child("users").child(id).observe(.value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    if let profileImage=dictionary["profileImage"] as? String {
                        self.profileImageView.loadImageUsingCacheFromUrl(urlString: profileImage)
                    }
                    self.textLabel?.text = dictionary["name"] as? String
                }
            }, withCancel: nil)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 64, y: (textLabel!.frame.origin.y), width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 64, y: (detailTextLabel!.frame.origin.y), width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    let profileImageView : UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints=false
        image.layer.cornerRadius=24
        image.layer.masksToBounds=true
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    let timeLabel : UILabel = {
        let label = UILabel()
        label.text = "HH:MM:SS"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.gray
        label.translatesAutoresizingMaskIntoConstraints=false
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        //anchoring profileImageView
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive=true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive=true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive=true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive=true
        
        //anchoring timeLabelView
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive=true
        timeLabel.centerYAnchor.constraint(equalTo: (textLabel?.centerYAnchor)!).isActive=true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive=true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive=true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive=true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

