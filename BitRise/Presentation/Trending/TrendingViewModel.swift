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
        
    }
    
    init() {
        print("⭐️ TrendingViewModel INIT ⭐️")
    }
    
    deinit {
        print("⭐️ TrendingViewModel DEINIT ⭐️")
    }

    func transform(input: Input) -> Output {
//        let searchresult = BehaviorSubject(value: ) 상세화면 객체 만들고 생성
        
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
            .map { $0}
            .asDriver(onErrorJustReturn: "")
            .drive(with: self) { owner, value in
             // 뷰 넘기기
            }
            .disposed(by: disposeBag)
        
        return Output(
            trendingCoins: trendingCoinsRelay.asDriver(),
            trendingNFTs: trendingNFTsRelay.asDriver(),
            timestamp: timestampRelay.asDriver(),
            isLoading: loadingRelay.asDriver(),
            error: errorRelay.asDriver(onErrorJustReturn: .unknownError)
            
        )
    }
    
    private func fetchTrendingData() -> Observable<Void> {
        return networkManager.fetchTrendingData()
            .asObservable()
            .do(onNext: { [weak self] result in
                self?.processTrendingData(result.coins, result.nfts)
                self?.timestampRelay.accept(result.timestamp)
                self?.loadingRelay.accept(false)
            }, onError: { [weak self] error in
                self?.loadingRelay.accept(false)
                if let apiError = error as? APIError {
                    self?.errorRelay.accept(apiError)
                } else {
                    self?.errorRelay.accept(.unknownError)
                }
            })
            .map { _ in () }
            .catchAndReturn(())
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
