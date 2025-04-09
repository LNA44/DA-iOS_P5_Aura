//
//  AccountDetailView.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import SwiftUI

struct AccountDetailView: View {
	@ObservedObject var viewModel: AccountDetailViewModel
	
	var body: some View {
		NavigationStack {
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
				
				VStack(alignment: .leading, spacing: 10) {
					Text("Recent Transactions")
						.font(.headline)
						.padding([.horizontal])
					
					ForEach(viewModel.recentTransactions, id: \.id) { transaction in
						HStack {
							Image(systemName: transaction.value >= 0 ? "arrow.up.right.circle.fill" : "arrow.down.left.circle.fill")
								.foregroundColor(transaction.value >= 0 ? .green : .red)
							
							Text(transaction.label)
							
							Spacer()
							
							Text(viewModel.formattedAmount(value:transaction.value))
								.fontWeight(.bold)
								.foregroundColor(transaction.value >= 0 ? .green : .red)
						}
						.padding()
						.background(Color.gray.opacity(0.1))
						.cornerRadius(8)
						.padding([.horizontal])
						
					}
				}
				
				//Remplacement du bouton par un navigationlink
				NavigationLink (destination: AllTransactionsView(viewModel: AllTransactionsViewModel(repository: AuraRepository(keychain: AuraKeyChainService())))) {
					HStack {
						Image(systemName: "list.bullet")
						Text("See Transaction Details")
					}
					.padding()
					.background(Color(hex: "#94A684"))
					.foregroundColor(.white)
					.cornerRadius(8)
				}
				.padding([.horizontal, .bottom])
				
				Spacer()
			}
			.onTapGesture {
				self.endEditing(true)  // This will dismiss the keyboard when tapping outside
			}
			.task {
				await viewModel.fetchTransactions()
			}
			.alert(isPresented: $viewModel.showAlert) {
				Alert(title: Text("Erreur"), message: Text(viewModel.errorMessage ?? ""), dismissButton: .default(Text("OK")))
			}
		}
	}
}

/*#Preview {
	AccountDetailView(viewModel: AccountDetailViewModel(repository: AuraService(keychain: AuraKeyChainServiceMock())))
}
*/
/*struct AccountDetailView_Previews: PreviewProvider {
	static var previews: some View {

		let keychain = AuraKeyChainServiceMock()
		
		let viewModel = AccountDetailViewModel(repository: AuraService(executeDataRequest: AuraServiceFetchAccountDetailsMock(), keychain: keychain))
		
		keychain.storeToken(token: "93D2C537-FA4A-448C-90A9-6058CF26DB29", key: "authToken")

		defer {
			keychain.removeToken(key: "authToken")
		}

		return AccountDetailView(viewModel: viewModel)
	}
}
*/
