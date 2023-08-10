//
//  ArticleService.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/09.
//

import Foundation
import RxSwift
import Alamofire

class ArticleService {
    
    func fetchArticles(categoryId: Int, page: Int, sortingType: SortingType)->Single<FitSiteFeedDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        var urlString = baseURL + "articles/\(categoryId)"
        if sortingType == .popularity { urlString += "/likes" }
        
        let paramter: Parameters = ["pageIndex" : page]
        
        return Single<FitSiteFeedDTO>.create { observer in
            AF.request(urlString, parameters: paramter, encoding: URLEncoding.queryString, interceptor: AuthManager())
                .responseString() { res in
                    switch res.result {
                    case .success(let str):
                        print(str)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
                .responseDecodable(of: BaseResponse<FitSiteFeedDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                        if response.code == 2000 {
                            guard let result = response.result else { return }
                            observer(.success(result))
                        } else {
                            print(response.message)
                            print(response.code)
                            observer(.failure(AuthError.serverError))
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                        observer(.failure(AuthError.serverError))
                    }
                }
            return Disposables.create()
        }
    }
}
