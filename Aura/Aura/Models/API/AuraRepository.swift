//
//  AuraRepository.swift
//  Aura
//
//  Created by Ordinateur elena on 10/03/2025.
//

import Foundation
//logique de récup des données depuis l'API

struct AuraRepository {
	let data: Data?
	let response: URLResponse?
	//private let baseURLString: String
	private let executeDataRequest: (URLRequest) async throws -> (Data, URLResponse) // permet d'utiliser un mock
	private let keychain: AuraKeychainService
	private let APIService: AuraAPIService

	/*enum LoginError: Error, Equatable {
		case badURL
		case noData
		case requestFailed
		case serverError
		case decodingError
	}
	
	enum FetchAccountDetailsError: Error {
		case badURL
		case missingToken
		case noData
		case requestFailed
		case serverError
		case decodingError
	}
	
	enum TransferError: Error {
		case badURL
		case missingToken
		case dataNotEmpty
		case requestFailed
		case serverError
	}*/
	
	init(data: Data? = nil, response: URLResponse? = nil, executeDataRequest: @escaping (URLRequest) async throws -> (Data, URLResponse) = URLSession.shared.data(for:), keychain: AuraKeychainService, APIService: AuraAPIService = AuraAPIService()) {
		self.data = data
		self.response = response
		//self.baseURLString = baseURLString
		self.executeDataRequest = executeDataRequest
		self.keychain = keychain
		self.APIService = APIService
	}
	
	func login(APIService: AuraAPIService, username: String, password: String) async throws {
	/*	guard let baseURL = URL(string: baseURLString) else {
			throw LoginError.badURL
		}*/
		//let endpoint = baseURL.appendingPathComponent("/auth")
		//let endpoint = try AuraAPIService().createEndpoint(path: .login)
		let endpoint = try AuraAPIService().createEndpoint(path: .login)

		//body de la requete
		let parameters: [String: Any] = [
			"username": username,
			"password": password
		]
	
		//conversion en JSON
		//let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
		let jsonData = AuraAPIService().serializeParameters(parameters: parameters)
		//création de la requête
		/*var request = URLRequest(url: endpoint)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = jsonData*/
		
		let request = AuraAPIService().createRequest(parametersNeeded: true, jsonData: jsonData, endpoint: endpoint, method: .post)

		//lancement appel réseau
		/*let (data, response) = try await AuraAPIService().fetch(request: request)
		
		if data.isEmpty {//data est non optionnel dc pas de guard let
			throw LoginError.noData
		}
		guard let httpResponse = response as? HTTPURLResponse else { // cast renvoie un optionnel
			throw LoginError.requestFailed //response peut etre de type URLResponse et non HTTPURLResponse donc vérif
		}
		guard httpResponse.statusCode == 200 else {
			throw LoginError.serverError
		}
		
		//décodage du JSON
		guard let responseJSON = try? JSONDecoder().decode([String: String].self, from: data),
			  let token = responseJSON["token"] else {
			throw LoginError.decodingError
		}*/
		
		let dict = try await APIService.fetchAndDecode([String: String].self, request: request)
		
		guard let dict = dict else {
			throw APIError.noData
		}
		
		guard let token = dict["token"] else {
			throw APIError.unauthorized
		}
		//Stockage du token
		keychain.storeToken(token: token, key: "authToken")
	}
	
	func fetchAccountDetails(APIService: AuraAPIService) async throws -> (currentBalance: Decimal,transactions: [Transaction]) {
		/*guard let baseURL = URL(string: baseURLString) else {
			throw FetchAccountDetailsError.badURL
		}
		let endpoint = baseURL.appendingPathComponent("/account")*/
		/*let endpoint = try AuraAPIService().createEndpoint(path: .fetchAccountsDetails)
		
		//création de la requête
		var request = URLRequest(url: endpoint)
		request.httpMethod = "GET"*/
		let endpoint = try AuraAPIService().createEndpoint(path: .fetchAccountsDetails)
		var request = AuraAPIService().createRequest(parametersNeeded: false, jsonData: nil, endpoint: endpoint, method: .get)

		//Récupération du token
		guard let token = keychain.retrieveToken(key: "authToken") else {
			throw APIError.unauthorized
		}
		request.setValue(token, forHTTPHeaderField: "token") //header
		
		//lancement appel réseau
		/*let (data, response) = try await executeDataRequest(request)
		
		if data.isEmpty { //data est non optionnel dc pas de guard let
			throw FetchAccountDetailsError.noData
		}
		guard let httpResponse = response as? HTTPURLResponse else { //response peut etre de type URLResponse et non HTTPURLResponse donc vérif
			throw FetchAccountDetailsError.requestFailed
		}
		guard httpResponse.statusCode == 200 else {
			throw FetchAccountDetailsError.serverError
		}
		
		//décodage du JSON
		guard let accountResponse = try? JSONDecoder().decode(AccountResponse.self, from: data) else {
			throw FetchAccountDetailsError.decodingError
		}*/
		let accountResponse = try await APIService.fetchAndDecode(AccountResponse.self, request: request)
		
		guard let accountResponse = accountResponse else {
			throw APIError.noData
		}
		
		return (accountResponse.currentBalance, accountResponse.transactions.map(Transaction.init)) //mapper pour avoir objet Transaction avec un id utile pour ForEach
	}
	
	func transferMoney(APIService: AuraAPIService, recipient: String, amount: Decimal) async throws -> Void {
		/*guard let baseURL = URL(string: baseURLString) else {
			throw TransferError.badURL
		}
		
		let endpoint = baseURL.appendingPathComponent("/account/transfer")*/
		let endpoint = try AuraAPIService().createEndpoint(path: .makeTransaction)

		
		//body de la requete
		let parameters: [String: Any] = [
			"recipient": recipient,
			"amount": amount
		]
		
		//conversion en JSON
		//let jsonData = AuraAPIService().serializeParameters(parameters: parameters)
		let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
		
		//création de la requête
		/*var request = URLRequest(url: endpoint)
		request.httpMethod = "POST"*/
		var request = AuraAPIService().createRequest(parametersNeeded: true, jsonData: jsonData, endpoint: endpoint, method: .post)

		//Récupération du token
		guard let token = keychain.retrieveToken(key: "authToken") else {
			throw APIError.unauthorized
		}
		request.setValue(token, forHTTPHeaderField: "token") //header
		
		//request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		//request.httpBody = jsonData
		
		//lancement appel réseau
		/*let (data, response) = try await executeDataRequest(request)
		
		if !data.isEmpty { //data est non optionnel dc pas de guard let
			throw TransferError.dataNotEmpty
		}
		guard let httpResponse = response as? HTTPURLResponse else { //response peut etre de type URLResponse et non HTTPURLResponse donc vérif
			throw TransferError.requestFailed
		}
		guard httpResponse.statusCode == 200 else {
			throw TransferError.serverError
		}*/
		_ = try await APIService.fetchAndDecode(AccountResponse.self, request: request, shouldCheckEmptyData: false)
	}
}
