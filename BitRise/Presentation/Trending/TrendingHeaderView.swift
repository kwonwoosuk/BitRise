//
//  TrendingHeaderView.swift
//  BitRise
//
//  Created by 권우석 on 3/10/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class TrendingHeaderView: BaseView {
    
    let searchBar = UISearchBar()
    
    let disposeBag = DisposeBag()
    
    override func configureHierarchy() {
        addSubview(searchBar)
    }
    
    override func configureLayout() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-8)
            make.height.equalTo(44)
        }
    }
    
    override func configureView() {
        backgroundColor = .white
        //... wa
//        searchBar.searchBarStyle = .minimal
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default) // !!!! 드이어 !!!
        searchBar.backgroundColor = .white
        searchBar.setImage(UIImage(systemName: "magnifyingglass"), for: .search, state: .normal)
        searchBar.clipsToBounds = true
        
        let textField = searchBar.searchTextField
        textField.backgroundColor = .clear
        textField.layer.cornerRadius = 18
        textField.clipsToBounds = true
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .regular),
            .foregroundColor: UIColor.gray
        ]
        textField.attributedPlaceholder = NSAttributedString(
            string: "검색어를 입력해주세요.",
            attributes: placeholderAttributes
        )
    }
    
    func setupTapGesture(in viewController: UIViewController) {
        let tapGesture = UITapGestureRecognizer()
        viewController.view.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .bind(onNext: { [weak self] _ in
                self?.searchBar.resignFirstResponder()
            })
            .disposed(by: disposeBag)
    }
}
