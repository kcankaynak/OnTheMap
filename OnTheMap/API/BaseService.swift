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
        case studentLocation
        case studendList
        case getUser(String)
        
        var stringValue: String {
            switch self {
            case .auth:
                return EndPoints.base + "session"
            case .webAuth:
                return "https://auth.udacity.com/sign-up/?redirect_to=webAuthLogin:authenticate"
            case .studentLocation:
                return EndPoints.base + "StudentLocation"
            case .studendList:
                return EndPoints.studentLocation.stringValue + "?limit=100&order=-updatedAt"
            case .getUser(let id):
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
    
    func logIn(_ username: String, password: String, success: @escaping (LogInResponse) -> (), failure: @escaping (Error) -> ()) {
        let loginData = LogInStruct(udacity: LoginRequest(username: username, password: password))
        setupPostRequest(EndPoints.auth.url, bodyData: loginData, shouldEscape: true) { (result: Result<LogInResponse, Error>) in
            switch result {
            case .success(let response):
                UserData.id = response.session.id
                self.fetchUser { (userData, error) in
                    guard let userData = userData else {
                        DispatchQueue.main.async {
                            success(response)
                        }
                        return
                    }
                    UserData.uniqueKey = userData.key
                    UserData.firstName = userData.firstName
                    UserData.lastName = userData.lastName
                    DispatchQueue.main.async {
                        success(response)
                    }
                }
            case .failure(let error):
                failure(error)
            }
        }
    }
    
    func fetchStudents(completion: @escaping (Error?) -> ()) {
        setupGetRequest(url: EndPoints.studendList.url, responseType: StudentResponse.self, shouldEscape: false, completion: { (result: Result<StudentResponse, Error>) in
            switch result {
            case .success(let response):
                appDel.students = response
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        })
    }
    
    private func fetchUser(completion: @escaping(GetUserResponse?, Error?) -> ()) {
        setupGetRequest(url: EndPoints.getUser(UserData.id).url, responseType: GetUserResponse.self, shouldEscape: true, completion: { (result: Result<GetUserResponse, Error>) in
            switch result {
            case .success(let response):
                completion(response, nil)
            case .failure(let error):
                completion(nil, error)
            }
        })
    }
    
    func createUser(_ request: StudentRequest, completion: @escaping(Error?) -> ()) {
        setupPostRequest(EndPoints.studentLocation.url, bodyData: request, shouldEscape: false) { (result: Result<CreateUserResponse, Error>) in
            switch result {
            case .success(_):
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func logOut(success: @escaping (LogOutResponse) -> (), failure: @escaping (Error) -> ()) {
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

// MARK: - Get Request -

extension BaseService {
    
    func setupGetRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, shouldEscape: Bool, completion: @escaping (Result<ResponseType, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(error!))
                }
                return
            }
            do {
                var response: ResponseType!
                if shouldEscape {
                    response = try JSONDecoder().decode(ResponseType.self, from: data.subdata(in: 5..<data.count))
                } else {
                    response = try JSONDecoder().decode(ResponseType.self, from: data)
                }
                DispatchQueue.main.async {
                    completion(.success(response))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

// MARK: - Post Request -

extension BaseService {
    
    func setupPostRequest<RequestType: Encodable, ResponseType: Decodable>(_ url: URL, bodyData: RequestType, shouldEscape: Bool, completion: @escaping (Result<ResponseType, Error>) -> Void) {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            urlRequest.httpBody = try JSONEncoder().encode(bodyData)
        } catch {
            fatalError("HTTP body is not set correctly. Failed with error -> \(error.localizedDescription)")
        }
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard error == nil, let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(error!))
                }
                return
            }
            do {
                var responseObject: ResponseType!
                if shouldEscape {
                    responseObject = try JSONDecoder().decode(ResponseType.self, from: data.subdata(in: 5..<data.count))
                } else {
                    responseObject = try JSONDecoder().decode(ResponseType.self, from: data)
                }
                DispatchQueue.main.async {
                    completion(.success(responseObject))
                }
            } catch {
                do {
                    let errorResponse = try JSONDecoder().decode(AuthErrorResponse.self, from: data) as Error
                    DispatchQueue.main.async {
                        completion(.failure(errorResponse))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }.resume()
    }
}

// MARK: - Cancel Task by URL -

extension BaseService {
    
    func cancelTaskBy(_ url: URL) {
        URLSession.shared.getAllTasks { tasks in
            tasks.filter { $0.state == .running }.filter { $0.originalRequest?.url == url }.first?.cancel()
        }
    }
}
