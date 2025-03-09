//
//  ExchangeView.swift
//  BitRise
//
//  Created by 권우석 on 3/8/25.
//

import UIKit
import SnapKit

final class ExchangeView: BaseView {
    
    let headerBackgroundView = UIView()
    let coinNameLabel = UILabel()
    let currentPriceSortButton = UIButton()
    let changeRateSortButton = UIButton()
    let tradePriceSortButton = UIButton()
    let tableView = UITableView()
    
    override func configureHierarchy() {
        [headerBackgroundView, tableView].forEach { addSubview($0) }
        [coinNameLabel, currentPriceSortButton, changeRateSortButton, tradePriceSortButton].forEach { headerBackgroundView.addSubview($0) }
    }
    
    override func configureLayout() {
                
        headerBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(38)
        }
        
        let columnWidth = UIScreen.main.bounds.width / 4
        
        coinNameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.width.equalTo(columnWidth - 16)
        }
        
        currentPriceSortButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(coinNameLabel.snp.right)
            make.width.equalTo(columnWidth)
        }
        
        changeRateSortButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(currentPriceSortButton.snp.right)
            make.width.equalTo(columnWidth)
        }
        
        tradePriceSortButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(changeRateSortButton.snp.right)
            make.width.equalTo(columnWidth - 16)
            make.right.equalToSuperview().offset(-16)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerBackgroundView.snp.bottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    override func configureView() {
        headerBackgroundView.backgroundColor = .brWhite
        
        coinNameLabel.text = "코인"
        coinNameLabel.font = Constants.Font.bold_12
        coinNameLabel.textAlignment = .left
        
        currentPriceSortButton.setTitle("현재가", for: .normal)
        currentPriceSortButton.setTitleColor(.brBlack, for: .normal)
        currentPriceSortButton.titleLabel?.font = Constants.Font.bold_12
        currentPriceSortButton.titleLabel?.textAlignment = .right
        
        changeRateSortButton.setTitle("전일대비", for: .normal)
        changeRateSortButton.setTitleColor(.brBlack, for: .normal)
        changeRateSortButton.titleLabel?.font = Constants.Font.bold_12
        changeRateSortButton.titleLabel?.textAlignment = .right
        
        tradePriceSortButton.setTitle("거래대금", for: .normal)
        tradePriceSortButton.setTitleColor(.brBlack, for: .normal)
        tradePriceSortButton.titleLabel?.font = Constants.Font.bold_12
        tradePriceSortButton.titleLabel?.textAlignment = .right
        
        tableView.separatorStyle = .none
        tableView.rowHeight = 44
    }
}
