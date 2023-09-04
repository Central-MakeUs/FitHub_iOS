//
//  AlarmService.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/23.
//

import Foundation
import Alamofire
import RxSwift

class AlarmService {
    func fetchAlramList(page: Int)->Single<AlarmListDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        
        let urlString = baseURL + "users/alarms"
        let parameter: Parameters = ["pageIndex" : page]
        
        return Single<AlarmListDTO>.create { emitter in
            
            AF.request(urlString, parameters: parameter, encoding: URLEncoding.queryString, interceptor: AuthManager())
                .responseDecodable(of: BaseResponse<AlarmListDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                        guard let result = response.result else { return }
                        emitter(.success(result))
                    case .failure(let error):
                        print(error)
                        emitter(.failure(error))
                    }
                }
            return Disposables.create()
        }
    }
    
    func confirmAlram(alarmId: Int)->Single<Bool> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        
        let urlString = baseURL + "users/alarms/\(alarmId)"
        
        return Single<Bool>.create { emitter in
            
            AF.request(urlString, interceptor: AuthManager())
                .responseDecodable(of: BaseResponse<ConfirmAlertDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                        if response.code == 2000 {
//                            guard let result = response.result else { return }
                            emitter(.success(true))
                        } else {
                            emitter(.success(false))
                        }
                    case .failure(let error):
                        print(error)
                        emitter(.failure(error))
                    }
                }
            return Disposables.create()
        }
    }
}

