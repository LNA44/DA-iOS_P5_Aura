//
//  AuraApp.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import SwiftUI

@main
struct AuraApp: App {
	@Environment(\.scenePhase) private var scenePhase  // Observe l'état de l'application (active, background, inactive)
	@StateObject private var viewModel: AppViewModel
	private let keychain = AuraKeychainService()
	
	init() {
		let authenticationRepository = AuthenticationRepository(keychain: keychain)
		let accountRepository = AccountRepository(keychain: keychain)
		let moneyTransferRepository = MoneyTransferRepository(keychain: keychain)
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
			.environmentObject(viewModel)
		}
		.onChange(of: scenePhase) {
			switch scenePhase {
			case .background, .active:
				do {
					// Supprime le token lorsque l'app passe en arrière-plan ou se lance
					_ = try keychain.deleteToken(key: Constante.Authentication.tokenKey)
					viewModel.isLogged = false
				} catch {
					viewModel.showAlert = true
					viewModel.errorMessage = "Erreur lors de la suppression du token : \(error)" //transmis à AuthenticationView pour afficher alerte
				}
			default:
				break
			}
		}
	}
}
