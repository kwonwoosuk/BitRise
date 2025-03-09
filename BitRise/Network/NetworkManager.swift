//
//  NetworkManager.swift
//  BitRise
//
//  Created by 권우석 on 3/9/25.
//

import Foundation
import Alamofire
import RxSwift
import RxCocoa

enum APIError: Error {
    case invalidParameter // 400 두개 인것 같던데...
    case invalidURL // 404
    case callLimitExceeded // 429
    case unknownError
    
    var message: String {
        switch self {
        case .invalidParameter:
            return "유효하지 않은 파라미터입니다."
        case .invalidURL:
            return "잘못된 URL입니다."
        case .callLimitExceeded:
            return "호출 한도를 초과했습니다."
        case .unknownError:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}

final class NetworkManager {
    static let shared = NetworkManager()
    
    private init() { }

    func fetchAllKRWTickers() -> Single<[UpbitTicker]> {
        return Single.create { value in
            
            guard let url = URL(string: APIURL.upbitKRWURL) else {
                value(.failure(APIError.invalidURL))
                return Disposables.create()
            }
            
            AF.request(url, method: .get)
                .validate(statusCode: 200..<299)
                .responseDecodable(of: [UpbitTicker].self) { response in
                switch response.result {
                case .success(let data):
                    print("STATUS CODE \(response.response?.statusCode ?? 000)")
                    value(.success(data))
                case .failure(let error):
                    print("STATUS CODE \(response.response?.statusCode ?? 000)")
                    
                    let errorStatusCode = response.response?.statusCode
                    switch errorStatusCode {
                    case 400:
                        value(.failure(APIError.invalidParameter))
                    case 404:
                        value(.failure(APIError.invalidURL))
                    case 429:
                        value(.failure(APIError.callLimitExceeded))
                    default:
                        value(.failure(APIError.unknownError))
                    }
                }
            }
        
            return Disposables.create {
                print("NetworkManager Disposed")
            }
        }
    }
    
}
