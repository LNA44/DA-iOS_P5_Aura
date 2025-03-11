//
//  View+Extensions.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import SwiftUI

extension View {
    func endEditing(_ force: Bool) {
		guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
				scene.windows.forEach { $0.endEditing(true) }
    }
}
