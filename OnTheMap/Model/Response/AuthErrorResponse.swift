//
//  LoginErrorResponse.swift
//  OnTheMap
//
//  Created by Kemal Kaynak on 29.06.20.
//  Copyright © 2020 Kemal Kaynak. All rights reserved.
//

import Foundation

struct AuthErrorResponse: Codable {
    let status: Int
    let error: String
}

extension AuthErrorResponse: LocalizedError {
    var errorDescription: String? {
        return error
    }
}
