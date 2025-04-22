//
//  AuraAPIServiceTests.swift
//  AuraTests
//
//  Created by Ordinateur elena on 15/04/2025.
//

import XCTest
@testable import Aura

final class AuraAPIServiceTests: XCTestCase {
	
	let mockData = AuraAPIServiceMock()
	
	lazy var session: URLSession = {
		let configuration = URLSessionConfiguration.ephemeral
		configuration.protocolClasses = [MockURLProtocol.self]
		return URLSession(configuration: configuration)
	}()
	lazy var apiService: AuraAPIService = {
		AuraAPIService(session: session)
	}()
	
	override func setUp() {
		super.setUp()
	}
	
	override func tearDown() {
		super.tearDown()
		MockURLProtocol.requestHandler = nil
		Constante.APIService.baseUrl = URL(string: "http://127.0.0.1:8080") // valeur par défaut
	}
	
	func testCreateEndpointSuccess() {
		//Given
		let path: AuraAPIService.Path = .fetchAccountsDetails
		//When & Then
		do {
			let endpoint = try apiService.createEndpoint(path: path)
			XCTAssertEqual(endpoint, URL(string: "http://127.0.0.1:8080/account"))
		} catch {
			XCTFail("Unexpected error type: \(error)")
		}
	}
	
	func testCreateEndpointErrorOccurs() {
		//Given
		Constante.APIService.baseUrl = nil
		let path: AuraAPIService.Path = .fetchAccountsDetails
		//When & Then
		do {
			_ = try apiService.createEndpoint(path: path)
			XCTFail("Expected APIError.invalidURL to be thrown")
		} catch APIError.invalidURL {
			XCTAssertTrue(true, "Caught expected APIError.invalidURL")
		} catch {
			XCTFail("Expected APIError.invalidURL, got \(error)")
		}
	}
	
	func testSerializeParametersSuccess() {
		let parameters : [String: Any] = ["key": "value"]
		do {
			let data = try apiService.serializeParameters(parameters: parameters)
			XCTAssertNotNil(data)
		} catch {
			XCTFail("Unexpected error type: \(error)")
		}
	}
	
	func testSerializeParametersErrorOccurs() {
		let parameters: [String: Any] = ["date": Date()]
		do {
			let data = try apiService.serializeParameters(parameters: parameters)
			XCTAssertNil(data)
		} catch APIError.invalidParameters {
			XCTAssertTrue(true, "Caught expected APIError.invalidParameters")
		} catch {
			XCTFail("Expected APIError.invalidParameters, got \(error)")
		}
	}
	
	func testCreateRequestWithoutBodySucess() {
		//Given
		let jsonData: Data? = nil
		let endpoint: URL = URL(string: "http://127.0.0.1:8080/account")!
		let method: AuraAPIService.Method = .get
		//When
		let request = apiService.createRequest(jsonData: jsonData, endpoint: endpoint, method: method)
		//Then
		XCTAssertEqual(request.httpMethod, method.rawValue)
		XCTAssertEqual(request.url, endpoint)
		XCTAssertNil(request.httpBody)
		XCTAssertNil(request.allHTTPHeaderFields?["Content-Type"])
	}
	
	func testCreateRequestWithBodySuccess() {
		//Given
		let parameters : [String: Any] = [
			"recipient": "+33 6 01 02 03 04",
			"amount": 12.4
		]
		
		let	jsonData = try? JSONSerialization.data(withJSONObject: parameters, options: [])
		let endpoint: URL = URL(string: "http://127.0.0.1:8080//account/transfer")!
		let method: AuraAPIService.Method = .post
		//When
		let request = apiService.createRequest(parameters: parameters, jsonData: jsonData, endpoint: endpoint, method: method)
		//Then
		XCTAssertEqual(request.httpMethod, method.rawValue)
		XCTAssertEqual(request.url, endpoint)
		XCTAssertEqual(request.httpBody, jsonData)
		XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], "application/json")
	}
	
	func testFetchWithoutBodySuccess() async {
		//Given
		let endpoint = URL(string: "http://127.0.0.1:8080/account")!
		var request = URLRequest(url: endpoint)
		request.httpMethod = AuraAPIService.Method.get.rawValue
		
		let (_, expectedData, _) = mockData.makeMock(for: .successWithoutBody)
		
		let allowEmptyData = true
		//When
		do {
			let data = try await apiService.fetch(request: request,  allowEmptyData: allowEmptyData)
			//Then
			XCTAssertEqual(data, expectedData) //Vérifie que la fonction renvoie bien les données mockées dans le request handler
		} catch {
			XCTFail("Unexpected error type: \(error)")
		}
	}
	
	func testFetchWithBodySuccess() async {
		//Given
		let endpoint = URL(string: "http://127.0.0.1:8080/account/transfer")!
		var request = URLRequest(url: endpoint)
		request.httpMethod = AuraAPIService.Method.post.rawValue
		
		let parameters: [String: Any] = ["key": "value"]
		let jsonData = try? JSONSerialization.data(withJSONObject: parameters, options: [])
		request.httpBody = jsonData
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		
		let (_, expectedData, _) = mockData.makeMock(for: .successWithoutBody)
		
		let allowEmptyData = true
		//When
		do {
			let data = try await apiService.fetch(request: request, allowEmptyData: allowEmptyData)
			//Then
			XCTAssertEqual(data, expectedData)
		} catch {
			XCTFail("Unexpected error type: \(error)")
		}
	}
	
	func testFetchInvalidResponseOccurs() async {
		//Given
		let endpoint = URL(string: "http://127.0.0.1:8080/account")!
		var request = URLRequest(url: endpoint)
		request.httpMethod = AuraAPIService.Method.get.rawValue
		
		// Simuler une réponse avec des données
		let (_, _, _) = mockData.makeMock(for: .serverError)
		
		//When & Then
		do {
			_ = try await apiService.fetch(request: request)
			XCTFail("Expected to throw APIError.invalidParameters but succeeded")
		} catch APIError.invalidResponse {
			XCTAssertTrue(true, "Caught expected APIError.invalidResponse")
		} catch {
			XCTFail("Expected APIError.invalidParameters, got \(error)")
		}
	}
	
	func testFetchStatusCodeErrorOccurs() async {
		//Given
		let endpoint = URL(string: "http://127.0.0.1:8080/account")!
		var request = URLRequest(url: endpoint)
		request.httpMethod = AuraAPIService.Method.get.rawValue
		
		// Simuler une réponse avec des données
		let (_, _, _) = mockData.makeMock(for: .statusCodeError)
		//When & Then
		do {
			_ = try await apiService.fetch(request: request)
			XCTFail("Expected to throw APIError.httpError but succeeded")
		} catch APIError.httpError(statusCode: 500) {
			XCTAssertTrue(true, "Caught expected APIError.httpError")
		} catch {
			XCTFail("Expected APIError.invalidParameters, got \(error)")
		}
	}
	
	func testFetchNetworkErrorOccurs() async {
		let endpoint = URL(string: "invalid-url")!
		var request = URLRequest(url: endpoint)
		request.httpMethod = AuraAPIService.Method.get.rawValue
		
		let (_, _, _) = mockData.makeMock(for: .networkError)
		
		do {
			_ = try await apiService.fetch(request: request)
			XCTFail("Expected to throw network error but it succeeded")
		} catch let error as NSError {
			// Vérifie si c'est une erreur réseau (en fonction de la nature de l'erreur)
			XCTAssertTrue(error.domain == NSURLErrorDomain)
		} catch {
			XCTFail("Unexpected error: \(error)")
		}
	}
	
	func testDecodeSuccess() {
		//Given
		let (_,expectedData,_) = mockData.makeMock(for: .successWithoutBody)
		guard let data = expectedData else {
			return
		}
		//When & Then
		do {
			let responseJSON = try apiService.decode(AccountResponse.self, data: data)
			guard let responseJSON = responseJSON else {
				XCTFail("Decoded response is nil")
				return
			}
			XCTAssertEqual(responseJSON.transactions, [])
			XCTAssertEqual(responseJSON.currentBalance, 100)
		} catch {
			XCTFail("Unexpected error type: \(error)")
		}
	}
	
	func testDecodeDecodingErrorOccurs() {
		//Given
		let endpoint = URL(string: "http://127.0.0.1:8080/account")!
		let expectedData = """
	  {
	   "date": Date()
	  }
	  """.data(using: .utf8)!
		
		let mockResponse = HTTPURLResponse(url: endpoint, statusCode: 200, httpVersion: nil, headerFields: nil)!
		MockURLProtocol.requestHandler = { request in
			return (mockResponse, expectedData, nil) // Réponse simulée
		}
		//When & Then
		do {
			let responseJSON = try apiService.decode(AccountResponse.self, data: expectedData)
			guard responseJSON != nil else {
				XCTFail("Decoded response is nil")
				return
			}
		} catch APIError.decodingError {
			XCTAssertTrue(true, "Caught expected APIError.decodingError")
		} catch {
			XCTFail("Unexpected error type: \(error)")
		}
	}
	
	func testFetchAndDecodeWithoutBodySuccess() async {
		//Given
		let endpoint = URL(string: "http://127.0.0.1:8080/account")!
		var request = URLRequest(url: endpoint)
		request.httpMethod = AuraAPIService.Method.get.rawValue
		let (_,_,_) = mockData.makeMock(for: .successWithoutBody)
		let allowEmptyData = true
		//When & Then
		do {
			let decodedData = try await apiService.fetchAndDecode(AccountResponse.self, request: request, allowEmptyData: allowEmptyData)
			XCTAssertNotNil(decodedData)
		} catch {
			XCTFail("Unexpected error type: \(error)")
		}
	}
	
	func testFetchAndDecodeWithBodySuccess() async {
		//Given		
		let endpoint = URL(string: "http://127.0.0.1:8080/account/transfer")!
		var request = URLRequest(url: endpoint)
		request.httpMethod = AuraAPIService.Method.post.rawValue
		
		let parameters: [String: Any] = [
			"recipient": "+33 6 01 02 03 04",
			"amount": 12.4
		]
		let jsonData = try? apiService.serializeParameters(parameters: parameters)
		
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = jsonData
		let (_,_,_) = mockData.makeMock(for: .successWithBody)
		let allowEmptyData = true
		//When & Then
		do {
			let emptyData = try await apiService.fetchAndDecode(AccountResponse.self, request: request, allowEmptyData: allowEmptyData)
			XCTAssertNil(emptyData)
		} catch {
			XCTFail("Unexpected error type: \(error)")
		}
	}
}
