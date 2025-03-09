//
//  NumberFormatterUtil.swift
//  BitRise
//
//  Created by 권우석 on 3/10/25.
//


import UIKit

struct NumberFormatterUtil {
    /// - 소수점 이하 3자리에서 반올림하여 소수점 2자리까지 표시
    static func formatPercentage(_ percentage: Double) -> String {
        return String(format: "%.2f", percentage)
    }
}
