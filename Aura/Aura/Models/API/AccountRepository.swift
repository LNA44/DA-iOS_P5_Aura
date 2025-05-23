//
//  AccountRepository.swift
//  Aura
//
//  Created by Ordinateur elena on 12/04/2025.
//

import Foundation

struct AccountRepository {
	private let keychain: AuraKeychainService
	private let APIService: AuraAPIService
	
	init(keychain: AuraKeychainService, APIService: AuraAPIService = AuraAPIService()) {
		self.keychain = keychain
		self.APIService = APIService
	}
	
	func fetchAccountDetails() async throws -> (currentBalance: Decimal,transactions: [Transaction]) {
		let endpoint = try APIService.createEndpoint(path: .fetchAccountsDetails)
		var request = APIService.createRequest(jsonData: nil, endpoint: endpoint, method: .get)
		
		//Récupération du token
		let token = try keychain.getToken(key: Constante.Account.tokenKey) 
		
		request.setValue(token, forHTTPHeaderField: "token")
		
		let accountResponse = try await APIService.fetchAndDecode(AccountResponse.self, request: request)
		
		guard let accountResponse = accountResponse else {
			throw APIError.noData
		}
		
		return (accountResponse.currentBalance, accountResponse.transactions.map(Transaction.init)) //mapper pour avoir objet Transaction avec un id utile pour ForEach
	}
}
