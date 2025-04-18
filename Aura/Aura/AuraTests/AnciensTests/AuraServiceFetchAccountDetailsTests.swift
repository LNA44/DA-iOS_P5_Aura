//
//  AuraServiceFetchAccountDetailsTests.swift
//  AuraTests
//
//  Created by Ordinateur elena on 25/03/2025.
//

/*import XCTest
@testable import Aura

final class AuraServiceFetchAccountDetailsTests: XCTestCase {
	var viewModel: AllTransactionsViewModel!
	var dataMock = AuraServiceFetchAccountDetailsMock()
	var repository: AuraService!
	let keychain = AuraKeyChainServiceMock()
	
	
	override func setUp() {
		repository = AuraService(executeDataRequest: dataMock.executeRequestMock, keychain: keychain)
		viewModel = AllTransactionsViewModel(keychain: keychain, repository: repository)
		keychain.storeToken(token: "93D2C537-FA4A-448C-90A9-6058CF26DB29", key: "authToken")
		dataMock.response = 0
	}
	
	override func tearDown() {
		keychain.removeToken(key: "authToken")
	}
	
	func testFetchAccountDetailsSuccess() async throws {
		//Given
		dataMock.response = 1
		//When
		let result = try await repository.fetchAccountDetails()
		//Then
		XCTAssertEqual(result.transactions.count, 5)
		XCTAssertEqual(result.transactions[0].label, "Achat de maillot de foot")
		XCTAssertEqual(result.transactions[0].value, -50)
		XCTAssertEqual(result.currentBalance, 12345.67)
	}
	
	func testFetchAccountDetailsBadURLErrorOccurs() async throws {
		//Given
		dataMock.response = 2
		repository = AuraService(baseURLString: "", executeDataRequest: dataMock.executeRequestMock, keychain: keychain)
		//When & Then
		do {
			_ = try await repository.fetchAccountDetails()
		} catch {
			XCTAssertEqual(error as? AuraService.fetchAccountDetailsError, AuraService.fetchAccountDetailsError.badURL)
		}
	}
	
	func testFetchAccountDetailsMissingTokenErrorOccurs() async throws {
		//Given
		dataMock.response = 3
		keychain.removeToken(key: "authToken")
		//When & Then
		do {
			_ = try await repository.fetchAccountDetails()
		} catch {
			XCTAssertEqual(error as? AuraService.fetchAccountDetailsError, AuraService.fetchAccountDetailsError.missingToken)
		}
	}
	
	func testFetchAccountDetailsNoDataErrorOccurs() async throws {
		//Given
		dataMock.response = 4
		//When & Then
		do {
			_ = try await repository.fetchAccountDetails()
		} catch {
			XCTAssertEqual(error as? AuraService.fetchAccountDetailsError, AuraService.fetchAccountDetailsError.noData)
		}
	}
	
	func testFetchAccountDetailsRequestFailedErrorOccurs() async throws {
		//Given
		dataMock.response = 5
		//When & Then
		do {
			_ = try await repository.fetchAccountDetails()
		} catch {
			XCTAssertEqual(error as? AuraService.fetchAccountDetailsError, AuraService.fetchAccountDetailsError.requestFailed)
		}
	}
	
	func testFetchAccountDetailsServerErrorOccurs() async throws {
		//Given
		dataMock.response = 6
		//When & Then
		do {
			_ = try await repository.fetchAccountDetails()
		} catch {
			XCTAssertEqual(error as? AuraService.fetchAccountDetailsError, AuraService.fetchAccountDetailsError.serverError)
		}
	}
	
	func testFetchAccountDetailsDecodingErrorOccurs() async throws {
		//Given
		dataMock.response = 7
		//When & Then
		do {
			_ = try await repository.fetchAccountDetails()
		} catch {
			XCTAssertEqual(error as? AuraService.fetchAccountDetailsError, AuraService.fetchAccountDetailsError.decodingError)
		}
	}
}
*/
