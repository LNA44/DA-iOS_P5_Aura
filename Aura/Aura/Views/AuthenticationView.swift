//
//  AuthenticationView.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import SwiftUI

struct AuthenticationView: View {
	@ObservedObject var viewModel: AuthenticationViewModel
	let gradientStart = Color(hex: "#94A684").opacity(0.7)
	let gradientEnd = Color(hex: "#94A684").opacity(0.0) // Fades to transparent
	
	var body: some View {
		ZStack {
			// Background gradient
			LinearGradient(gradient: Gradient(colors: [gradientStart, gradientEnd]), startPoint: .top, endPoint: .bottomLeading)
				.edgesIgnoringSafeArea(.all)
			VStack(spacing: 20) {
				Image(systemName: "person.circle")
					.resizable()
					.scaledToFit()
					.frame(width: 50, height: 50)
				
				Text("Welcome !")
					.font(.largeTitle)
					.fontWeight(.semibold)
				
				EntryField(placeHolder: "Email Adress", field: $viewModel.username, isSecure: false, prompt:viewModel.emailPrompt)
					.autocapitalization(.none)
					.keyboardType(.emailAddress)
					.disableAutocorrection(true)
				
				EntryField(placeHolder: "Password", field: $viewModel.password, isSecure: true, prompt:viewModel.passwordPrompt)
				
				Button(action: {
					Task {
						await viewModel.login()
					}
				}) {
					Text("Se connecter")
						.foregroundColor(.white)
						.frame(maxWidth: .infinity)
						.padding()
						.background(Color(hex: "#94A684"))
						.cornerRadius(8)
				}
				.opacity(viewModel.isSignUpComplete ? 1 : 0.6)
				//1 if true else 0.6
				.disabled(!viewModel.isSignUpComplete)
				//désactive : plus d'interaction possible
			}
			.padding(.horizontal, 40)
		}
		.onTapGesture {
			self.endEditing(true)  // This will dismiss the keyboard when tapping outside
		}
		.alert(isPresented: $viewModel.showAlert) {
			Alert(title: Text("Erreur"), message: Text(viewModel.errorMessage ?? ""), dismissButton: .default(Text("OK")))
		}
	}
}

//#Preview {
//	AuthenticationView(viewModel: AuthenticationViewModel(repository: AuraService()))
//}
