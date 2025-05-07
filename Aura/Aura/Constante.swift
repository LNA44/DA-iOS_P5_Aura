//
//  K.swift
//  Aura
//
//  Created by Ordinateur elena on 12/04/2025.
//

import Foundation
struct Constante {
	struct APIService {
		static var baseUrl =  URL(string: "http://127.0.0.1:8080")
	}
	
	struct Authentication {
		static let tokenKey: String = "authToken"
	}
	
	struct Account {
		static let tokenKey: String = "authToken"
	}
	
	struct MoneyTransfer {
		static let tokenKey: String = "authToken"
	}
}
