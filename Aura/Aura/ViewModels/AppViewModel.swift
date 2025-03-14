//
//  AppViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class AppViewModel: ObservableObject {
    @Published var isLogged: Bool
	private let repository: AuraService
	init(repository: AuraService) {
		self.repository = repository
        isLogged = false
    }
    
    var authenticationViewModel: AuthenticationViewModel {
		return AuthenticationViewModel(repository: repository) { [weak self] in
            self?.isLogged = true
        }
    }
    
    var accountDetailViewModel: AccountDetailViewModel {
        return AccountDetailViewModel()
    }
}
