//
//  SearchService.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/15.
//

import Foundation
import Alamofire
import RxSwift

class SearchService {
    func searchTotalItem(tag: String)->Single<SearchTotalDTO?> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        
        let urlString = baseURL + "search"
        let parameter: Parameters = ["tag" : tag]
        
        return Single<SearchTotalDTO?>.create { emitter in
            
            AF.request(urlString, parameters: parameter, encoding: URLEncoding.queryString, interceptor: AuthManager())
                .responseString() { res in
                    switch res.result {
                    case .success(let response):
                        print(response)
                    case .failure(let error):
                        print(error)
                    }
                }
                .responseDecodable(of: BaseResponse<SearchTotalDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                        emitter(.success(response.result))
                    case .failure(let error):
                        print(error)
                        emitter(.failure(error))
                    }
                }
            return Disposables.create()
        }
    }
    
    func searchCertification(tag: String, page: Int, type: SortingType)->Single<CertificationFeedDTO?> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        
        var urlString = baseURL + "search/records"
        if type == .popularity { urlString += "/likes" }
        
        let parameter: Parameters = ["tag" : tag,
                                     "pageIndex" : page]
        
        return Single<CertificationFeedDTO?>.create { emitter in
            
            AF.request(urlString, parameters: parameter, encoding: URLEncoding.queryString, interceptor: AuthManager())
                .responseDecodable(of: BaseResponse<CertificationFeedDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                        emitter(.success(response.result))
                    case .failure(let error):
                        print(error)
                        emitter(.failure(error))
                    }
                }
            return Disposables.create()
        }
    }
    
    func searchToFitSite(tag: String, page: Int, type: SortingType)->Single<FitSiteFeedDTO?> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        
        var urlString = baseURL + "search/articles"
        if type == .popularity { urlString += "/likes" }
        let parameter: Parameters = ["tag" : tag,
                                     "pageIndex" : page]
        
        return Single<FitSiteFeedDTO?>.create { emitter in
            
            AF.request(urlString, parameters: parameter, encoding: URLEncoding.queryString, interceptor: AuthManager())
                .responseDecodable(of: BaseResponse<FitSiteFeedDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                        emitter(.success(response.result))
                    case .failure(let error):
                        print(error)
                        emitter(.failure(error))
                    }
                }
            return Disposables.create()
        }
    }
    
    func fetchRecommendKeyword()->Single<RecommendKeywordDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        
        let urlString = baseURL + "search/articles/recommend-keyword"
        
        return Single<RecommendKeywordDTO>.create { emitter in
            
            AF.request(urlString, interceptor: AuthManager())
                .responseDecodable(of: BaseResponse<RecommendKeywordDTO>.self) { res in
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
}
