//
//  AuthenticationResponse.swift
//
//
//  Created by Vincent Saluzzo on 03/10/2023.
//

import Vapor
//reçu via HTTP
struct AuthenticationResponse: Content {
    let token: String
}
