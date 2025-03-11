//
//  SearchCoinView.swift
//  BitRise
//
//  Created by 권우석 on 3/11/25.
//

import UIKit
import SnapKit

final class SearchCoinView: BaseView {
    
    let tableView = UITableView()
    let emptyStateLabel = UILabel()
    let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    override func configureHierarchy() {
        [tableView, emptyStateLabel, loadingIndicator].forEach { addSubview($0) }
    }
    
    override func configureLayout() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        emptyStateLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    override func configureView() {
        backgroundColor = .white
        
        tableView.register(SearchCoinCell.self, forCellReuseIdentifier: SearchCoinCell.identifier)
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .onDrag
        
        emptyStateLabel.text = "검색어를 입력해주세요."
        emptyStateLabel.font = .systemFont(ofSize: 16)
        emptyStateLabel.textColor = .gray
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.isHidden = false
        
        loadingIndicator.hidesWhenStopped = true
    }
    
    func showLoading(_ isLoading: Bool) {
        if isLoading {
            loadingIndicator.startAnimating()
            tableView.isHidden = true
            emptyStateLabel.isHidden = true
        } else {
            loadingIndicator.stopAnimating()
            tableView.isHidden = false
        }
    }
    
    func showEmptyState(_ message: String, show: Bool) {
        emptyStateLabel.text = message
        emptyStateLabel.isHidden = !show
        tableView.isHidden = show
    }
}
