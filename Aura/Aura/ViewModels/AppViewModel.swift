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
	private let repository: AuraRepository
	
	//MARK: - Initialisation
	init(repository: AuraRepository) {
		self.repository = repository
		isLogged = false
	}
	
	//MARK: - Computed properties
	var authenticationViewModel: AuthenticationViewModel {
		return AuthenticationViewModel(repository: repository) { [weak self] in
			self?.isLogged = true
		}
	}
	
	var accountDetailViewModel: AccountDetailViewModel {
		return AccountDetailViewModel(repository:repository)
	}
	
	var allTransactionsViewModel: AllTransactionsViewModel {
		return AllTransactionsViewModel(repository:repository)
	}
	
	var moneyTransferViewModel: MoneyTransferViewModel {
		return MoneyTransferViewModel(repository:repository)
	}
}
