//
//  Constants.swift
//  BitRise
//
//  Created by 권우석 on 3/8/25.
//

import UIKit

enum Constants {
    enum Font {
        static let regular_9 = UIFont.systemFont(ofSize: 9, weight: .regular)
        static let regular_12 = UIFont.systemFont(ofSize: 12, weight: .regular)
        static let bold_9 = UIFont.boldSystemFont(ofSize: 9)
        static let bold_12 = UIFont.boldSystemFont(ofSize: 12)
    }
    
    enum Icon {
        // 탭바 아이콘
        static let exchange = "chart.line.uptrend.xyaxis"
        static let coinInfo = "chart.bar.fill"
        static let star = "star"
        static let starFill = "star.fill"
        static let detail = "chevron.right"
        static let arrowLeft = "arrow.left"
        static let arrowUp = "arrowtriangle.up.fill"
        static let arrowDown = "arrowtriangle.down.fill"
        static let search = "magnifyingglass"
    }
}
