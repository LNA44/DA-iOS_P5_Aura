//
//  AuraAuthenticationViewModelTests.swift
//  AuraTests
//
//  Created by Ordinateur elena on 14/03/2025.
//

import XCTest
@testable import Aura

final class AuraAuthenticationViewModelTests: XCTestCase {
	let mockData = AuraAuthenticationViewModelMock()
	let keychain = AuraKeychainService()
	
	lazy var session: URLSession = {
		let configuration = URLSessionConfiguration.ephemeral
		configuration.protocolClasses = [MockURLProtocol.self]
		return URLSession(configuration: configuration)
	}()
	
	lazy var apiService: AuraAPIService = {
		AuraAPIService(session: session)
	}()
	
	lazy var repository = AuthenticationRepository(keychain: keychain, APIService: apiService)

	var callback: () -> Void = {}
	
	lazy var viewModel = AuthenticationViewModel(repository: repository, callback)

	override func setUp() {
		_ = keychain.deleteToken(key: "authToken")
		// Création d'un callback simulé
		callback = {
			// Ce callback pourrait simplement être une assertion pour vérifier que la connexion a réussi.
			print("Login succeeded")
		}
	}
	
	override func tearDown() {
			MockURLProtocol.requestHandler = nil
	}
	
	func testLoginSuccess() async {
		//Given
		//dataMock.response = 1
		viewModel.username = "test"
		viewModel.password = "test"
		_ = mockData.makeMock(for: .success)
		//When
		await viewModel.login()
		//Then
		XCTAssertNil(viewModel.errorMessage)
		let token = keychain.getToken(key: K.Authentication.tokenKey)
		XCTAssertEqual(token, "93D2C537-FA4A-448C-90A9-6058CF26DB29")
	}
	
	func testLoginDecodingErrorOccurs() async {
		viewModel.username = "test"
		viewModel.password = "test"
		_ = mockData.makeMock(for: .decodingAPIError)
		// When
		await viewModel.login()
		//Then
		XCTAssertEqual(viewModel.errorMessage, "No data received from the server.")
		XCTAssertTrue(viewModel.showAlert)
	}
	
	func testLoginUnknownErrorOccurs() async {
		viewModel.username = "test"
		viewModel.password = "test"
		_ = mockData.makeMock(for: .unknownError)
		// When
		await viewModel.login()
		//Then
		XCTAssertEqual(viewModel.errorMessage, "Une erreur inconnue est survenue : \(error.localizedDescription)")
		XCTAssertTrue(viewModel.showAlert)
	}
	
	func testIsPasswordValidSuccess() {
		//Given
		viewModel.password = "test123"
		//When
		let validPassword = viewModel.isPasswordValid()
		//Then
		XCTAssertTrue(validPassword)
	}
	
	func testIsPasswordValidFail() {
		//Given
		viewModel.password = "test"
		//When
		let validPassword = viewModel.isPasswordValid()
		//Then
		XCTAssertFalse(validPassword)
	}
	
	func testIsEmailValidSuccess() {
		viewModel.username = "test@aura.app"
		let validEmail = viewModel.isEmailValid()
		XCTAssertTrue(validEmail)
	}
	
	func testIsEmailValidFail() {
		viewModel.username = "test@"
		let validEmail = viewModel.isEmailValid()
		XCTAssertFalse(validEmail)
	}
	
	func testIsSignUpCompleteSuccess() {
		//Given
		viewModel.username = "test@aura.app"
		viewModel.password = "test123"
		//When
		let isComplete = viewModel.isSignUpComplete
		//Then
		XCTAssertTrue(isComplete)
	}
	
	func testIsSignUpCompleteFail() {
		//Given
		viewModel.username = "test@"
		viewModel.password = "test"
		//When
		let isComplete = viewModel.isSignUpComplete
		//Then
		XCTAssertFalse(isComplete)
	}
	
	func testEmailPromptSuccess() {
		//Given
		viewModel.username = "test@aura.app"
		//When
		let prompt = viewModel.emailPrompt
		//Then
		XCTAssertEqual(prompt, "")
	}
	
	func testPasswordPromptSuccess() {
		//Given
		viewModel.password = "test123"
		//when
		let prompt = viewModel.passwordPrompt
		//Then
		XCTAssertEqual(prompt, "")
	}
}

