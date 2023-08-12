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
    
    func createArticle(categoryId: Int, feedInfo: EditFitSiteModel)->Single<Bool> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String,
              let token = KeychainManager.read("accessToken") else { return Single.error(AuthError.invalidURL)}
        let urlString = baseURL + "articles/\(categoryId)"
        
        var headers: HTTPHeaders = ["Content-Type" : "multipart/form-data"]
        headers.add(.authorization(bearerToken: token))
        
        guard let contents = feedInfo.content,
              let title = feedInfo.title,
              let exerciseTag = feedInfo.selectedSport?.name else { return Single.error(AuthError.invalidURL)}
                
        let tagList = feedInfo.hashtags.filter { !$0.isEmpty }.joined(separator: ",")
        let images = feedInfo.images.compactMap { $0?.jpegData(compressionQuality: .leastNormalMagnitude) }
        let parameter: Parameters = ["title" : title,
                                    "contents" : contents,
                                    "exerciseTag" : exerciseTag,
                                    "tagList" : tagList]
        
        return Single<Bool>.create { observer in
            AF.upload(multipartFormData: { multipartFormData in
                for image in images {
                    multipartFormData.append(image, withName: "pictureList", fileName: "\(image)", mimeType: "image/jpeg")
                }
                
                for (key,value) in parameter {
                    multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                }
                
            }, to: urlString, method: .post, headers: headers)
            .responseDecodable(of: BaseResponse<CreateFitSiteDTO>.self) { res in
                switch res.result {
                case .success(let response):
                    if response.code == 2000 {
                        observer(.success(true))
                    } else {
                        observer(.success(false))
                    }
                case .failure(let error):
                    print(error)
                    observer(.failure(error))
                }
            }
            
            return Disposables.create()
        }
        
    }
}
