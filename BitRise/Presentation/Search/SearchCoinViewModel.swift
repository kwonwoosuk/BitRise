//
//  SearchCoinViewModel.swift
//  BitRise
//
//  Created by 권우석 on 3/11/25.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchCoinViewModel: BaseViewModel {
    var disposeBag = DisposeBag()
    
    private let networkManager = NetworkManager.shared
    private let favoriteManager = FavoriteManager.shared
    
    private let coinsRelay = BehaviorRelay<[SearchCoin]>(value: [])
    private let errorRelay = PublishRelay<APIError>()
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let messageRelay = PublishRelay<String>()
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let searchQuery: Observable<String?> 
        let coinCellSelected: Observable<SearchCoin>
        let favoriteToggled: Observable<SearchCoin>
    }
    
    struct Output {
        let coins: Driver<[SearchCoin]>
        let isLoading: Driver<Bool>
        let error: Driver<APIError>
        let message: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        input.searchQuery
            .compactMap { $0 }
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .distinctUntilChanged()
            .do(onNext: { [weak self] _ in
                self?.loadingRelay.accept(true)
            })
            .flatMap { [weak self] query -> Observable<Result<SearchResponse, APIError>> in
                guard let self = self else { return .empty() }
                return self.networkManager.searchCoins(query: query).asObservable()
            }
            .subscribe(onNext: { [weak self] result in
                self?.loadingRelay.accept(false)
                
                switch result {
                case .success(let response):
                    self?.coinsRelay.accept(response.coins)
                case .failure(let error):
                    self?.errorRelay.accept(error)
                }
            })
            .disposed(by: disposeBag)
        
        input.favoriteToggled
            .subscribe(onNext: { [weak self] coin in
                let isAdded = self?.favoriteManager.toggleFavorite(
                    coinId: coin.id,
                    name: coin.name
                ) ?? false
                
                let message = isAdded ?
                    "\(coin.name)이 즐겨찾기 되었습니다" :
                    "\(coin.name)이 즐겨찾기에서 제거 되었습니다"
                
                self?.messageRelay.accept(message)
            })
            .disposed(by: disposeBag)
        
        favoriteManager.favoritesChanged
            .subscribe(onNext: { [weak self] _ in
                let currentCoins = self?.coinsRelay.value ?? []
                self?.coinsRelay.accept(currentCoins)
            })
            .disposed(by: disposeBag)
        
        return Output(
            coins: coinsRelay.asDriver(),
            isLoading: loadingRelay.asDriver(),
            error: errorRelay.asDriver(onErrorJustReturn: .unknownError),
            message: messageRelay.asDriver(onErrorJustReturn: "")
        )
    }
    
    func isFavorite(coinId: String) -> Bool {
        return favoriteManager.isFavorite(coinId: coinId)
    }
}
