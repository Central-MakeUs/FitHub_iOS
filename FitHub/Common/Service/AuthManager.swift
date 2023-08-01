//
//  AuthManager.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/27.
//

import Alamofire
import Foundation

final class AuthManager: RequestInterceptor {
    private let retryLimit = 3
    
    /// request 전에 특정 작업을 하고 싶은 경우
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        guard let accessToken = KeychainManager.read("accessToken") else {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .presentAlert, object: nil)
            }
            
            return
        }
   
        var urlRequest = urlRequest
        urlRequest.headers.add(.authorization(bearerToken: accessToken))
        urlRequest.headers.add(.contentType("application/json"))
        completion(.success(urlRequest))
    }
    
    /// 특정 오류가 발생한 경우, retry가 필요한 경우
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        //TODO: 토큰 유효시간 문제시 재발급 후 재시도
    }
}
