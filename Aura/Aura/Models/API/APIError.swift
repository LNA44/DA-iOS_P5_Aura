//
//  APIError.swift
//  Aura
//
//  Created by Ordinateur elena on 08/04/2025.
//

import Foundation

enum APIError: LocalizedError, Equatable {
	case invalidURL
	case invalidResponse
	case httpError(statusCode: Int)
	case noData
	case unauthorized
	case decodingError

	var errorDescription: String {
		switch self {
		case .invalidURL:
			return "The URL is invalid."
		case .invalidResponse: //response pas de type HTTPURLResponse
			return "Invalid response from the server."
		case .httpError(let statusCode):
			return "HTTP error: \(statusCode)"
		case .noData:
			return "No data received from the server."
		case .unauthorized: //token manquant ou invalide
			return "You are not authorized to perform this action."
		case .decodingError:
			return "Decoding error."
		}
	}
}
