//
//  AppViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class AppViewModel: ObservableObject {
	//MARK: -Properties
	@Published var isLogged: Bool
	private let repository: AuraService
	
	//MARK: - Initialisation
	init(repository: AuraService) {
		self.repository = repository
		isLogged = false
	}
	
	//MARK: - Computed properties
	var authenticationViewModel: AuthenticationViewModel {
		return AuthenticationViewModel(keychain: AuraKeyChainService.shared, repository: repository) { [weak self] in
			self?.isLogged = true
		}
	}
	
	var accountDetailViewModel: AccountDetailViewModel {
		return AccountDetailViewModel(keychain: AuraKeyChainService.shared, repository:repository)
	}
	
	var allTransactionsViewModel: AllTransactionsViewModel {
		return AllTransactionsViewModel(keychain: AuraKeyChainService.shared, repository:repository)
	}
	
	var moneyTransferViewModel: MoneyTransferViewModel {
		return MoneyTransferViewModel(keychain: AuraKeyChainService.shared, repository:repository)
	}
}
