//
//  AllTransactionsRawView.swift
//  Aura
//
//  Created by Ordinateur elena on 13/03/2025.
//

import SwiftUI

struct RawAllTransactionsView: View {
	@ObservedObject var viewModel: AllTransactionsViewModel
	let transaction: Transaction
	var body: some View {
		HStack{
				Image(systemName: transaction.value >= 0 ? "arrow.up.right.circle.fill" : "arrow.down.left.circle.fill")
					.foregroundColor(transaction.value >= 0 ? .green : .red)
				Text(transaction.label)
				Spacer()
				Text(viewModel.formattedAmount(value:transaction.value))
					.fontWeight(.bold)
					.foregroundColor(transaction.value >= 0 ? .green : .red)
		}.padding()
			.background(Color.gray.opacity(0.1))
			.cornerRadius(8)
	}
}

