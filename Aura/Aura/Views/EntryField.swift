//
//  EntryField.swift
//  Aura
//
//  Created by Ordinateur elena on 10/03/2025.
//

import SwiftUI

struct EntryField: View {
	var placeHolder: String
	@Binding var field: String
	var isSecure: Bool
	var prompt : String
	
	var body: some View {
		VStack(alignment:.leading) {
			HStack {
				if isSecure {
					SecureField(placeHolder, text: $field).autocapitalization(.none)
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
