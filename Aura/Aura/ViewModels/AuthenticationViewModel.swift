//
//  AuthenticationViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class AuthenticationViewModel: ObservableObject {
	//MARK: -Private properties
	private var repository: AuthenticationRepository
	
	//MARK: -Initialisation
	init(repository: AuthenticationRepository, _ callback: @escaping () -> ()) {
		self.repository = repository
		self.onLoginSucceed = callback
	}
	
	//MARK: -Outputs
	@Published var username: String = ""
	@Published var password: String = ""
	@Published var errorMessage: String? = nil
	@Published var showAlert: Bool = false
	let onLoginSucceed: (() -> ())
	
	var isSignUpComplete: Bool {
		if !isPasswordValid() || !isEmailValid() {
			return false
		}
		return true
	}
	
	var emailPrompt: String {
		if !isEmailValid() {
			return "Enter a valid email address"
		}
		return ""
	}
	
	var passwordPrompt: String {
		if !isPasswordValid() {
			return "Password must contain at least one letter, at least one number, and be longer than six charaters. "
		}
		return ""
	}
	
	//MARK: -Inputs
	@MainActor
	func login() async {
		do {
			_ = try await repository.login(username: username, password: password)
			self.onLoginSucceed()
		} catch let error as APIError {
			errorMessage = error.errorDescription
			showAlert = true
		} catch let error as AuraKeychainService.KeychainError {
			errorMessage = error.errorKeychainDescription
			showAlert = true
		} catch {
			errorMessage = "Unknown error happened : \(error.localizedDescription)"
			showAlert = true
		}
	}
	
	func isPasswordValid() -> Bool {
		// criterias here : http://regexlib.com
		let passwordTest = NSPredicate(format: "SELF MATCHES %@","^(?=.*[0-9]+.*)(?=.*[a-zA-Z]+.*)[0-9a-zA-Z]{6,}$" )
		//Au moins 1 chiffre, au moins une lettre, au moins 6 caractères
		return passwordTest.evaluate(with: password)
	}
	
	func isEmailValid() -> Bool {
		// criterias here : http://regexlib.com
		let emailTest = NSPredicate(format: "SELF MATCHES %@","^([0-9a-zA-Z]([-.\\w]*[0-9a-zA-Z])*@(([0-9a-zA-Z])+([-\\w]*[0-9a-zA-Z])*\\.)+[a-zA-Z]{2,9})$" )
		/*Caractères précédants le @: 1 caractère alphanumérique (chiffre ou lettre), tiret point et underscores ok si suivies d'un caractère alphanumérique
		 Caractères suivants le @: 1 ou plusieurs caractères alphanumériques et tirets ou underscores (domaine de l'email)
		 Caractères après le point : entre 2 et 9 lettres (domaine de premier niveau : .com, .org,...)*/
		return emailTest.evaluate(with: username)
	}
	
}
