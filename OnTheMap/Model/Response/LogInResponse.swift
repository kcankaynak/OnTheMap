//
//  LoginResponse.swift
//  OnTheMap
//
//  Created by Kemal Kaynak on 29.06.20.
//  Copyright © 2020 Kemal Kaynak. All rights reserved.
//

import Foundation

struct LogInResponse: Codable {
    let account: LogInAccountResponse
    let session: LogInAccountSession
}

struct LogInAccountResponse: Codable {
    let registered: Bool
    let key: String
}

struct LogInAccountSession: Codable {
    let id: String
    let expiration: String
}
