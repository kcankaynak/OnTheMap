//
//  UserResponse.swift
//  OnTheMap
//
//  Created by Kemal Kaynak on 30.06.20.
//  Copyright © 2020 Kemal Kaynak. All rights reserved.
//

import Foundation

//struct UserResponse: Codable {
//    let user: UserModel
//    enum CodingKeys: String, CodingKey {
//        case user
//    }
//}

struct GetUserResponse: Codable {
    var firstName: String
    var lastName: String
    let key: String
    let websiteUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case websiteUrl = "website_url"
        case key
    }
}
