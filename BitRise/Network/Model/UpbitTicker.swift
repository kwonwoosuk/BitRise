//
//  UpbitTicker.swift
//  BitRise
//
//  Created by 권우석 on 3/9/25.
//

import Foundation
// quote_currencies  KRW 한가지만사용

struct UpbitTicker: Decodable {
    let market: String // 코인 이름
    let change: String // RISE, FALL, EVEN
    let tradePrice: Double // 현재가
    let signedChangeRate: Double // 전일대비 퍼센트 -3.72%
    let signedChangePrice: Double // 전일대비 가격 -154
    let accTradePrice: Double // 거래대금 UTC 0 시 기준

    enum CodingKeys: String, CodingKey {
        case market
        case change
        case tradePrice = "trade_price"
        case signedChangeRate = "signed_change_rate"
        case signedChangePrice = "signed_change_price"
        case accTradePrice = "acc_trade_price"
    }
}

