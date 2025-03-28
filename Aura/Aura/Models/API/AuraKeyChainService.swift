//
//  AuraKeyChainService.swift
//  Aura
//
//  Created by Ordinateur elena on 22/03/2025.
//

import Security
import Foundation

protocol KeyChainServiceProtocol {
	func storeToken(token: String, key: String)
	func retrieveToken(key: String) -> String?
	func removeToken(key: String)
}

//Gère le token en le cryptant
class AuraKeyChainService: ObservableObject, KeyChainServiceProtocol {
	static let shared = AuraKeyChainService() //création instance partagée singleton
	
	private init() {} //évite la création d'une autre instance
	
	func storeToken(token: String, key: String) { //Crée un token
		let data = token.data(using: .utf8)! //keychain attend des Data
		let query: [String: Any] = [ //Dictionnaire
			kSecClass as String: kSecClassGenericPassword, //type mot de passe générique
			kSecAttrAccount as String: key,
			kSecValueData as String: data
		]
		SecItemAdd(query as CFDictionary, nil)//ajout nouvel élément dans keychain
	}
	
	func retrieveToken(key: String) -> String? { //Récupération du token
		let query: [String: Any] = [//dictionnaire contenant les critères de recherche dans le keychain pour récupérer l'élément
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrAccount as String: key,
			kSecReturnData as String: true, //retourne la donnée
			kSecMatchLimit as String: kSecMatchLimitOne //limite la recherche à un seul élément par clé
		]
		var item: AnyObject?
		let status = SecItemCopyMatching(query as CFDictionary, &item)//recherche de l'élément qui sera stocké dans item
		guard status == errSecSuccess, let data = item as? Data else {//vérif du statut et du type de item
			return nil
		}
		return String(data: data, encoding: .utf8)//convertit Data en String
	}
	
	func removeToken(key: String) { //Suppression du token
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrAccount as String: key
		]
		SecItemDelete(query as CFDictionary)
	}
}
