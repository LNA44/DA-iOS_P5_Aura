//
//  AuthenticationViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class AuthenticationViewModel: ObservableObject {
	//MARK: -Private properties
	private let keychain: KeyChainServiceProtocol
	private var repository: AuraService
	
	//MARK: -Initialisation
	init(keychain: KeyChainServiceProtocol, repository: AuraService, _ callback: @escaping () -> ()) {
		self.keychain = keychain
		self.repository = repository
		self.onLoginSucceed = callback //callback : permet ds AppViewModel isLogged = True une fois connexion OK
	}
	
	//MARK: -Outputs
	@Published var username: String = ""
	@Published var password: String = ""
	@Published var errorMessage: String? = nil
	@Published var showAlert: Bool = false
	let onLoginSucceed: (() -> ())
	
	var isSignUpComplete: Bool {
		if !isPasswordValid() || !isEmailValid(){ 
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
		print("🔄 login() appelé")
		do {
			let token = try await repository.login(username: username, password: password)
			print("✅ Login réussi : \(token)")
			print("login with \(username) and \(password)")
			print(token) 
			self.onLoginSucceed() //exécute la closure du callback
			return
		} catch {
			print("Erreur détectée dans login() : \(error)")
			if let loginError = error as? AuraService.LoginError {
				switch loginError {
				case .badURL :
					errorMessage = "URL invalide"
				case .noData :
					errorMessage = "Aucune donnée reçue"
				case .requestFailed :
					errorMessage = "Erreur de requête"
				case .serverError :
					errorMessage = "Erreur serveur"
				case .decodingError :
					errorMessage = "Erreur de décodage"
				}
				showAlert = true
			}
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
