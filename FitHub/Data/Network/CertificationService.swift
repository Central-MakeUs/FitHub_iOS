//
//  CertificationService.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/27.
//

import Foundation
import RxSwift
import Alamofire

class CertificationService {
    func fecthCertification(_ categoryId: Int)->Single<CertificationFeedDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(CertificationError.invalidURL) }
        let urlString = baseURL + "records/\(categoryId)"

        return Single<CertificationFeedDTO>.create { observer in
            AF.request(urlString, interceptor: AuthManager())
                .responseDecodable(of: BaseResponse<CertificationFeedDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                        if response.code == 2000 {
                            guard let result = response.result else { return }
                            observer(.success(result))
                        } else {
                            print(response.code)
                            observer(.failure(CertificationError.serverError))
                        }
                    case .failure:
                        observer(.failure(AuthError.serverError))
                    }
                }
            return Disposables.create()
        }
    }
}
