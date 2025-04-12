//
//  AuraApp.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import SwiftUI

@main
struct AuraApp: App {
	@Environment(\.scenePhase) private var scenePhase  // Observe l'état de l'application (foreground, background, inactive)
	@StateObject private var viewModel: AppViewModel
	private let keychain = AuraKeychainService()
	private let APIService = AuraAPIService()
	
	init() {
		_ = keychain.deleteToken(key: K.Authentication.tokenKey) //supprime les anciens tokens au lancement de l'app
		let authenticationRepository = AuthenticationRepository(keychain: keychain, APIService: APIService)
		let accountRepository = AccountRepository(keychain: keychain, APIService: APIService)
		let moneyTransferRepository = MoneyTransferRepository(keychain: keychain, APIService: APIService)
		_viewModel = StateObject(wrappedValue: AppViewModel(authenticationRepository: authenticationRepository, accountRepository: accountRepository, moneyTransferRepository: moneyTransferRepository))
	}
	
	var body: some Scene {
		WindowGroup {
			Group { //n'ajoute pas de contraintes visuelles
				if viewModel.isLogged {
					TabView { //barre en bas de l'écran
						AccountDetailView(viewModel: viewModel.accountDetailViewModel)
							.tabItem {
								Image(systemName: "person.crop.circle")
								Text("Account")
							}
						MoneyTransferView(viewModel: viewModel.moneyTransferViewModel)
							.tabItem {
								Image(systemName: "arrow.right.arrow.left.circle")
								Text("Transfer")
							}
					}
				} else {
					AuthenticationView(viewModel: viewModel.authenticationViewModel)
						.transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
												removal: .move(edge: .top).combined(with: .opacity)))
				}
			}
			.accentColor(Color(hex: "#94A684"))
			.animation(.easeInOut(duration: 0.5), value: UUID())
		}
		.onChange(of: scenePhase) {
			if scenePhase == .background {
				// Supprime le token lorsque l'app passe en arrière-plan
				_ = keychain.deleteToken(key: K.Authentication.tokenKey)
				viewModel.isLogged = false
			}
		}
	}
}
