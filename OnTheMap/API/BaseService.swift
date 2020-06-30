//
//  BaseService.swift
//  OnTheMap
//
//  Created by Kemal Kaynak on 29.06.20.
//  Copyright © 2020 Kemal Kaynak. All rights reserved.
//

import Foundation
import UIKit

final class BaseService {
    
    static let shared = BaseService()
    private init(){}
    
    enum EndPoints {
        static let base = "https://onthemap-api.udacity.com/v1/"
        
        case auth
        case webAuth
        case studendList
        case user(String)
        
        var stringValue: String {
            switch self {
            case .auth:
                return EndPoints.base + "session"
            case .webAuth:
                return "https://auth.udacity.com/sign-up/?redirect_to=webAuthLogin:authenticate"
            case .studendList:
                return EndPoints.base + "StudentLocation?limit=100&order=-updatedAt"
            case .user(let id):
                return EndPoints.base + "users/\(id)"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    struct UserData {
        static var id = ""
        static var uniqueKey = ""
        static var firstName = ""
        static var lastName = ""
    }
}

extension BaseService {
    
    final func setupPostRequest<RequestType: Encodable, ResponseType: Decodable>(_ url: URL, bodyData: RequestType, completion: @escaping (Result<ResponseType, Error>) -> Void) {
        
    }
    
    func logInService(_ username: String, password: String, success: @escaping (LogInResponse) -> (), failure: @escaping (Error) -> ()) {
        let loginData = LogInStruct(udacity: LoginRequest(username: username, password: password))
        var urlRequest = URLRequest(url: EndPoints.auth.url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            urlRequest.httpBody = try JSONEncoder().encode(loginData)
        } catch {
            fatalError("HTTP body is not set correctly. Failed with error -> \(error.localizedDescription)")
        }
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard error == nil, let data = data else {
                DispatchQueue.main.async {
                    failure(error!)
                }
                return
            }
            do {
                let responseObject = try JSONDecoder().decode(LogInResponse.self, from: data.subdata(in: 5..<data.count))
                UserData.id = responseObject.session.id
                self.fetchUser { (userData, error) in
                    guard let userData = userData else { return }
                    UserData.uniqueKey = userData.user.key
                    UserData.firstName = userData.user.firstName
                    UserData.lastName = userData.user.lastName
                }
                DispatchQueue.main.async {
                    success(responseObject)
                }
            } catch {
                do {
                    let errorResponse = try JSONDecoder().decode(AuthErrorResponse.self, from: data) as Error
                    DispatchQueue.main.async {
                        failure(errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        failure(error)
                    }
                }
            }
        }.resume()
    }
    
    func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, shouldEscape: Bool, completion: @escaping (ResponseType?, Error?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            do {
                var responseObject: ResponseType!
                if shouldEscape {
                    responseObject = try JSONDecoder().decode(ResponseType.self, from: data)
                } else {
                    responseObject = try JSONDecoder().decode(ResponseType.self, from: data.subdata(in: 5..<data.count))
                }
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }.resume()
    }
    
    func fetchStudents(completion: @escaping (Error?) -> ()) {
        taskForGETRequest(url: EndPoints.studendList.url, responseType: StudentResponse.self, shouldEscape: false) { (response, error) in
            guard error == nil, let response = response else {
                completion(error!)
                return
            }
            appDel.students = response
            completion(nil)
        }
    }
    
    private func fetchUser(completion: @escaping(UserResponse?, Error?) -> ()) {
        taskForGETRequest(url: EndPoints.user(UserData.id).url, responseType: UserResponse.self, shouldEscape: true) { (response, error) in
            guard error == nil, let response = response else {
                completion(nil, error!)
                return
            }
            completion(response, nil)
        }
    }
    
    final func logOutService(success: @escaping (LogOutResponse) -> (), failure: @escaping (Error) -> ()) {
        var urlRequest = URLRequest(url: EndPoints.auth.url)
        urlRequest.httpMethod = "DELETE"
        deleteCookies(&urlRequest)
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard error == nil, let data = data else {
                DispatchQueue.main.async {
                    failure(error!)
                }
                return
            }
            do {
                let responseObject = try JSONDecoder().decode(LogOutResponse.self, from: data.subdata(in: 5..<data.count))
                DispatchQueue.main.async {
                    self.removeUserData()
                    success(responseObject)
                }
            } catch {
                do {
                    let errorResponse = try JSONDecoder().decode(AuthErrorResponse.self, from: data) as Error
                    DispatchQueue.main.async {
                        failure(errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        failure(error)
                    }
                }
            }
        }.resume()
    }
    
    private func deleteCookies(_ request: inout URLRequest) {
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        guard let cookies = sharedCookieStorage.cookies else { return }
        for cookie in cookies {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
    }
    
    private func removeUserData() {
        UserData.id = ""
        UserData.uniqueKey = ""
        UserData.firstName = ""
        UserData.lastName = ""
    }
}
