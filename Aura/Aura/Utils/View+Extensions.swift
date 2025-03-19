//
//  View+Extensions.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import SwiftUI

extension View {
    func endEditing(_ force: Bool) {
		guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return } //récupère la première scène connectée à l'app (qui contient ttes les scènes) et essaye de la caster en UIWindowsScene
				scene.windows.forEach { $0.endEditing(true) }//ferme le clavier
    }
}
