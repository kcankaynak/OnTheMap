//
//  LoginRequest.swift
//  OnTheMap
//
//  Created by Kemal Kaynak on 29.06.20.
//  Copyright © 2020 Kemal Kaynak. All rights reserved.
//

import Foundation

struct LogInStruct: Codable{
    var udacity: LoginRequest
}

struct LoginRequest: Codable {
    let username: String
    let password: String
}
