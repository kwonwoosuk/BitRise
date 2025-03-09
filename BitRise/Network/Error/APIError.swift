//
//  APIError.swift
//  BitRise
//
//  Created by 권우석 on 3/10/25.
//

import Foundation

enum APIError: Error {
    case upbitError(UpbitError)
    case coinGeckoError(CoinGeckoError)
    case callLimitExceeded // 429 공통
    case unknownError //  공통
    case invalidURL        // 404 공통 url거를때 사용
    
    // Upbit API 에러
    enum UpbitError {
        case invalidParameter  // 400
        
    }
    
    // CoinGecko API 에러
    enum CoinGeckoError {
        case badRequest           // 400: 잘못된 요청
        case unauthorized         // 401: 인증 실패
        case forbidden            // 403: 접근 거부
        case serverError          // 500: 서버 내부 오류
        case serviceUnavailable   // 503: 서비스 사용 불가
        case accessDenied         // 1020: CDN 방화벽 규칙 위반
        case apiKeyMissing        // 10002: API 키 누락
        case corsError            // CORS 관련 오류?
    }
    
    var message: String {
        switch self {
        // Upbit 에러 문서 정의
        case .unknownError:
            return "알 수 없는 오류가 발생했습니다."
        case .callLimitExceeded:
            return "호출 한도를 초과했습니다."
        case .invalidURL:
            return "잘못된 URL입니다."
            
            
        case .upbitError(let error):
            switch error {
            case .invalidParameter:
                return "유효하지 않은 파라미터입니다."
            }
            
        // CoinGecko 에러 문서 정의
        case .coinGeckoError(let error):
            switch error {
            case .badRequest:
                return "잘못된 요청입니다. 요청 형식을 확인해주세요."
            case .unauthorized:
                return "인증에 실패했습니다. 인증 정보를 확인해주세요."
            case .forbidden:
                return "접근이 차단되었습니다."
            case .serverError:
                return "서버 내부 오류가 발생했습니다."
            case .serviceUnavailable:
                return "서비스를 현재 이용할 수 없습니다. 잠시 후 다시 시도해주세요."
            case .accessDenied:
                return "CDN 방화벽에 의해 접근이 차단되었습니다."
            case .apiKeyMissing:
                return "API 키가 누락되었습니다."
            case .corsError:
                return "CORS 설정 오류가 발생했습니다."
            }
            
        }
        
    }
}
