//
//  TrendingViewModel.swift
//  BitRise
//
//  Created by 권우석 on 3/10/25.
//

import Foundation
import RxSwift
import RxCocoa

final class TrendingViewModel: BaseViewModel {
    
    var disposeBag = DisposeBag()
    
    private let networkManager = NetworkManager.shared
    private let trendingCoinsRelay = BehaviorRelay<[TrendingCoin]>(value: [])
    private let trendingNFTsRelay = BehaviorRelay<[TrendingNFT]>(value: [])
    private let timestampRelay = BehaviorRelay<Date?>(value: nil)
    private let errorRelay = PublishRelay<APIError>()
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let pushToSearchRelay = PublishRelay<String>()
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let viewWillAppear: Observable<Void>
        let searchBarReturnKey: Observable<String>
    }
    
    struct Output {
        let trendingCoins: Driver<[TrendingCoin]>
        let trendingNFTs: Driver<[TrendingNFT]>
        let timestamp: Driver<Date?>
        let isLoading: Driver<Bool>
        let error: Driver<APIError>
        let pushToSearch: Driver<String>
        
    }
    
    init() {
        print("⭐️ TrendingViewModel INIT ⭐️")
    }
    
    deinit {
        print("⭐️ TrendingViewModel DEINIT ⭐️")
    }
    
    func transform(input: Input) -> Output {
        
        Observable.merge(
            input.viewDidLoad,
            input.viewWillAppear
        )
        .do(onNext: { [weak self] _ in
            self?.loadingRelay.accept(true)
        })
        .flatMapLatest { [weak self] _ -> Observable<Void> in
            guard let self = self else { return .empty() }
            return self.fetchTrendingData()
        }
        .subscribe()
        .disposed(by: disposeBag)
        
        input.searchBarReturnKey
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .subscribe(onNext: { [weak self] query in
                self?.pushToSearchRelay.accept(query)
            })
            .disposed(by: disposeBag)
        
        return Output(
            trendingCoins: trendingCoinsRelay.asDriver(),
            trendingNFTs: trendingNFTsRelay.asDriver(),
            timestamp: timestampRelay.asDriver(),
            isLoading: loadingRelay.asDriver(),
            error: errorRelay.asDriver(onErrorJustReturn: .unknownError),
            pushToSearch: pushToSearchRelay.asDriver(onErrorJustReturn: "")
        )
    }
    
    private func fetchTrendingData() -> Observable<Void> {
        return Observable<Void>.create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            let disposable = self.networkManager.fetchTrendingData()
                .subscribe(
                    onSuccess: { result in
                        self.processTrendingData(result.coins, result.nfts)
                        self.timestampRelay.accept(result.timestamp)
                        self.loadingRelay.accept(false)
                        observer.onNext(())
                        observer.onCompleted()
                    },
                    onFailure: { error in
                        self.loadingRelay.accept(false)
                        if let apiError = error as? APIError {
                            self.errorRelay.accept(apiError)
                        } else {
                            self.errorRelay.accept(.unknownError)
                        }
                        observer.onNext(())
                        observer.onCompleted()
                    }
                )
            
            return Disposables.create {
                disposable.dispose()
            }
        }
    }
    
    private func processTrendingData(_ coins: [TrendingCoin], _ nfts: [TrendingNFT]) {
        let rankCoin = Array(coins.prefix(14))
        trendingCoinsRelay.accept(rankCoin)
        
        let rankNFT = Array(nfts.prefix(7))
        trendingNFTsRelay.accept(rankNFT)
    }
    
    func getCurrentTrendingCoins() -> [TrendingCoin] {
        return trendingCoinsRelay.value
    }
    
    func getCurrentTrendingNFTs() -> [TrendingNFT] {
        return trendingNFTsRelay.value
    }
    
    func getCurrentTimestamp() -> Date? {
        return timestampRelay.value
    }
}
