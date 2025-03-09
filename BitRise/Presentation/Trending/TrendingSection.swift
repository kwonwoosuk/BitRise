//
//  TrendingSection.swift
//  BitRise
//
//  Created by 권우석 on 3/10/25.
//

import Foundation

enum TrendingSection: Int, CaseIterable {
    case coins = 0
    case nfts = 1
    
    var title: String {
        switch self {
        case .coins:
            return "인기 검색어"
        case .nfts:
            return "인기 NFT"
        }
    }
}
