//
//  MoneyTransferView.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import SwiftUI

struct MoneyTransferView: View {
	@ObservedObject var viewModel: MoneyTransferViewModel
	@State private var animationScale: CGFloat = 1.0
	
	var body: some View {
		VStack(spacing: 20) {
			// Adding a fun header image
			Image(systemName: "arrow.right.arrow.left.circle.fill")
				.resizable()
				.scaledToFit()
				.frame(width: 80, height: 80)
				.foregroundColor(Color(hex: "#94A684"))
				.padding()
				.scaleEffect(animationScale)
				.onAppear {
					withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
						animationScale = 1.2
					}
				}
			Text("Send Money!")
				.font(.largeTitle)
				.fontWeight(.heavy)
			
			VStack(alignment: .leading) {
				Text("Recipient (Email or Phone)")
					.font(.headline)
				
				EntryField(placeHolder: "Enter recipient's info", field: $viewModel.recipient, isSecure: false, prompt: viewModel.phoneOrEmailPrompt )
					.keyboardType(.emailAddress)
			}
			
			VStack(alignment: .leading) {
				Text("Amount (€)")
					.font(.headline)
				
				EntryField(placeHolder: "0.00", field: $viewModel.amountString, isSecure: false, prompt: viewModel.amountPrompt )
					.keyboardType(.decimalPad)
			}
			
			Button(action:{
				Task {//car fonction async interdite dans views
					await viewModel.sendMoney()
				}
			}) {
				HStack {
					Image(systemName: "arrow.right.circle.fill")
					Text("Send")
				}
				.padding()
				.background(Color(hex: "#94A684"))
				.foregroundColor(.white)
				.cornerRadius(8)
			}
			.buttonStyle(PlainButtonStyle())
			if !viewModel.transferMessage.isEmpty {
				Text(viewModel.transferMessage)
					.padding(.top, 20)
					.transition(.move(edge: .top))
			}
			Spacer()
		}
		.padding()
		.onTapGesture {
			self.endEditing(true)  // This will dismiss the keyboard when tapping outside
		}
		.alert(isPresented: $viewModel.showAlert) {
			Alert(title: Text("Erreur"), message: Text(viewModel.errorMessage ?? ""), dismissButton: .default(Text("OK")))
		}
	}
}


//#Preview {
//	MoneyTransferView(viewModel: MoneyTransferViewModel(repository: AuraService()))
//}
