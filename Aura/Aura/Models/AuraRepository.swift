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
	let response : URLResponse?
	let error : Error?
	
	func PostAuth(username: String, password: String) async throws -> Void {
		guard let url = URL(string: "http://localhost:8080/auth") else {
			throw URLError(.badURL)
		}
		//body de la requete
		let parameters: [String: Any] = [
			"username": username,
			"password": password
		]
		//conversion en JSON
		guard let jsonData = try? JSONDecoder().decode(Data.self, from: parameters) else {
			print("Erreur : impossible de convertir en JSON")
			return
		}
		//création de la requête
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = jsonData
		
		//lancement requete avec task
		let task = URLSession.shared.dataTask(with: request) {data, response, error in
			guard let data = data, let response = let error = nil else {
				
			}
		}
	}
	
}
