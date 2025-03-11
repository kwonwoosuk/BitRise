//
//  Date+Extension.swift
//  BitRise
//
//  Created by 권우석 on 3/11/25.
//

import Foundation


extension String {
    
    func toFormattedDate() -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = isoFormatter.date(from: self) else {
            return "날짜 정보 없음"
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yy년 MM월 dd일"
        
        return outputFormatter.string(from: date)
    }
    
    func formattedUpdateDate() -> String {
            let isoFormatter = ISO8601DateFormatter()
            if let date = isoFormatter.date(from: self) {
                let formatter = DateFormatter()
                formatter.dateFormat = "M/d HH:mm:ss"
                return formatter.string(from: date)
            }
            return self
        }
    
}

extension Date {
    func toFormattedUpdateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d HH:mm:ss"
        return "\(formatter.string(from: self)) 업데이트"
    }
}
