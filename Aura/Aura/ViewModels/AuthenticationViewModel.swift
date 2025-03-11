//
//  AuthenticationViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class AuthenticationViewModel: ObservableObject {
	//MARK: -Properties
    @Published var username: String = ""
    @Published var password: String = ""
    
    let onLoginSucceed: (() -> ()) 
    
	//MARK: -Initialisation
    init(_ callback: @escaping () -> ()) {
        self.onLoginSucceed = callback
    }
    
	//MARK: -Validation functions
    func login() {
        print("login with \(username) and \(password)")
        onLoginSucceed()
    }
	
	func isPasswordValid() -> Bool {
		// criterias here : http://regexlib.com
		let passwordTest = NSPredicate(format: "SELF MATCHES %@","^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z]).{4,8}$" )
		//self matches pr utliser des regex
		return passwordTest.evaluate(with: password)
	}
	
	func isEmailValid() -> Bool {
		// criterias here : http://regexlib.com
		let emailTest = NSPredicate(format: "SELF MATCHES %@","^([0-9a-zA-Z]([-.\\w]*[0-9a-zA-Z])*@(([0-9a-zA-Z])+([-\\w]*[0-9a-zA-Z])*\\.)+[a-zA-Z]{2,9})$" )
		//self matches pr utliser des regex
		return emailTest.evaluate(with: username)
	}
	
	var isSignUpComplete: Bool {
		if !isPasswordValid() || !isEmailValid(){ //OU
			return false
		}
		return true
	}
	//MARK: -Validation prompt strings
	
	var emailPrompt: String {
		if !isEmailValid() {
			return "Enter a valid email address"
		}
		return ""
	}
	
	var passwordPrompt: String {
		if !isPasswordValid() {
			return "Must be between 4 and 8 characters, must include at least one upper case letter, one lower case letter, and one numeric digit "
		}
		return ""
	}
}
