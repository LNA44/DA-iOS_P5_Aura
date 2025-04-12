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
	
	init(keychain: AuraKeychainService, APIService: AuraAPIService) {
		self.keychain = keychain
		self.APIService = APIService
	}
	
	func transferMoney(APIService: AuraAPIService, recipient: String, amount: Decimal) async throws -> Void {
		let endpoint = try AuraAPIService().createEndpoint(path: .makeTransaction)
		
		
		//body de la requete
		let parameters: [String: Any] = [
			"recipient": recipient,
			"amount": amount
		]
		
		let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
		var request = AuraAPIService().createRequest(parametersNeeded: true, jsonData: jsonData, endpoint: endpoint, method: .post)
		
		//Récupération du token
		guard let token = keychain.getToken(key: K.MoneyTransfer.tokenKey) else {
			throw APIError.unauthorized
		}
		
		request.setValue(token, forHTTPHeaderField: "token") //header
		
		_ = try await APIService.fetchAndDecode(AccountResponse.self, request: request, shouldCheckEmptyData: false)
	}
}
