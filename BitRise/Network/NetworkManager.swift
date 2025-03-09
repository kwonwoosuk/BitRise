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
                            value(.failure(APIError.upbitError(.invalidParameter)))
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
                print("Disposed")
            }
        }
    }
    
    func fetchTrendingData() -> Single<(coins: [TrendingCoin], nfts: [TrendingNFT], timestamp: Date)> {
        return Single.create {  value in
            
            guard let url = URL(string: APIURL.coinGeckoTrendingURL) else {
                value(.failure(APIError.invalidURL))
                return Disposables.create()
            }
            
            AF.request(url, method: .get)
                .validate(statusCode: 200..<299)
                .responseDecodable(of: CoinGeckoTrendingResponse.self) { response in
                    switch response.result {
                    case .success(let data):
                        print("STATUS CODE \(response.response?.statusCode ?? 000)")
                        
                        // 15개 던져주는데 하나 자릅시다 0등 부터 14등까지 (1~15등이겠죠?)
                        let trendingCoins = data.coins.map { $0.item }
                        let rankCoin = Array(trendingCoins.prefix(14))
                        
                        let rankNFT = Array(data.nfts.prefix(7))
                        //                            let a = data.nfts
                        
                        
                        let timestamp = Date()
                        
                        value(.success((coins: rankCoin, nfts: rankNFT, timestamp: timestamp)))
                        
                    case .failure(let error):
                        print("FAILURE \(error)")
                        print("STATUS CODE \(response.response?.statusCode ?? 000)")
                        
                        let errorStatusCode = response.response?.statusCode
                        switch errorStatusCode {
                        case 400:
                            value(.failure(APIError.coinGeckoError(.badRequest)))
                        case 401:
                            value(.failure(APIError.coinGeckoError(.unauthorized)))
                        case 403:
                            value(.failure(APIError.coinGeckoError(.forbidden)))
                        case 429:
                            value(.failure(APIError.callLimitExceeded))
                        case 500:
                            value(.failure(APIError.coinGeckoError(.serverError)))
                        case 503:
                            value(.failure(APIError.coinGeckoError(.serviceUnavailable)))
                        case 1020:
                            value(.failure(APIError.coinGeckoError(.accessDenied)))
                        case 10002:
                            value(.failure(APIError.coinGeckoError(.apiKeyMissing)))
                        default:
                            if let errorDescription = error.errorDescription,
                               errorDescription.contains("CORS") {
                                value(.failure(APIError.coinGeckoError(.corsError)))
                            } else {
                                value(.failure(APIError.unknownError))
                            }
                        }
                    }
                }
            
            return Disposables.create {
                print("Disposed trending request")
            }
        }
    }
    
    
}
