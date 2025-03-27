//
//  AuraAuthenticationViewModelTests.swift
//  AuraTests
//
//  Created by Ordinateur elena on 14/03/2025.
//

import XCTest
@testable import Aura

final class AuraAuthenticationViewModelTests: XCTestCase {
	var viewModel: AuthenticationViewModel!
	var dataMock = DataAuthenticationMock()
	var repository: AuraService!
	var callback: () -> Void = {}
	let keychain = AuraKeyChainServiceMock()
	
	override func setUp() {
		repository = AuraService(executeDataRequest: dataMock.executeRequestMock, keychain: keychain)
		viewModel = AuthenticationViewModel(keychain: keychain, repository: repository, callback)
		// Création d'un callback simulé
		callback = {
			// Ce callback pourrait simplement être une assertion pour vérifier que la connexion a réussi.
			print("Login succeeded")
		}
	}
	
	override func tearDown() {
		keychain.removeToken(key: "authToken")
	}
	
	func testLoginSuccess() async {
		//Given
		dataMock.response = 1
		viewModel.username = "test@aura.app"
		viewModel.password = "test123"
		//When
		await viewModel.login()
		//Then
		XCTAssertNil(viewModel.errorMessage)
		let token = keychain.retrieveToken(key: "authToken")
		XCTAssertEqual(token, "93D2C537-FA4A-448C-90A9-6058CF26DB29")
	}
	
	func testLoginBadURLErrorOccurs() async {
		//Given
		repository = AuraService(baseURLString: "", executeDataRequest: dataMock.executeRequestMock, keychain: keychain)
		viewModel = AuthenticationViewModel(keychain: keychain, repository: repository, callback)
		dataMock.response = 2
		viewModel.username = "test@aura.app"
		viewModel.password = "test123"
		let token = keychain.retrieveToken(key: "authToken")
		//When
		await viewModel.login()
		//Then
		XCTAssertNotNil(viewModel.errorMessage)
		XCTAssertEqual(viewModel.errorMessage, "URL invalide")
		XCTAssertNil(token)
	}
	
	func testLoginNoDataErrorOccurs() async {
		//Given
		dataMock.response = 3
		viewModel.username = "test@aura.app"
		viewModel.password = "test123"
		
		//When
		await viewModel.login()
		//Then
		XCTAssertNotNil(viewModel.errorMessage)
		XCTAssertEqual(viewModel.errorMessage, "Aucune donnée reçue")
		let token = keychain.retrieveToken(key: "authToken")
		XCTAssertNil(token)
	}
	
	func testLoginRequestFailedErrorOccurs() async {
		//Given
		dataMock.response = 4
		viewModel.username = "test@aura.app"
		viewModel.password = "test123"
		
		//When
		await viewModel.login()
		//Then
		XCTAssertNotNil(viewModel.errorMessage)
		XCTAssertEqual(viewModel.errorMessage, "Erreur de requête")
		let token = keychain.retrieveToken(key: "authToken")
		XCTAssertNil(token)
	}
	
	func testLoginServerErrorOccurs() async {
		//Given
		dataMock.response = 5
		viewModel.username = "test@aura.app"
		viewModel.password = "test123"
		//When
		await viewModel.login()
		//Then
		XCTAssertNotNil(viewModel.errorMessage)
		XCTAssertEqual(viewModel.errorMessage, "Erreur serveur")
		let token = keychain.retrieveToken(key: "authToken")
		XCTAssertNil(token)
	}
	
	func testLoginDecodingErrorOccurs() async {
		//Given
		dataMock.response = 6
		viewModel.username = "test@aura.app"
		viewModel.password = "test123"
		//When
		await viewModel.login()
		//Then
		XCTAssertNotNil(viewModel.errorMessage)
		XCTAssertEqual(viewModel.errorMessage, "Erreur de décodage")
		let token = keychain.retrieveToken(key: "authToken")
		XCTAssertNil(token)
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
