//
//  LoginController.swift
//  ChitChat
//
//  Created by sangita singh on 10/30/17.
//  Copyright © 2017 sangita singh. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {

    var messageController : MessageController?
    
    let inputContainersView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints=false
        view.layer.cornerRadius=5
        view.layer.masksToBounds=true
        return view
    }()
    
    lazy var loginRegistrationButton : UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Register", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints=false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font=UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleLoginAndRegister), for: .touchUpInside)
        return button
    }()
    
    
    let nameTextField : UITextField = {
        let nameTV = UITextField()
        nameTV.placeholder="Name"
        nameTV.translatesAutoresizingMaskIntoConstraints=false
        return nameTV
    }()
    
    lazy var segmentedController : UISegmentedControl = {
       let sc = UISegmentedControl(items: ["Login","Register"])
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 1
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    
    let passwordTextField : UITextField = {
        let passwordTV = UITextField()
        passwordTV.placeholder="Password"
        passwordTV.translatesAutoresizingMaskIntoConstraints=false
        return passwordTV
    }()
    
    let emailTextField : UITextField = {
        let emailTF = UITextField()
        emailTF.placeholder="Email"
        emailTF.translatesAutoresizingMaskIntoConstraints=false
        return emailTF
    }()
    
    let nameSeparatorView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints=false
        return view
    }()
    
    let emailSeparatorView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints=false
        return view
    }()
    
    lazy var profileImageView : UIImageView = {
        let profileIV = UIImageView()
        let origImage = UIImage(named: "icons8-customer")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        profileIV.tintColor = UIColor.white
        profileIV.image = tintedImage
        profileIV.contentMode = .scaleAspectFill
        profileIV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectProfileImage)))
        profileIV.translatesAutoresizingMaskIntoConstraints=false
        profileIV.isUserInteractionEnabled = true
        return profileIV
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //settting up views
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        view.addSubview(loginRegistrationButton)
        view.addSubview(inputContainersView)
        view.addSubview(profileImageView)
        view.addSubview(segmentedController)
        
        setUpInputContainerView()
        setUpLoginRegistrationButton()
        setUpProfileImageView()
        setUpLoginRegisterSegmentedController()
}
    
    //Constraint variables for dynamic change in ui
    var inputContainerHeightAnchor : NSLayoutConstraint?
    var nameTextFieldHeightAnchor : NSLayoutConstraint?
    var emailTextFieldHeightAnchor : NSLayoutConstraint?
    var passwordTextFieldHeightAnchor : NSLayoutConstraint?
    
    func setUpProfileImageView(){
    profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive=true
        profileImageView.bottomAnchor.constraint(equalTo: segmentedController.topAnchor,constant: -12).isActive=true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive=true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive=true
        
    }
    
    func setUpLoginRegistrationButton() {
        loginRegistrationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive=true
        loginRegistrationButton.topAnchor.constraint(equalTo: inputContainersView.bottomAnchor, constant:12).isActive=true
        loginRegistrationButton.widthAnchor.constraint(equalTo: inputContainersView.widthAnchor).isActive=true
        loginRegistrationButton.heightAnchor.constraint(equalToConstant: 30).isActive=true
        
    }

    func setUpInputContainerView(){
        //input container view anchoring
        inputContainersView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive=true
        inputContainersView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive=true
        inputContainersView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: -24).isActive=true
        inputContainerHeightAnchor = inputContainersView.heightAnchor.constraint(equalToConstant: 150)
        inputContainerHeightAnchor?.isActive=true
        
        //adding subviews to input container view
        inputContainersView.addSubview(nameTextField)
        inputContainersView.addSubview(nameSeparatorView)
        inputContainersView.addSubview(emailTextField)
        inputContainersView.addSubview(emailSeparatorView)
        inputContainersView.addSubview(passwordTextField)
        
        //nametextfield anchoring
        nameTextField.leftAnchor.constraint(equalTo: inputContainersView.leftAnchor, constant: 12).isActive=true
        nameTextField.topAnchor.constraint(equalTo: inputContainersView.topAnchor).isActive=true
        nameTextField.widthAnchor.constraint(equalTo: inputContainersView.widthAnchor).isActive=true
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputContainersView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAnchor?.isActive=true
        
        //nameSeparatorView anchoring
        nameSeparatorView.leftAnchor.constraint(equalTo: inputContainersView.leftAnchor, constant: 12).isActive=true
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive=true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputContainersView.widthAnchor).isActive=true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive=true
    
        //emailTextField anchoring
        emailTextField.leftAnchor.constraint(equalTo: inputContainersView.leftAnchor, constant: 12).isActive=true
        emailTextField.topAnchor.constraint(equalTo: nameSeparatorView.bottomAnchor).isActive=true
        emailTextField.widthAnchor.constraint(equalTo: inputContainersView.widthAnchor).isActive=true
        emailTextFieldHeightAnchor=emailTextField.heightAnchor.constraint(equalTo: inputContainersView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive=true
        
        //emailseparatorview
        emailSeparatorView.leftAnchor.constraint(equalTo: inputContainersView.leftAnchor, constant: 12).isActive=true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive=true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputContainersView.widthAnchor).isActive=true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive=true
       
        //PasswordTextField anchoring
        passwordTextField.leftAnchor.constraint(equalTo: inputContainersView.leftAnchor, constant: 12).isActive=true
        passwordTextField.topAnchor.constraint(equalTo: emailSeparatorView.bottomAnchor).isActive=true
        passwordTextField.widthAnchor.constraint(equalTo: inputContainersView.widthAnchor).isActive=true
        passwordTextFieldHeightAnchor=passwordTextField.heightAnchor.constraint(equalTo: inputContainersView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive=true
    }
    
    func setUpLoginRegisterSegmentedController()  {
        segmentedController.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        segmentedController.bottomAnchor.constraint(equalTo: inputContainersView.topAnchor, constant: -12).isActive=true
        segmentedController.widthAnchor.constraint(equalTo: inputContainersView.widthAnchor, multiplier: 1).isActive=true
        segmentedController.heightAnchor.constraint(equalToConstant: 36).isActive=true
    }
    
    @objc func handleLoginRegisterChange() {
        let title = segmentedController.titleForSegment(at: segmentedController.selectedSegmentIndex)
        loginRegistrationButton.setTitle(title, for: .normal)
        
        //change height of inputContainer
        inputContainerHeightAnchor?.constant = segmentedController.selectedSegmentIndex == 0 ? 100 :150
        
        nameTextFieldHeightAnchor?.isActive=false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputContainersView.heightAnchor, multiplier: segmentedController.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextFieldHeightAnchor?.isActive=true
        
        emailTextFieldHeightAnchor?.isActive=false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputContainersView.heightAnchor, multiplier: segmentedController.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor?.isActive=true
        
        passwordTextFieldHeightAnchor?.isActive=false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputContainersView.heightAnchor, multiplier: segmentedController.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightAnchor?.isActive=true
    }
    

}
