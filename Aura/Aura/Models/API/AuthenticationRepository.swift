//
//  AuthenticationRepository.swift
//  Aura
//
//  Created by Ordinateur elena on 12/04/2025.
//

import Foundation

struct AuthenticationRepository {
	private let keychain: AuraKeychainService
	private let APIService: AuraAPIService
	
	init(keychain: AuraKeychainService, APIService: AuraAPIService) {
		self.keychain = keychain
		self.APIService = APIService
	}
	
	func login(APIService: AuraAPIService, username: String, password: String) async throws {
		let endpoint = try AuraAPIService().createEndpoint(path: .login)
		
		//body de la requete
		let parameters: [String: Any] = [
			"username": username,
			"password": password
		]
		let jsonData = AuraAPIService().serializeParameters(parameters: parameters)
		let request = AuraAPIService().createRequest(parametersNeeded: true, jsonData: jsonData, endpoint: endpoint, method: .post)
		let dict = try await APIService.fetchAndDecode([String: String].self, request: request)
		
		guard let dict = dict else {
			throw APIError.noData
		}
		
		guard let token = dict["token"] else {
			throw APIError.unauthorized
		}
		
		//Stockage du token
		_ = keychain.saveToken(token: token, key: K.Authentication.tokenKey)
	}
}
