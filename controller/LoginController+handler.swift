//
//  LoginController+handler.swift
//  ChitChat
//
//  Created by sangita singh on 10/30/17.
//  Copyright © 2017 sangita singh. All rights reserved.
//

import UIKit
import Firebase

extension LoginController : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    //triggers when profile image is clicked
    @objc func selectProfileImage(){
        let picker = UIImagePickerController()
        picker.delegate=self
        picker.allowsEditing=true
        present(picker, animated: true, completion: nil)
    }
    
    //handles login or register according to the segmented controller
    @objc func handleLoginAndRegister(){
        if(segmentedController.selectedSegmentIndex == 0){
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    // handles when user presses the login button
    func handleLogin() {
        guard let email = emailTextField.text , let password = passwordTextField.text
            else {
                print("Form content is not valid")
                return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if(error != nil){
                print ("Error signing in")
                return
            }
            self.dismiss(animated: true, completion: nil)
            self.messageController!.checkIfUserLoggedIn()
        }
        
    }
    
    /*
     uploading the profile image , after completion of upload data is written in the server in users node.
 */
    @objc func handleRegister() {
        
        guard let email = emailTextField.text , let password = passwordTextField.text , let name = nameTextField.text
            else {
                print("Form content not valid")
                return
        }
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            if(error != nil){
                print ("Error creating user")
                return
            }
            
            guard let uid=user?.uid else {
                print("no user")
                return
            }
        
            let imageName = NSUUID().uuidString
            let storageReference  = Storage.storage().reference().child("\(imageName).jpg")
            if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
                storageReference.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if(error != nil){
                        print(error ?? "error")
                        return
                    }
                    
                    let values = ["name":name , "email":email,"profileImage":metadata?.downloadURL()?.absoluteString]
                    self.registerUserWithUid(uid: uid, values: values as [String : AnyObject])
                })
            }

        }
    }
    
    /*
     Register user in firebase database inside the users node
     @params : uid - String
     @params : values - dictionary
 */
    private func registerUserWithUid(uid : String , values : [String : AnyObject]){
        let userReference = Database.database().reference().child("users").child(uid)
        userReference.updateChildValues(values, withCompletionBlock: {(error,ref) in
            
            if(error != nil){
                print("Error")
                return
            }
            print("User created")
            self.dismiss(animated: true, completion: nil)
            self.messageController?.checkIfUserLoggedIn()
        })
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
            profileImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
}
