//
//  BaseTableViewCell.swift
//  BitRise
//
//  Created by 권우석 on 3/8/25.
//

import UIKit

class BaseTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureHierarchy()
        configureLayout()
        configureView()
    }
    
    func configureHierarchy() {}
    
    func configureLayout() {}
    
    func configureView() {}
    
    @available(*, unavailable) 
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
