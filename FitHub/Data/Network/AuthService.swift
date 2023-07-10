//
//  AuthService.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/10.
//

import Foundation
import Alamofire
import RxSwift

class AuthService {
    func signInAppleLogin(_ token: String)->Single<String> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        
        let urlString = baseURL + "users/login/social/kakao"
        let paramter: Parameters = ["identityToken" : token]
        
        return Single<String>.create { observer in
            AF.request(urlString, method: .post, parameters: paramter, encoding: JSONEncoding.default)
                .responseString(completionHandler: { res in
                    switch res.result {
                    case .success(let str):
                        observer(.success(str))
                    case .failure(let error):
                        observer(.failure(error))
                    }
                })
            return Disposables.create()
        }
        
    
    }
}
