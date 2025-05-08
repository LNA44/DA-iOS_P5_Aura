//
//  MoneyTransferRepository.swift
//  Aura
//
//  Created by Ordinateur elena on 12/04/2025.
//

import Foundation

struct MoneyTransferRepository {
	private let keychain: AuraKeychainService
	private let APIService: AuraAPIService
	
	init(keychain: AuraKeychainService, APIService: AuraAPIService = AuraAPIService()) {
		self.keychain = keychain
		self.APIService = APIService
	}
	
	func transferMoney(recipient: String, amount: Decimal) async throws -> Void {
		let endpoint = try APIService.createEndpoint(path: .makeTransaction)
		
		
		//body de la requete
		let parameters: [String: Any] = [
			"recipient": recipient,
			"amount": amount
		]
		
		let jsonData = try APIService.serializeParameters(parameters: parameters)
		var request = APIService.createRequest(parameters: parameters, jsonData: jsonData, endpoint: endpoint, method: .post)
		
		//Récupération du token
		let token = try keychain.getToken(key: Constante.MoneyTransfer.tokenKey)
		
		request.setValue(token, forHTTPHeaderField: "token") //header
		_ = try await APIService.fetch(request: request, allowEmptyData: true)
	}
}
