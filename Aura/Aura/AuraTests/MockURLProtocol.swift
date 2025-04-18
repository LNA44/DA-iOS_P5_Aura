//
//  MockURLProtocol.swift
//  AuraTests
//
//  Created by Ordinateur elena on 12/04/2025.
//

import XCTest

final class MockURLProtocol: URLProtocol {
	override class func canInit(with request: URLRequest) -> Bool {
		return true
	}

	override class func canonicalRequest(for request: URLRequest) -> URLRequest {
		return request
	}
	
	static var requestHandler: ((URLRequest) throws -> (URLResponse?, Data?, Error?))? //URLResponse pour pouvoir tester fun fetch avec invalidResponse
	
	override func startLoading() {
		guard let handler = MockURLProtocol.requestHandler else {
			XCTFail("No handler provided for MockURLProtocol")
			return
		}
		
		do {
			let (response, data, error) = try handler(request)
			
			if let error = error {
				client?.urlProtocol(self, didFailWithError: error)
				return
			}
			
			guard let unwrappedResponse = response else {
				return
			}
			//Si pas d'erreur envoyer response et data
			client?.urlProtocol(self, didReceive: unwrappedResponse, cacheStoragePolicy: .notAllowed)
			
			if let data = data {
				client?.urlProtocol(self, didLoad: data)
			}
			
			client?.urlProtocolDidFinishLoading(self)
		} catch {
			XCTFail("Error handling the request: \(error)")
		}
	}
	
	override func stopLoading() {
	}
}
