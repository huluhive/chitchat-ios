//
//  Extensions.swift
//  ChitChat
//
//  Created by sangita singh on 10/31/17.
//  Copyright © 2017 sangita singh. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func loadImageUsingCacheFromUrl(urlString : String) {
        
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as?
            UIImage {
                self.image = cachedImage
                return
            }
        
        let url = NSURL(string: urlString)
        let request = URLRequest(url:url! as URL)
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if(error != nil){
                print(error!)
                return
            }
            DispatchQueue.main.async {
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    self.image = downloadedImage
                }
            }
        }).resume()
        
    }
    
}
