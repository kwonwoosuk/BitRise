//
//  Trending.swift
//  BitRise
//
//  Created by 권우석 on 3/10/25.
//

import Foundation

struct CoinGeckoTrendingResponse: Decodable {
    let coins: [TrendingCoinItem]
    let nfts: [TrendingNFT]
}

// MARK: Coin
struct TrendingCoinItem: Decodable {
    let item: TrendingCoin
}

struct TrendingCoin: Decodable {
    let id: String               // 코인 ID
    let name: String             // 코인 이름
    let symbol: String           // 코인 통화 단위
    let thumb: String
    let data: CoinData?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case symbol
        case thumb
        case data
    }
}

// MARK: - 코인 데이터
struct CoinData: Decodable {
    let priceChangePercentage24h: PriceChange?  // 24시간 변동률
    
    enum CodingKeys: String, CodingKey {
        case priceChangePercentage24h = "price_change_percentage_24h"
    }
}

struct PriceChange: Decodable {
    let krw: Double?
}

// MARK: ===============================================================



// MARK: NFT
struct TrendingNFT: Decodable {
    let id: String?      // NFT ID
    let name: String     // NFT 토큰명
    let symbol: String?  // NFT 심볼
    let thumb: String    // NFT 썸네일 이미지 URL
    
    // 가격 데이터
    let data: NFTData?
    
    enum CodingKeys: String, CodingKey {
        case id, name, symbol, thumb
        case data
    }
}

// MARK: - NFT 데이터
struct NFTData: Decodable {
    let floorPrice: String?  // 24시간 중 NFT 최저가
    let floorPriceInUsd24hPercentageChange: String?
    
    enum CodingKeys: String, CodingKey {
        case floorPrice = "floor_price"
        case floorPriceInUsd24hPercentageChange = "floor_price_in_usd_24h_percentage_change"
    }
}
