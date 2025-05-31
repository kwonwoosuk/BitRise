//
//  Search.swift
//  BitRise
//
//  Created by 권우석 on 3/10/25.
//

import Foundation

struct SearchResponse: Decodable {
    let coins: [SearchCoin]
    let nfts: [SearchNFT]
}


struct SearchCoin: Decodable {
    let id: String
    let name: String
    let symbol: String
    let marketCapRank: Int?
    let thumb: String
    let large: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, symbol, thumb, large
        case marketCapRank = "market_cap_rank"
    }
}

struct SearchNFT: Decodable {
    let id: String
    let name: String
    let symbol: String?
    let thumb: String
}
