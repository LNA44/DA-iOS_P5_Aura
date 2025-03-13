//
//  AuraRepository.swift
//  Aura
//
//  Created by Ordinateur elena on 10/03/2025.
//

import Foundation
//logique de récup des données depuis l'API

struct AuraService {
	let data: Data?
	let response: URLResponse?
	static var token: String? //propriété de classe car n'est modifié qu'une fois
	private let baseURLString = "http://127.0.0.1:8080/"
	
	enum LoginError: Error {
		case badURL
		case noData
		case requestFailed(String)
		case encodingError
		case serverError(Int)
		case decodingError
	}
	
	init(data: Data? = nil, response: URLResponse? = nil) { //pour ne ps avoir à les init dans AuraApp
		self.data = data
		self.response = response
	}
	
	func login(username: String, password: String) async throws -> String { //mutating : fonction modifie propriété de classe (token)
		guard let baseURL = URL(string: baseURLString) else {
			throw LoginError.badURL
		}
		let endpoint = baseURL.appendingPathComponent("/auth")
		
		//body de la requete
		let parameters: [String: Any] = [
			"username": username,
			"password": password
		]
		//conversion en JSON
		guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
			throw LoginError.encodingError
		}
		//création de la requête
		var request = URLRequest(url: endpoint)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = jsonData
		
		//lancement appel réseau
		let (data, response) = try await URLSession.shared.data(for: request)
		
		if data.isEmpty {//data est non optionnel dc pas de guard let
			throw LoginError.noData
		}
		guard let httpResponse = response as? HTTPURLResponse else { //response peut etre de type URLResponse et non HTTPURLResponse donc vérif
			throw LoginError.requestFailed("Réponse du serveur invalide")
		}
		guard httpResponse.statusCode == 200 else {
			throw LoginError.serverError(httpResponse.statusCode)
		}
		
		//décodage du JSON
		guard let responseJSON = try? JSONDecoder().decode([String: String].self, from: data),
			  let token = responseJSON["token"] else {
			throw LoginError.decodingError
		}
		//Stockage du token
		AuraService.token = token
		return token
	}
	
	func fetchAccountDetails() async throws -> (currentBalance:Double,transactions: [Transaction]) {
		guard let baseURL = URL(string: baseURLString) else {
			throw URLError(.badURL) // Erreur si l’URL est invalide
		}
		let endpoint = baseURL.appendingPathComponent("/account")
		//création de la requête
		var request = URLRequest(url: endpoint)
		request.httpMethod = "GET"
		request.setValue(AuraService.token, forHTTPHeaderField: "token") //header
		
		//lancement appel réseau
		let (data, response) = try await URLSession.shared.data(for: request)
		
		if data.isEmpty {//data est non optionnel dc pas de guard let
			throw LoginError.noData
		}
		guard let httpResponse = response as? HTTPURLResponse else { //response peut etre de type URLResponse et non HTTPURLResponse donc vérif
			throw LoginError.requestFailed("Réponse du serveur invalide")
		}
		guard httpResponse.statusCode == 200 else {
			throw LoginError.serverError(httpResponse.statusCode)
		}

		//décodage du JSON
		guard let accountResponse = try? JSONDecoder().decode(AccountResponse.self, from: data) else {
			throw LoginError.decodingError
		}
		return (accountResponse.currentBalance, accountResponse.transactions.map(Transaction.init)) //mapper pour avoir objet Transaction avec un id
	}
}
