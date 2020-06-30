//
//  LogoutResponse.swift
//  OnTheMap
//
//  Created by Kemal Kaynak on 29.06.20.
//  Copyright © 2020 Kemal Kaynak. All rights reserved.
//

import Foundation

struct LogOutResponse: Codable {
    let session: LogOutResponseData
}

struct LogOutResponseData: Codable {
    let id: String
    let expiration: String
}
