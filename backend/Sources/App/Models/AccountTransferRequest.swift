//
//  AccountTransferRequest.swift
//
//
//  Created by Vincent Saluzzo on 03/10/2023.
//

import Vapor
//envoyé via HTTP
struct AccountTransferRequest: Content, Validatable {
    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("recipient", as: String.self, is: .email ||  .pattern("^(?:(?:\\+|00)33[\\s.-]{0,3}(?:\\(0\\)[\\s.-]{0,3})?|0)[1-9](?:[\\s.-]?\\d{2}){4}$")) //vérif email ou tel valide
        validations.add("amount", as: Decimal.self, is: .valid) //vérif amount valide et décimal
    }
    let recipient: String
    let amount: Decimal
}
