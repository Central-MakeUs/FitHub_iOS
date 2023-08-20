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
    func fecthCertification(_ categoryId: Int, pageIndex: Int, type: SortingType)->Single<CertificationFeedDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(CertificationError.invalidURL) }
    
        var urlString = baseURL + "records/\(categoryId)"
        if type == .popularity { urlString += "likes"}
        
        let parameter: Parameters = ["pageIndex" : pageIndex]
        
        return Single<CertificationFeedDTO>.create { observer in
            AF.request(urlString, parameters: parameter, encoding: URLEncoding.queryString, interceptor: AuthManager())
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
        
        guard let categoryTag = certificationInfo.selectedSport?.name,
              let image = certificationInfo.profileImage?.jpegData(compressionQuality: 0.2),
              let accessToken = KeychainManager.read("accessToken") else { return Single.error(CertificationError.otherError) }
        
        let contents = certificationInfo.content ?? ""
        let categoryId = certificationInfo.selectedSport?.id ?? 0
        let hashTagList = certificationInfo.hashtags.filter { !$0.isEmpty }.joined(separator: ",")
        let urlString = baseURL + "records/\(categoryId)"
        
        let parameter: Parameters = ["contents" : contents,
                                     "exerciseTag" : categoryTag,
                                     "hashTagList" : hashTagList,
        ]
        
        
        let headers: HTTPHeaders = [.authorization(bearerToken: accessToken),
                                    .contentType("multipart/form-data")]
        
        return Single<CreateCertificationDTO>.create { observer in
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(image, withName: "image", fileName: "\(image).jpeg", mimeType: "image/jpeg")
                
                for (key,value) in parameter {
                    multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                }
            }, to: urlString, method: .post, headers: headers)
            .responseDecodable(of: BaseResponse<CreateCertificationDTO>.self) { res in
                switch res.result {
                case .success(let response):
                    print(response.code)
                    if response.code == 2000 {
                        guard let result = response.result else { return }
                        observer(.success(result))
                    } else {
                        observer(.failure(CertificationError.serverError))
                    }
                case .failure:
                    observer(.failure(AuthError.serverError))
                }
            }
            return Disposables.create()
        }
    }
    
    func fetchCertifiactionDetail(recordId: Int)->Single<CertificationDetailDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(CertificationError.invalidURL) }
    
        let urlString = baseURL + "records/\(recordId)/spec"
        
        return Single<CertificationDetailDTO>.create { emitter in
            AF.request(urlString, interceptor: AuthManager())
                .responseDecodable(of:BaseResponse<CertificationDetailDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                        if response.code == 2000 {
                            guard let result = response.result else { return }
                            emitter(.success(result))
                        } else {
                            print(response.code)
                        }
                    case .failure(let error):
                        emitter(.failure(AuthError.serverError))
                        print(error)
                    }
                }
            
            return Disposables.create()
        }
    }
    
    func reportCertification(recordId: Int)->Single<Int> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(CertificationError.invalidURL) }
    
        let urlString = baseURL + "records/\(recordId)/report"
        
        return Single<Int>.create { emitter in
            AF.request(urlString, method: .post, interceptor: AuthManager())
                .responseDecodable(of:BaseResponse<ReportCertificationDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                        emitter(.success(response.code))
                    case .failure(let error):
                        emitter(.failure(AuthError.serverError))
                        print(error)
                    }
                }
            
            return Disposables.create()
        }
    }
    
    func removeCertification(recordId: Int)->Single<Int> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(CertificationError.invalidURL) }
    
        let urlString = baseURL + "records/\(recordId)"
        
        return Single<Int>.create { emitter in
            AF.request(urlString, method: .delete, interceptor: AuthManager())
                .responseDecodable(of:BaseResponse<DeleteCertificationDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                        emitter(.success(response.code))
                    case .failure(let error):
                        emitter(.failure(AuthError.serverError))
                        print(error)
                    }
                }
            
            return Disposables.create()
        }
    }
    
    func toggleLikeCertification(recordId: Int)->Single<LikeCertificationDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(CertificationError.invalidURL) }
    
        let urlString = baseURL + "records/\(recordId)/likes"
        
        return Single<LikeCertificationDTO>.create { emitter in
            AF.request(urlString, method: .post, interceptor: AuthManager())
                .responseDecodable(of:BaseResponse<LikeCertificationDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                        if response.code == 2000 {
                            guard let result = response.result else { return }
                            emitter(.success(result))
                        } else {
                            print(response.code)
                            print(response.message)
                            emitter(.failure(AuthError.invalidURL))
                        }
                    case .failure(let error):
                        emitter(.failure(AuthError.serverError))
                        print(error)
                    }
                }
            
            return Disposables.create()
        }
    }
    
    func deleteCertifications(recordIdList: [Int])->Single<CertificationDeleteRecordsDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(CertificationError.invalidURL) }
    
        let urlString = baseURL + "records"
        let parameter: Parameters = ["recordIdList" : recordIdList]
        
        return Single<CertificationDeleteRecordsDTO>.create { emitter in
            AF.request(urlString, method: .patch, parameters: parameter, encoding: JSONEncoding.default, interceptor: AuthManager())
                .responseDecodable(of:BaseResponse<CertificationDeleteRecordsDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                        if response.code == 2000 {
                            guard let result = response.result else { return }
                            emitter(.success(result))
                        } else {
                            print(response.code)
                            print(response.message)
                            emitter(.failure(AuthError.invalidURL))
                        }
                    case .failure(let error):
                        emitter(.failure(AuthError.serverError))
                        print(error)
                    }
                }
            
            return Disposables.create()
        }
    }
    
    func deleteCertification(recordId: Int)->Single<CertificationDeleteRecordDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(CertificationError.invalidURL) }
    
        let urlString = baseURL + "record/\(recordId)"
        
        return Single<CertificationDeleteRecordDTO>.create { emitter in
            AF.request(urlString, method: .delete, interceptor: AuthManager())
                .responseDecodable(of:BaseResponse<CertificationDeleteRecordDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                        if response.code == 2000 {
                            guard let result = response.result else { return }
                            emitter(.success(result))
                        } else {
                            print(response.code)
                            print(response.message)
                            emitter(.failure(AuthError.invalidURL))
                        }
                    case .failure(let error):
                        emitter(.failure(AuthError.serverError))
                        print(error)
                    }
                }
            
            return Disposables.create()
        }
    }
}
