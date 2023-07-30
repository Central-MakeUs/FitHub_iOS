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
    
    func createCertification(_ certificationInfo: EditCertificationModel) -> Single<CreateCertificationDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(CertificationError.invalidURL) }
        let contents = certificationInfo.content ?? ""
        let categoryId = certificationInfo.selectedSport?.id ?? 0
        guard let categoryTag = certificationInfo.selectedSport?.name else { return Single.error(CertificationError.otherError) }
        let hashTagList = certificationInfo.hashtags.joined(separator: ",")
        guard let image = certificationInfo.profileImage?.pngData() else { return Single.error(CertificationError.otherError) }
        let urlString = baseURL + "/records/\(categoryId)"
        
        let parameter: Parameters = ["contents" : contents,
                                     "exerciseTag" : categoryTag,
                                     "hashTagList" : hashTagList,
        ]
        
        print("호출")
        return Single<CreateCertificationDTO>.create { observer in
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(image, withName: "image",fileName: "\(image).png", mimeType: "mime/png")
                
                for (key,value) in parameter {
                    multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                }
            }, to: urlString, method: .post, interceptor: AuthManager())
                .responseDecodable(of: BaseResponse<CreateCertificationDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                    print(response)
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
