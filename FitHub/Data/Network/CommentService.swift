//
//  CommentService.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/13.
//

import Foundation
import Alamofire
import RxSwift

enum CommentType:String {
    case articles
    case records
}

class CommentService {
    func fetchComments(type: CommentType, page: Int, id: Int)->Single<FetchCommentDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        
        let urlString = baseURL + "\(type.rawValue)/\(id)/comments"
        let parameter: Parameters = ["pageIndex" : page]
        
        return Single<FetchCommentDTO>.create { emitter in
            
            AF.request(urlString, parameters: parameter, encoding: URLEncoding.queryString, interceptor: AuthManager())
                .responseDecodable(of: BaseResponse<FetchCommentDTO>.self) { res in
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
    
    func createComment(type: CommentType, id: Int, contents: String)->Single<Bool> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        let urlString = baseURL + "\(type.rawValue)/\(id)/comments"
        let parameter: Parameters = ["contents" : contents]
        
        return Single<Bool>.create { emitter in
            AF.request(urlString, method: .post, parameters: parameter, encoding: JSONEncoding.default, interceptor: AuthManager())
                .responseDecodable(of: BaseResponse<CreateCommentDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                        if response.code == 2000 {
                            emitter(.success(true))
                        } else {
                            print(response.code)
                            print(response.message)
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
    
    func toggleCommentLike(type: CommentType, id: Int, commentId: Int)-> Single<LikeCommentDTO> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        let urlString = baseURL + "\(type)/\(id)/comments/\(commentId)"
        
        return Single<LikeCommentDTO>.create { emitter in
            AF.request(urlString, method: .post, interceptor: AuthManager())
                .responseDecodable(of: BaseResponse<LikeCommentDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                        if response.code == 2000 {
                            guard let result = response.result else { return }
                            emitter(.success(result))
                        } else {
                            print(response.code)
                            print(response.message)
                        }
                    case .failure(let error):
                        print(error)
                        emitter(.failure(error))
                    }
                }
            return Disposables.create()
        }
    }
    
    func deleteComment(type: CommentType, id: Int, commentId: Int)->Single<Bool> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        let urlString = baseURL + "\(type)/\(id)/comments/\(commentId)"
        
        return Single<Bool>.create { emitter in
            AF.request(urlString, method: .delete, interceptor: AuthManager())
                .responseDecodable(of: BaseResponse<DeleteCommentDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                        if response.code == 2000 {
                            emitter(.success(true))
                        } else {
                            print(response.message)
                            print(response.code)
                            emitter(.success(false))
                        }
                    case .failure(let error):
                        print(error)
                        emitter(.failure(AuthError.serverError))
                    }
                }
            
            return Disposables.create()
        }
    }
    
    func reportComment(commentId: Int)->Single<Int> {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else { return Single.error(AuthError.invalidURL)}
        let urlString = baseURL + "comments/\(commentId)/report"
        
        return Single<Int>.create { emitter in
            AF.request(urlString, method: .post, interceptor: AuthManager())
                .responseDecodable(of: BaseResponse<ReportCommentDTO>.self) { res in
                    switch res.result {
                    case .success(let response):
                        emitter(.success(response.code))
                    case .failure(let error):
                        print(error)
                        emitter(.failure(AuthError.serverError))
                    }
                }
            
            return Disposables.create()
        }
    }
    
}
