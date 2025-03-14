//
//  EntryFieldDouble.swift
//  Aura
//
//  Created by Ordinateur elena on 14/03/2025.
//

import SwiftUI

struct EntryFieldDouble: View {
	var placeHolder: String
	@Binding var field: String
	var isSecure: Bool
	var prompt : String
	
	var body: some View {
		VStack(alignment:.leading) {
			HStack {
				if isSecure {
					SecureField(placeHolder, text: $field).autocapitalization(.none)//TextField ne prend comme paramètre text qu'un String, pas de Décimal
				} else {
					TextField(placeHolder, text: $field).autocapitalization(.none)
				}
			}.padding()
				.background(Color(UIColor.secondarySystemBackground))
				.cornerRadius(8)
			Text(prompt)
				.font(.caption)
		}
	}
}
