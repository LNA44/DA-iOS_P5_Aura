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
	
	init(keychain: AuraKeychainService, APIService: AuraAPIService = AuraAPIService()) {
		self.keychain = keychain
		self.APIService = APIService
	}
	
	func login(username: String, password: String) async throws {
		let endpoint = try APIService.createEndpoint(path: .login)
		
		//body de la requete
		let parameters: [String: Any] = [
			"username": username,
			"password": password
		]
		let jsonData = try APIService.serializeParameters(parameters: parameters)
		let request = APIService.createRequest(parameters: parameters, jsonData: jsonData, endpoint: endpoint, method: .post)
		
		let dict = try await APIService.fetchAndDecode([String: String].self, request: request, allowEmptyData: true)
		
		guard let dict = dict else {
			throw APIError.noData
		}
		
		guard let token = dict["token"] else {
			throw APIError.unauthorized
		}
		//Stockage du token
		_ = try keychain.saveToken(token: token, key: Constante.Authentication.tokenKey)
	}
}
