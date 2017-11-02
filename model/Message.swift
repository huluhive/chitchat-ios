//
//  Message.swift
//  ChitChat
//
//  Created by sangita singh on 10/31/17.
//  Copyright © 2017 sangita singh. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    
    var toId:String?
    var fromId:String?
    var timeStamp:NSNumber?
    var text:String?
    var imageUrl:String?
    var imageHeight: NSNumber?
    var imageWidth: NSNumber?
    
    func chatPartnerId() ->String? {
        return Auth.auth().currentUser?.uid == fromId ? toId : fromId
    }
    
    init(dictionary : [String : AnyObject]){
        super.init()
        fromId = dictionary["fromId"] as? String
        toId = dictionary["toId"] as? String
        text = dictionary["text"] as? String
        timeStamp = dictionary["timeStamp"] as? NSNumber
        imageUrl = dictionary["imageUrl"] as? String
        imageWidth = dictionary["imageWidth"] as? NSNumber
        imageHeight = dictionary["imageHeight"] as? NSNumber
    }
    
}
