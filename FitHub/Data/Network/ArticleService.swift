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
    
    func editArticle(categoryId: Int, feedInfo: EditFitSiteModel, remainImageList: [String])->Single<Bool> {
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
                                    "tagList" : tagList,
                                     "remainPictureUrlList" : remainImageList]
        
        return Single<Bool>.create { observer in
            AF.upload(multipartFormData: { multipartFormData in
                for image in images {
                    multipartFormData.append(image, withName: "newPictureList", fileName: "\(image)", mimeType: "image/jpeg")
                }
                
                for (key,value) in parameter {
                    multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                }
                
            }, to: urlString, method: .patch, headers: headers)
            .responseDecodable(of: BaseResponse<UpdateFitSiteDTO>.self) { res in
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
    
    func fetchFitSiteDetail(articleId: Int)->Single<FitSiteDetailDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        let urlString = baseURL + "articles/\(articleId)/spec"
        
        return Single<FitSiteDetailDTO>.create { observer in
            AF.request(urlString, interceptor: AuthManager())
                .responseDecodable(of: BaseResponse<FitSiteDetailDTO>.self) { res in
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
    
    func toggleLikeFitSite(articleId: Int)->Single<LikeFitSiteDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        let urlString = baseURL + "articles/\(articleId)/likes"
        
        return Single<LikeFitSiteDTO>.create { observer in
            AF.request(urlString, method: .post, interceptor: AuthManager())
                .responseDecodable(of: BaseResponse<LikeFitSiteDTO>.self) { res in
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
    
    func reportFitSite(articleId: Int)->Single<Int> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        var urlString = baseURL + "articles/\(articleId)/report"
        
        return Single<Int>.create { observer in
            AF.request(urlString, method: .post, interceptor: AuthManager())
                .responseDecodable(of: BaseResponse<ReportFitSiteDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                        observer(.success(response.code))
                    case .failure(let error):
                        print(error.localizedDescription)
                        observer(.failure(AuthError.serverError))
                    }
                }
            return Disposables.create()
        }
    }
    
    func deleteFitSite(articleId: Int)->Single<Bool> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        let urlString = baseURL + "articles/\(articleId)"
        
        return Single<Bool>.create { observer in
            AF.request(urlString, method: .delete, interceptor: AuthManager())
                .responseDecodable(of: BaseResponse<DeleteFitSiteDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                        if response.code == 2000 {
                            observer(.success(true))
                        } else {
                            print(response.message)
                            print(response.code)
                            observer(.success(false))
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                        observer(.failure(AuthError.serverError))
                    }
                }
            return Disposables.create()
        }
    }
    
    func scrapFitSite(articleId: Int)->Single<FitSiteScrapDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        let urlString = baseURL + "articles/\(articleId)/scrap"
        
        return Single<FitSiteScrapDTO>.create { observer in
            AF.request(urlString, method: .post, interceptor: AuthManager())
                .responseDecodable(of: BaseResponse<FitSiteScrapDTO>.self) { res in
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
    
    func deleteFitSites(articleIdList: [Int])->Single<DeleteFitSitesDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(CertificationError.invalidURL) }
    
        let urlString = baseURL + "articles"
        let parameter: Parameters = ["articleIdList" : articleIdList]
        
        return Single<DeleteFitSitesDTO>.create { emitter in
            AF.request(urlString, method: .patch, parameters: parameter, encoding: JSONEncoding.default, interceptor: AuthManager())
                .responseDecodable(of:BaseResponse<DeleteFitSitesDTO>.self) { res in
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
