//
//  Markets(detail).swift
//  BitRise
//
//  Created by 권우석 on 3/10/25.
//

import Foundation

struct CoinDetail: Decodable {
    let id: String
    let symbol: String
    let name: String
    let image: String
    
    
    let currentPrice: Double
    let marketCap: Int64?
    let totalVolume: Int64?
    let high24h: Double?
    let low24h: Double?
    let priceChangePercentage24h: Double?
    let marketCapRank: Int?
    let lastUpdated: String
    let fullyDilutedValuation: Double?
    let sparklineIn7d: SparklineData?
    let ath: Double?
    let athChangePercentage: Double?
    let athDate: String?
    let atl: Double?
    let atlChangePercentage: Double?
    let atlDate: String?
    
    enum CodingKeys: String, CodingKey {
        case id, symbol, name, image
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case totalVolume = "total_volume"
        case high24h = "high_24h"
        case low24h = "low_24h"
        case priceChangePercentage24h = "price_change_percentage_24h"
        case marketCapRank = "market_cap_rank"
        case lastUpdated = "last_updated"
        case sparklineIn7d = "sparkline_in_7d"
        case fullyDilutedValuation = "fully_diluted_valuation"
        case ath
        case athChangePercentage = "ath_change_percentage"
        case athDate = "ath_date"
        case atl
        case atlChangePercentage = "atl_change_percentage"
        case atlDate = "atl_date"
    }
}

struct SparklineData: Decodable {
    let price: [Double]?
}
