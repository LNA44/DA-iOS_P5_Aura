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
	
	func login(username: String, password: String) async throws -> String {
		guard let url = URL(string: "http://127.0.0.1:8080/auth") else {
			throw LoginError.badURL
		}
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
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = jsonData
		
		//lancement appel réseau
		let (data, response) = try await URLSession.shared.data(for: request)
		
		if data.isEmpty {//data est non optionnel dc pas de guard let
			throw LoginError.noData
		}
		guard let response = response as? HTTPURLResponse else { //response peut etre de type URLResponse et non HTTPURLResponse donc vérif
			throw LoginError.requestFailed("Réponse du serveur invalide")
		}
		guard response.statusCode == 200 else {
			throw LoginError.serverError(response.statusCode)
		}
		guard let responseJSON = try? JSONDecoder().decode([String: String].self, from: data),
			  let token = responseJSON["token"] else {
			throw LoginError.decodingError
		}
		return token
	}
}
