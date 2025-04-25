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
	private let authenticationRepository: AuthenticationRepository
	private let accountRepository: AccountRepository
	private let moneyTransferRepository: MoneyTransferRepository
	
	//MARK: -Initialisation
	init(authenticationRepository: AuthenticationRepository, accountRepository: AccountRepository, moneyTransferRepository: MoneyTransferRepository) {
		self.authenticationRepository = authenticationRepository
		self.accountRepository = accountRepository
		self.moneyTransferRepository = moneyTransferRepository
		isLogged = false
	}
	
	//MARK: -Outputs
	@Published var errorMessage: String?
	@Published var showAlert: Bool = false
	
	//MARK: -Computed properties
	var authenticationViewModel: AuthenticationViewModel {
		return AuthenticationViewModel(repository: authenticationRepository) { [weak self] in
			self?.isLogged = true
		}
	}
	
	var accountDetailViewModel: AccountDetailViewModel {
		return AccountDetailViewModel(repository: accountRepository)
	}
	
	var allTransactionsViewModel: AllTransactionsViewModel {
		return AllTransactionsViewModel(repository: accountRepository)
	}
	
	var moneyTransferViewModel: MoneyTransferViewModel {
		return MoneyTransferViewModel(repository: moneyTransferRepository)
	}
}
