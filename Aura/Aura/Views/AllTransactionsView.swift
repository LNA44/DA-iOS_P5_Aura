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
		ScrollView {
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
				
				// Display recent transactions
				VStack(alignment: .leading, spacing: 10) {
					Text("Recent Transactions")
						.font(.headline)
						.padding([.horizontal])
					ForEach(viewModel.totalTransactions, id: \.id) { transaction in
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
				
				Spacer()
			}
			.onTapGesture {
				self.endEditing(true)  // This will dismiss the keyboard when tapping outside
			}
			.task{
				await viewModel.fetchTransactions()
			}
		}
	}
}

#Preview {
	AllTransactionsView(viewModel: AllTransactionsViewModel())
}
