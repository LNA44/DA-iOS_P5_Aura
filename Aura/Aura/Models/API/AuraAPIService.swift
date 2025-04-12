//
//  AuraAPIService.swift
//  Aura
//
//  Created by Ordinateur elena on 08/04/2025.
//

import Foundation

struct AuraAPIService {
	
	//MARK: -Private properties
	private let session: URLSession

	//MARK: -Initialization
	init(session: URLSession = .shared) {
		self.session = session
	}
	
	//MARK: -Enumerations
	//endpoint
	enum Path: String {
		case login = "/auth"
		case fetchAccountsDetails = "/account"
		case makeTransaction = "/account/transfer"
	}
	
	enum Method: String {
			case get = "GET"
			case post = "POST"
		}
	
	//MARK: -Methods
	func createEndpoint(path: Path) throws -> URL {
		guard let baseURL = URL(string: "http://127.0.0.1:8080") else {
			throw APIError.invalidURL
		}
		return baseURL.appendingPathComponent(path.rawValue)
	}
	
	//sérialisation
	func serializeParameters(parameters: [String: Any]) -> Data? {
		return try? JSONSerialization.data(withJSONObject: parameters, options: [])
	}
	
	//requête
	func createRequest(parametersNeeded: Bool, jsonData: Data?, endpoint: URL, method: Method) -> URLRequest {
		var request = URLRequest(url: endpoint)
		request.httpMethod = method.rawValue
		if parametersNeeded {
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")
			request.httpBody = jsonData
			return request
		} else {
			return request
		}
	}
	
	//appel réseau
	func fetch(request: URLRequest, shouldCheckEmptyData: Bool = true) async throws -> Data {
		let (data, response) = try await session.data(for: request)
		
		guard let httpResponse = response as? HTTPURLResponse else {
			throw APIError.invalidResponse
		}
		guard httpResponse.statusCode == 200 else {
			throw APIError.httpError(statusCode: httpResponse.statusCode)
		}
		if shouldCheckEmptyData && data.isEmpty {
			throw APIError.noData
		}
		return data
	}
	
	func decode<T: Decodable>(_ type: T.Type, data: Data) throws -> T? { //T est décodable
		if data.isEmpty {
			return nil
		}
		guard let responseJSON = try? JSONDecoder().decode(T.self, from: data) else { //T: plusieurs types possibles : [String, String], AccountResponse
			throw APIError.decodingError
		}
		return responseJSON
	}
	
	func fetchAndDecode<T: Decodable>(_ type: T.Type, request: URLRequest, shouldCheckEmptyData: Bool = true) async throws -> T? {
		let data = try await fetch(request: request,  shouldCheckEmptyData: shouldCheckEmptyData)
		if data.isEmpty {
			return nil
		}
		let decodedData = try decode(T.self, data: data)
		return decodedData
	}
}
