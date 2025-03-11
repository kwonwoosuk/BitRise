//
//  CoinDetailViewModel.swift
//  BitRise
//
//  Created by 권우석 on 3/11/25.
//

import Foundation
import RxSwift
import RxCocoa

final class CoinDetailViewModel: BaseViewModel {
    
    var disposeBag = DisposeBag()
    
    private let networkManager = NetworkManager.shared
    private let favoriteManager = FavoriteManager.shared
    
    private let coinDetailRelay = BehaviorRelay<CoinDetail?>(value: nil)
    private let errorRelay = PublishRelay<APIError>()
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let messageRelay = PublishRelay<String>()
    private let isFavoriteRelay = BehaviorRelay<Bool>(value: false)
    
    private var coinId: String = ""
    private var coinName: String = ""
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let viewWillAppear: PublishRelay<Void>
        let favoriteButtonTapped: PublishRelay<Void>
        let moreButtonTapped: PublishRelay<Void>
    }
    
    struct Output {
        let coinDetail: Driver<CoinDetail?>
        let isLoading: Driver<Bool>
        let error: Driver<APIError>
        let message: Driver<String>
        let isFavorite: Driver<Bool>
    }
    
    func configure(coinId: String, coinName: String) {
        self.coinId = coinId
        self.coinName = coinName
        updateFavoriteState()
    }
    
    func transform(input: Input) -> Output {
        
        input.viewDidLoad
            .do(onNext: { [weak self] in
                self?.loadingRelay.accept(true)
            })
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.networkManager.fetchCoinDetail(id: self.coinId)
                    .subscribe(
                        onSuccess: { result in
                            self.loadingRelay.accept(false)
                            
                            switch result {
                            case .success(let coins):
                                if let coin = coins.first {
                                    self.coinDetailRelay.accept(coin)
                                } else {
                                    self.messageRelay.accept("코인 정보를 찾을 수 없습니다.")
                                }
                            case .failure(let error):
                                self.errorRelay.accept(error)
                            }
                        },
                        onFailure: { error in
                            self.loadingRelay.accept(false)
                            if let apiError = error as? APIError {
                                self.errorRelay.accept(apiError)
                            } else {
                                self.errorRelay.accept(.unknownError)
                            }
                        }
                    )
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
        input.favoriteButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                let isAdded = self.favoriteManager.toggleFavorite(
                    coinId: self.coinId,
                    name: self.coinName
                )
                
                self.isFavoriteRelay.accept(isAdded)
                
                let message = isAdded ?
                    "\(self.coinName)이(가) 즐겨찾기에 추가되었습니다." :
                    "\(self.coinName)이(가) 즐겨찾기에서 제거되었습니다."
                
                self.messageRelay.accept(message)
            })
            .disposed(by: disposeBag)
        
        input.moreButtonTapped
            .subscribe(onNext: { [weak self] _ in
                self?.messageRelay.accept("준비중입니다.")
            })
            .disposed(by: disposeBag)
        
        input.viewWillAppear
            .subscribe(onNext: { [weak self] _ in
                self?.updateFavoriteState()
            })
            .disposed(by: disposeBag)
        
        return Output(
            coinDetail: coinDetailRelay.asDriver(),
            isLoading: loadingRelay.asDriver(),
            error: errorRelay.asDriver(onErrorJustReturn: .unknownError),
            message: messageRelay.asDriver(onErrorJustReturn: ""),
            isFavorite: isFavoriteRelay.asDriver()
        )
    }
    
    private func updateFavoriteState() {
        print("실행됨")
        let isFavorite = favoriteManager.isFavorite(coinId: coinId)
        isFavoriteRelay.accept(isFavorite)
    }
}
