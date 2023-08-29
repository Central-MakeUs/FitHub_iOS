//
//  HomeService.swift
//  FitHub
//
//  Created by 신상우 on 2023/08/03.
//

import Foundation
import Alamofire
import RxSwift

class HomeService {
    func fetchHomeInfo() -> Single<HomeInfoDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(CertificationError.invalidURL) }
        let urlString = baseURL + "home"

        return Single<HomeInfoDTO>.create { observer in
            AF.request(urlString, interceptor: AuthManager())
                .responseDecodable(of: BaseResponse<HomeInfoDTO>.self) { res in
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
    
    func checkAuth() -> Single<Bool> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String
        else { return Single.error(CertificationError.invalidURL) }
        
        let accessToken = KeychainManager.read("accessToken") ?? ""
        var header: HTTPHeaders = HTTPHeaders()
        header.add(.authorization(bearerToken: accessToken))
        return Single<Bool>.create { emitter in
            AF.request(baseURL, headers: header)
                .responseDecodable(of:BaseResponse<CheckAuthDTO>.self) { res in
                    
                    switch res.result {
                    case .success(let response):
                        if response.code == 2008 {
                            emitter(.success(true))
                        } else {
                            emitter(.success(false))
                        }
                    case .failure(let error):
                        emitter(.failure(error))
                    }
                }
            
            return Disposables.create()
        }
    }
    
    func fetchLevelInfo() -> Single<LevelInfoDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String
        else { return Single.error(CertificationError.invalidURL) }
        
        let urlString = baseURL + "home/level-info"
        
        return Single<LevelInfoDTO>.create { emitter in
            AF.request(urlString, interceptor: AuthManager())
                .responseDecodable(of:BaseResponse<LevelInfoDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                        if response.code == 2000 {
                            guard let result = response.result else { return }
                            emitter(.success(result))
                        } else {
                            print(response.code)
                            print(response.message)
                            emitter(.failure(CertificationError.serverError))
                        }
                    case .failure(let error):
                        emitter(.failure(error))
                    }
                }
            
            return Disposables.create()
        }
    }
    
    func fetchBookMark(categoryId: Int, page: Int) -> Single<BookMarkDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String
        else { return Single.error(CertificationError.invalidURL) }
        let parameter: Parameters = ["pageIndex" : page]
        
        let urlString = baseURL + "home/book-mark/\(categoryId)"
        
        return Single<BookMarkDTO>.create { emitter in
            AF.request(urlString, parameters: parameter, encoding: URLEncoding.queryString, interceptor: AuthManager())
                .responseDecodable(of:BaseResponse<BookMarkDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                        if response.code == 2000 {
                            guard let result = response.result else { return }
                            emitter(.success(result))
                        } else {
                            print(response.code)
                            print(response.message)
                            emitter(.failure(CertificationError.serverError))
                        }
                    case .failure(let error):
                        emitter(.failure(error))
                    }
                }
            
            return Disposables.create()
        }
    }
    
    func fetchTermList() -> Single<TermsListDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String
        else { return Single.error(CertificationError.invalidURL) }
        
        let urlString = baseURL + "home/terms-list"
        
        return Single<TermsListDTO>.create { emitter in
            AF.request(urlString, interceptor: AuthManager())
                .responseDecodable(of:BaseResponse<TermsListDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                        if response.code == 2000 {
                            guard let result = response.result else { return }
                            emitter(.success(result))
                        } else {
                            print(response.code)
                            print(response.message)
                            emitter(.failure(CertificationError.serverError))
                        }
                    case .failure(let error):
                        emitter(.failure(error))
                    }
                }
            return Disposables.create()
        }
    }
    
    func checkNotiSetting() -> Single<NotiSettingDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String
        else { return Single.error(CertificationError.invalidURL) }
        
        let urlString = baseURL + "home/notification-permit"
        
        return Single<NotiSettingDTO>.create { emitter in
            AF.request(urlString, interceptor: AuthManager())
                .responseDecodable(of:BaseResponse<NotiSettingDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                        if response.code == 2000 {
                            guard let result = response.result else { return }
                            emitter(.success(result))
                        } else {
                            print(response.code)
                            print(response.message)
                            emitter(.failure(CertificationError.serverError))
                        }
                    case .failure(let error):
                        emitter(.failure(error))
                    }
                }
            return Disposables.create()
        }
    }
    
    func updateNotiSetting(communityPermit: Bool, marketingPermit: Bool) -> Single<NotiSettingDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String
        else { return Single.error(CertificationError.invalidURL) }
        
        let urlString = baseURL + "home/notification-permit"
        let parameter: Parameters = ["marketingPermit" : marketingPermit,
                                     "communityPermit" : communityPermit]
                          
        
        return Single<NotiSettingDTO>.create { emitter in
            AF.request(urlString, method: .patch, parameters: parameter, encoding: JSONEncoding.default, interceptor: AuthManager())
                .responseDecodable(of:BaseResponse<NotiSettingDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                        if response.code == 2000 {
                            guard let result = response.result else { return }
                            emitter(.success(result))
                        } else {
                            print(response.code)
                            print(response.message)
                            emitter(.failure(CertificationError.serverError))
                        }
                    case .failure(let error):
                        emitter(.failure(error))
                    }
                }
            return Disposables.create()
        }
    }
    
    func checkRemainAlarm() -> Single<CheckRemainAlarmDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String
        else { return Single.error(CertificationError.invalidURL) }
        
        let urlString = baseURL + "user/my-alarm"
                
        return Single<CheckRemainAlarmDTO>.create { emitter in
            AF.request(urlString, interceptor: AuthManager())
                .responseDecodable(of:BaseResponse<CheckRemainAlarmDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                        if response.code == 2000 {
                            guard let result = response.result else { return }
                            emitter(.success(result))
                        } else {
                            print(response.code)
                            print(response.message)
                            emitter(.failure(CertificationError.serverError))
                        }
                    case .failure(let error):
                        emitter(.failure(error))
                    }
                }
            return Disposables.create()
        }
    }
    
    func fetchFacilities(searchInfo: FacilitySearch)-> Single<FacilitiesDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String
        else { return Single.error(AuthError.invalidURL) }
        
        let urlString = baseURL + "home/facilities/\(searchInfo.categoryId)"
        var parameter: Parameters = ["x" : searchInfo.x,
                                     "y" : searchInfo.y,
                                     "userX" : searchInfo.userX,
                                     "userY" : searchInfo.userY]
        if !searchInfo.keyword.isEmpty { parameter["keyword"] = searchInfo.keyword }
        
        return Single<FacilitiesDTO>.create { emitter in
            AF.request(urlString, parameters: parameter, encoding: URLEncoding.queryString, interceptor: AuthManager())
                .responseDecodable(of:BaseResponse<FacilitiesDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                        if response.code == 2000 {
                            guard let result = response.result else { return }
                            emitter(.success(result))
                        } else {
                            print(response.code)
                            print(response.message)
                            emitter(.failure(CertificationError.serverError))
                        }
                    case .failure(let error):
                        emitter(.failure(error))
                    }
                }
            return Disposables.create()
        }
    }
}
