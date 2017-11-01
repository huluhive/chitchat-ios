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
    
    func chatPartnerId() ->String? {
        return Auth.auth().currentUser?.uid == fromId ? toId : fromId
    }
}
