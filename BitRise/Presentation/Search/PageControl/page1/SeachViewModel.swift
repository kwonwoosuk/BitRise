//
//  SeachViewModel.swift
//  BitRise
//
//  Created by 권우석 on 3/11/25.
//

import Foundation
import RxSwift
import RxCocoa

enum SearchTab: Int, CaseIterable {
    case coin = 0
    case nft = 1
    case exchange = 2
    
    var title: String {
        switch self {
        case .coin:
            return "코인"
        case .nft:
            return "NFT"
        case .exchange:
            return "거래소"
        }
    }
}

final class SearchViewModel: BaseViewModel {
        var disposeBag = DisposeBag()
        
        private let messageRelay = PublishRelay<String>()
        private let errorRelay = PublishRelay<APIError>()
        private let currentTabRelay = BehaviorRelay<SearchTab>(value: .coin)
        
        struct Input {
            let viewDidLoad: Observable<Void>
            let searchText: ControlProperty<String?>
            let searchButtonTapped: ControlEvent<Void> 
            let tabSelected: Observable<SearchTab>
        }
        
        struct Output {
            let message: Driver<String>
            let error: Driver<APIError>
            let currentTab: Driver<SearchTab>
        }
        
        func transform(input: Input) -> Output {
            input.tabSelected
                .subscribe(onNext: { [weak self] tab in
                    self?.currentTabRelay.accept(tab)
                })
                .disposed(by: disposeBag)
            
            
            return Output(
                message: messageRelay.asDriver(onErrorJustReturn: ""),
                error: errorRelay.asDriver(onErrorJustReturn: .unknownError),
                currentTab: currentTabRelay.asDriver()
            )
        }
    }
