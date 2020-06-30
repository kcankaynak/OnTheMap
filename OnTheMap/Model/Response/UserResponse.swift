//
//  UserResponse.swift
//  OnTheMap
//
//  Created by Kemal Kaynak on 30.06.20.
//  Copyright © 2020 Kemal Kaynak. All rights reserved.
//

import Foundation

struct UserResponse: Codable {
    let user: UserModel
}

struct UserModel: Codable {
    var firstName: String
    var lastName: String
    var bio: String?
    var registered: Bool
    var linkedinUrl: String?
    var image: String?
    let key: String
    let websiteUrl: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case registered = "_registered"
        case linkedinUrl = "linkedin_url"
        case image = "_image"
        case websiteUrl = "website_url"
        case bio, key
    }
}
