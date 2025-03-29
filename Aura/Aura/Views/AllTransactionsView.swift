//
//  AllTransactionsView.swift
//  Aura
//
//  Created by Ordinateur elena on 13/03/2025.
//

import SwiftUI

struct AllTransactionsView: View {
	@ObservedObject var viewModel: AllTransactionsViewModel
	
	var body: some View {
		VStack(spacing: 20) {
			// Large Header displaying total amount
			VStack(spacing: 10) {
				Text("Your Balance")
					.font(.headline)
				
				Text(viewModel.formattedAmount(value: viewModel.totalAmount))
					.font(.system(size: 60, weight: .bold))
					.foregroundColor(Color(hex: "#94A684")) // Using the green color you provided
				
				Image(systemName: "eurosign.circle.fill")
					.resizable()
					.scaledToFit()
					.frame(height: 80)
					.foregroundColor(Color(hex: "#94A684"))
			}
			.padding(.top)
			VStack(alignment: .leading) {
				Text("Recent Transactions")
					.font(.headline)
					.padding([.horizontal])
				
				List {
					ForEach(viewModel.totalTransactions, id: \.id) { transaction in
						HStack {
							RawAllTransactionsView(viewModel: AllTransactionsViewModel(keychain: AuraKeyChainService.shared, repository: AuraService(keychain: AuraKeyChainService.shared)), transaction: transaction) // Passe transaction de l'itération à la propriété transaction de la sous vue
						}
					}
					.listRowSeparator(.hidden)
					.listRowInsets(EdgeInsets(top:5, leading:15, bottom: 5, trailing: 15))
				}
				.listStyle(.plain)
			}
			Spacer()
		}
		.onTapGesture {
			self.endEditing(true)  // This will dismiss the keyboard when tapping outside
		}
		.task{
			await viewModel.fetchTransactions()
		}
		.alert(isPresented: $viewModel.showAlert) {
			Alert(title: Text("Erreur"), message: Text(viewModel.errorMessage ?? ""), dismissButton: .default(Text("OK")))
		}
	}
}

//#Preview {
//	AllTransactionsView(viewModel: AllTransactionsViewModel(repository: AuraService()))
//}
