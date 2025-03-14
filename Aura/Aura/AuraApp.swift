//
//  AuraApp.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import SwiftUI

@main
struct AuraApp: App {
	//@StateObject var viewModel = AppViewModel(repository: AuraRepository())
	@StateObject private var viewModel: AppViewModel //new
	
	init() { //new
		_viewModel = StateObject(wrappedValue: AppViewModel(repository: AuraService()))
	}
	
    var body: some Scene {
        WindowGroup {
            Group {
                if viewModel.isLogged {
                    TabView { //barre en bas de l'écran
                        AccountDetailView(viewModel: viewModel.accountDetailViewModel)
                            .tabItem {
                                Image(systemName: "person.crop.circle")
                                Text("Account")
                            }
                        
                        MoneyTransferView()
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
    }
}
