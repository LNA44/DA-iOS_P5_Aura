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
	var dataMock = DataMock()
	var repository: AuraService!
	var callback: () -> Void = {}
	
	override func setUp() {
		repository = AuraService(executeDataRequest: dataMock.executeRequestMock)
		viewModel = AuthenticationViewModel(repository: repository, callback)
		// Création d'un callback simulé
		callback = {
			// Ce callback pourrait simplement être une assertion pour vérifier que la connexion a réussi.
			print("Login succeeded")
		}
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
		XCTAssertEqual(AuraService.token, "93D2C537-FA4A-448C-90A9-6058CF26DB29")
	}
	
	func testLoginBadURLErrorOccurs() async {
		//Given
		repository = AuraService(baseURLString: "", executeDataRequest: dataMock.executeRequestMock)
		viewModel = AuthenticationViewModel(repository: repository, callback)
		dataMock.response = 2
		viewModel.username = "test@aura.app"
		viewModel.password = "test123"
		
		//When
		await viewModel.login()
		//Then
		XCTAssertNotNil(viewModel.errorMessage)
		XCTAssertEqual(viewModel.errorMessage, "URL invalide")
		XCTAssertNil(AuraService.token)
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
		XCTAssertNil(AuraService.token)
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
		XCTAssertNil(AuraService.token)
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
		XCTAssertNil(AuraService.token)
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
		XCTAssertNil(AuraService.token)
	}
	
	//Utile?
	func testIsPasswordValidSuccess() {
		//Given
		viewModel.password = "test123"
		//When
		let validPassword = viewModel.isPasswordValid()
		//Then
		XCTAssertTrue(validPassword)
	}
	//Utile?
	func testIsPasswordValidFail() {
		//Given
		viewModel.password = "test"
		//When
		let validPassword = viewModel.isPasswordValid()
		//Then
		XCTAssertFalse(validPassword)
	}
	//Utile?
	func testIsEmailValidSuccess() {
		viewModel.username = "test@aura.app"
		let validEmail = viewModel.isEmailValid()
		XCTAssertTrue(validEmail)
	}
	//Utile?
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
		viewModel.isEmailValid()
		//When
		let prompt = viewModel.emailPrompt
		//Then
		XCTAssertEqual(prompt, "")
	}
	
	func testPasswordPromptSuccess() {
		//Given
		viewModel.password = "test123"
		viewModel.isPasswordValid()
		//when
		let prompt = viewModel.passwordPrompt
		//Then
		XCTAssertEqual(prompt, "")
	}
}


