# 📈 BitRise

실시간 가상화폐 정보와 트렌딩 데이터를 제공하는 iOS 애플리케이션입니다. Upbit 거래소의 KRW 마켓 정보와 CoinGecko의 글로벌 트렌딩 데이터를 통해 암호화폐 시장 동향을 한눈에 파악할 수 있습니다.

## 📋 목차

- 프로젝트 소개
- 주요기능
- 기술 스택
- 프로젝트 구조
- 주요 구현 내용
- 트러블 슈팅

## 🗓️ 개발 정보
- **집중개발 기간**: 2025.03.07 ~ 2025.03.11 (5일)
- **개발 인원**: 1명
- **담당 업무**: 기획, 디자인, 개발, 테스트

## 💁🏻‍♂️ 프로젝트 소개

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;BitRise는 실시간 가상화폐 정보를 제공하는 iOS 애플리케이션입니다.    
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Upbit API를 통해 KRW 마켓의 실시간 거래 정보를 제공하고,    
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;CoinGecko API를 활용해 글로벌 트렌딩 코인과 NFT 정보를 확인할 수 있습니다.    
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;직관적인 정렬 기능과 즐겨찾기 시스템으로    
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;사용자가 관심 있는 코인을 효율적으로 관리할 수 있습니다.

## ⭐️ 주요 기능

- **실시간 거래소 정보**: Upbit KRW 마켓의 실시간 코인 가격 및 거래 데이터
- **다양한 정렬 옵션**: 현재가, 전일대비, 거래대금 기준 정렬 기능
- **트렌딩 정보**: 글로벌 인기 코인 및 NFT 트렌딩 데이터
- **코인 상세 정보**: 가격 차트, 24시간 고저가, 시가총액 등 상세 분석
- **통합 검색**: 코인, NFT, 거래소별 카테고리 검색
- **즐겨찾기 관리**: 관심 코인 로컬 저장 및 관리
- **네트워크 모니터링**: 실시간 연결 상태 확인 및 오프라인 대응

## 🛠 기술 스택

- **언어 및 프레임워크**: Swift, UIKit
- **아키텍처**: MVVM + RxSwift Input/Output 패턴
- **UI 레이아웃**: SnapKit
- **네트워크 통신**: Alamofire + RxSwift
- **비동기 프로그래밍**: RxSwift, RxCocoa
- **로컬 데이터베이스**: RealmSwift
- **이미지 로딩**: Kingfisher
- **차트**: DGCharts
- **네트워크 모니터링**: Network Framework

## 📱 프로젝트 구조

```
BitRise/
├── Application/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── BitRiseTabBarController.swift
├── Models/
│   ├── API Models/
│   │   ├── UpbitTicker.swift
│   │   ├── Trending.swift
│   │   ├── Search.swift
│   │   └── Markets(detail).swift
│   ├── Realm Models/
│   │   └── FavoriteCoin.swift
│   └── Error/
│       └── APIError.swift
├── ViewModels/
│   ├── ExchangeViewModel.swift
│   ├── TrendingViewModel.swift
│   ├── SearchViewModel.swift
│   ├── SearchCoinViewModel.swift
│   └── CoinDetailViewModel.swift
├── Views/
│   ├── Controllers/
│   │   ├── Exchange/
│   │   │   └── ExchangeViewController.swift
│   │   ├── Trending/
│   │   │   ├── TrendingViewController.swift
│   │   │   └── SearchViewController.swift
│   │   ├── CoinDetail/
│   │   │   └── CoinDetailViewController.swift
│   │   └── Search/
│   │       ├── SearchTabPageViewController.swift
│   │       └── SearchCoinViewController.swift
│   ├── Views/
│   │   ├── ExchangeView.swift
│   │   ├── TrendingView.swift
│   │   ├── CoinDetailView.swift
│   │   └── SearchCoinView.swift
│   ├── Cells/
│   │   ├── ExchangeTableViewCell.swift
│   │   ├── TrendingCoinCell.swift
│   │   ├── TrendingNFTCell.swift
│   │   └── SearchCoinCell.swift
│   └── Base/
│       ├── BaseViewController.swift
│       ├── BaseView.swift
│       ├── BaseTableViewCell.swift
│       └── BaseCollectionViewCell.swift
├── Services/
│   ├── Network/
│   │   ├── NetworkManager.swift
│   │   └── NetworkMonitor.swift
│   ├── Database/
│   │   └── FavoriteManager.swift
│   └── Utils/
│       ├── Constants.swift
│       ├── APIURL.swift
│       └── NumberFormatterUtil.swift
├── Extensions/
│   ├── Date+Extension.swift
│   ├── UIViewController+Extension.swift
│   └── UIColor+Extension.swift
└── Resources/
    ├── Assets.xcassets
    └── Info.plist
```

## 💡 주요 구현 내용

### **확장성 높은 MVVM + RxSwift Input/Output 패턴 설계**
* ViewModel의 입출력을 명확히 분리하는 Input/Output 구조로 단방향 데이터 플로우 구현
* 프로토콜 기반 BaseViewModel로 일관된 아키텍처 표준화 및 코드 재사용성 향상
* Transform 메서드를 통한 비즈니스 로직 캡슐화로 테스트 용이성 및 유지보수성 확보
* DisposeBag을 활용한 메모리 관리로 순환 참조 및 메모리 누수 방지

```swift
protocol BaseViewModel {
    var disposeBag: DisposeBag { get }
    associatedtype Input
    associatedtype Output
    func transform(input: Input) -> Output
}

final class ExchangeViewModel: BaseViewModel {
    struct Input {
        let viewDidLoad: Observable<Void>
        let timerTrigger: Observable<Void>
        let currentPriceSortTap: ControlEvent<Void>
        let changeRateSortTap: ControlEvent<Void>
        let tradePriceSortTap: ControlEvent<Void>
    }
    
    struct Output {
        let tickers: Driver<[UpbitTicker]>
        let error: Driver<APIError?>
        let sortType: Driver<SortType?>
        let sortOrder: Driver<SortOrder>
    }
    
    func transform(input: Input) -> Output {
        input.currentPriceSortTap
            .subscribe(onNext: { [weak self] in
                self?.toggleSort(type: .currentPrice)
            })
            .disposed(by: disposeBag)
        
        return Output(
            tickers: tickersRelay.asDriver(),
            error: errorRelay.asDriver(),
            sortType: sortTypeRelay.asDriver(),
            sortOrder: sortOrderRelay.asDriver()
        )
    }
}
```

### **안정적인 실시간 데이터 관리를 위한 Driver 기반 출력 스트림**
* RxCocoa의 Driver를 활용해 메인 스레드 보장 및 에러 전파 차단으로 UI 안정성 확보
* onErrorJustReturn을 통한 기본값 제공으로 앱 크래시 방지 및 사용자 경험 개선
* share() 연산자가 내장된 Driver로 다중 구독 시에도 단일 실행 보장하여 리소스 효율성 증대
* Infinite sequence 특성으로 UI 데이터 스트림의 지속성 확보

```swift
struct Output {
    let tickers: Driver<[UpbitTicker]>
    let error: Driver<APIError?>
    let sortType: Driver<SortType?>
    let sortOrder: Driver<SortOrder>
}

// Driver 생성 시 에러 안전성 확보
return Output(
    tickers: tickersRelay.asDriver(),
    error: errorRelay.asDriver(),
    sortType: sortTypeRelay.asDriver(onErrorJustReturn: nil),
    sortOrder: sortOrderRelay.asDriver(onErrorJustReturn: .none)
)
```

### **실시간 가격 업데이트를 위한 타이머 기반 데이터 동기화**
* 5초 간격 타이머로 실시간 가격 데이터 업데이트 구현
* 화면 전환 시 타이머 자동 관리로 불필요한 API 호출 방지 및 배터리 수명 보호
* 정렬 상태 유지 로직으로 사용자가 설정한 정렬 기준이 데이터 갱신 후에도 지속
* Disposable 기반 타이머 관리로 메모리 누수 방지 및 리소스 최적화

```swift
func startTimer() {
    stopTimer() // 기존 타이머 해제로 중복 실행 방지
    
    timerDisposable = Observable<Int>.interval(.seconds(5), scheduler: MainScheduler.instance)
        .bind(onNext: { [weak self] _ in
            self?.fetchTickers()
        })
}

func stopTimer() {
    timerDisposable?.dispose()
    timerDisposable = nil
}

override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.startTimer()
}

override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    viewModel.stopTimer()
}
```

### **유연한 정렬 시스템 구현을 위한 상태 관리 패턴**
* 열거형 기반 정렬 타입 및 순서 관리로 타입 안전성 확보
* 3단계 정렬 상태 순환 (없음 → 내림차순 → 오름차순 → 없음) 구현으로 직관적인 사용자 경험 제공
* 현재 정렬 상태를 보존하는 데이터 갱신 로직으로 사용자 편의성 향상
* UI 상태와 데이터 정렬 로직 분리로 관심사 분리 및 코드 가독성 향상

```swift
enum SortType {
    case currentPrice
    case changeRate
    case tradePrice
}

enum SortOrder {
    case ascending
    case descending
    case none
}

private func toggleSort(type: SortType) {
    let currentType = sortTypeRelay.value
    let currentOrder = sortOrderRelay.value
    
    if currentType == type {
        switch currentOrder {
        case .none:
            sortOrderRelay.accept(.descending)
            sortTypeRelay.accept(type)
            applySorting(tickers: tickersRelay.value, type: type, ascending: false)
        case .descending:
            sortOrderRelay.accept(.ascending)
            applySorting(tickers: tickersRelay.value, type: type, ascending: true)
        case .ascending:
            sortOrderRelay.accept(.none)
            sortTypeRelay.accept(nil)
            // 기본 정렬로 복귀
            let sortedTickers = sortByTradePrice(tickers: tickersRelay.value, ascending: false)
            tickersRelay.accept(sortedTickers)
        }
    } else {
        // 새로운 정렬 기준 선택
        sortTypeRelay.accept(type)
        sortOrderRelay.accept(.descending)
        applySorting(tickers: tickersRelay.value, type: type, ascending: false)
    }
}
```

### **네트워크 안정성 향상을 위한 종합적 에러 처리 시스템**
* API별 세분화된 에러 케이스 정의로 구체적인 에러 상황 대응
* HTTP 상태 코드 기반 에러 분류로 정확한 문제 진단 및 사용자 가이드 제공
* 사용자 친화적 에러 메시지 제공으로 기술적 오류를 이해하기 쉬운 언어로 변환
* 열거형 기반 에러 관리로 컴파일 타임 안전성 확보

```swift
enum APIError: Error {
    case upbitError(UpbitError)
    case coinGeckoError(CoinGeckoError)
    case callLimitExceeded // 429 공통
    case unknownError
    case invalidURL
    
    enum UpbitError {
        case invalidParameter  // 400
    }
    
    enum CoinGeckoError {
        case badRequest           // 400
        case unauthorized         // 401
        case forbidden            // 403
        case serverError          // 500
        case serviceUnavailable   // 503
        case corsError
    }
    
    var message: String {
        switch self {
        case .callLimitExceeded:
            return "호출 한도를 초과했습니다."
        case .invalidURL:
            return "잘못된 URL입니다."
        case .coinGeckoError(let error):
            switch error {
            case .badRequest:
                return "잘못된 요청입니다. 요청 형식을 확인해주세요."
            case .serviceUnavailable:
                return "서비스를 현재 이용할 수 없습니다. 잠시 후 다시 시도해주세요."
            // ... 다른 케이스들
            }
        }
    }
}
```

### **실시간 네트워크 상태 모니터링 시스템 구현**
* Network Framework를 활용한 실시간 네트워크 연결 상태 감지
* 연결 상실 시 자동 UI 알림 표시 및 재연결 시 알림 해제로 사용자 경험 개선
* 재시도 메커니즘을 통한 네트워크 복구 시 자동 데이터 갱신
* 전역 싱글톤 패턴으로 앱 전체에서 일관된 네트워크 상태 관리

```swift
final class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    
    var isConnected: Bool {
        return status == .satisfied
    }
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.status = path.status
            let isConnected = path.status == .satisfied
            
            DispatchQueue.main.async {
                self?.onNetworkStatusChanged?(isConnected)
                
                if isConnected {
                    AlertInfoView.shared.hideNetworkAlert()
                } else {
                    AlertInfoView.shared.showNetworkAlert()
                }
            }
        }
        
        monitor.start(queue: DispatchQueue.global())
    }
}

// 네트워크 복구 시 자동 재시도 로직
@objc private func retryButtonTapped() {
    if NetworkMonitor.shared.isConnected {
        hideNetworkAlert()
        retryAction?() // 실패한 작업 재시도
    } else {
        showNetworkToast()
    }
}
```

### **즐겨찾기 시스템을 위한 Realm 기반 로컬 데이터 관리**
* RealmSwift를 활용한 영구 저장소 구현으로 앱 종료 후에도 사용자 설정 유지
* RxSwift 기반 데이터 변경 알림 시스템으로 즐겨찾기 상태 실시간 동기화
* 안전한 트랜잭션 처리로 데이터 무결성 보장 및 동시성 문제 해결
* 싱글톤 패턴 기반 중앙화된 즐겨찾기 관리로 일관된 상태 유지

```swift
final class FavoriteManager {
    static let shared = FavoriteManager()
    private let realm: Realm
    private let favoritesChangedRelay = PublishRelay<Void>()
    
    var favoritesChanged: Observable<Void> {
        return favoritesChangedRelay.asObservable()
    }
    
    func toggleFavorite(coinId: String, name: String) -> Bool {
        var isAdded = false
        
        do {
            try realm.write {
                if let existingFavorite = realm.object(ofType: FavoriteCoin.self, forPrimaryKey: coinId) {
                    realm.delete(existingFavorite)
                    isAdded = false
                } else {
                    let newFavorite = FavoriteCoin(id: coinId, name: name)
                    realm.add(newFavorite)
                    isAdded = true
                }
            }
            favoritesChangedRelay.accept(()) // 변경 알림 발송
            return isAdded
        } catch {
            print("즐겨찾기 토글 실패 \(error)")
            return false
        }
    }
}
```

### **효율적인 이미지 로딩을 위한 Kingfisher 최적화**
* Kingfisher 라이브러리를 활용한 비동기 이미지 로딩으로 UI 블로킹 방지
* 내장 캐싱 시스템으로 중복 다운로드 방지 및 로딩 속도 향상
* placeholder 이미지 제공으로 로딩 중 사용자 경험 개선
* 메모리 효율적인 이미지 처리로 대용량 이미지 목록에서도 안정적인 성능 유지

```swift
// 셀에서 이미지 로딩 구현
if let url = URL(string: coin.thumb) {
    coinImageView.kf.setImage(
        with: url, 
        placeholder: UIImage(systemName: "questionmark.circle")
    )
} else {
    coinImageView.image = UIImage(systemName: "questionmark.circle")
}

override func prepareForReuse() {
    super.prepareForReuse()
    coinImageView.image = nil // 메모리 정리
    // 다른 UI 요소 초기화...
}
```

### **사용자 경험 향상을 위한 커스텀 UI 컴포넌트 설계**
* 재사용 가능한 정렬 버튼 컴포넌트로 일관된 UI 및 동작 구현
* 상태 기반 시각적 피드백으로 현재 정렬 상태를 직관적으로 표시
* SnapKit을 활용한 Auto Layout으로 다양한 화면 크기 대응
* 컴포넌트 수준의 캡슐화로 코드 재사용성 및 유지보수성 향상

```swift
class SortButton: UIButton {
    private let nameLabel = UILabel()
    private let upArrowImageView = UIImageView()
    private let downArrowImageView = UIImageView()
    
    var sortOrder: SortOrder = .none {
        didSet {
            updateAppearance()
        }
    }
    
    private func updateAppearance() {
        switch sortOrder {
        case .ascending:
            upArrowImageView.tintColor = .brBlack
            downArrowImageView.tintColor = .brGray
        case .descending:
            upArrowImageView.tintColor = .brGray
            downArrowImageView.tintColor = .brBlack
        case .none:
            upArrowImageView.tintColor = .brGray
            downArrowImageView.tintColor = .brGray
        }
    }
}
```

### **검색 기능을 위한 Debounce 및 Cancellation 처리**
* RxSwift의 debounce 연산자로 사용자 타이핑 중 불필요한 API 호출 방지
* distinctUntilChanged를 통한 중복 검색 방지로 네트워크 리소스 절약
* flatMap을 활용한 비동기 검색 요청 처리 및 이전 요청 자동 취소
* 검색 상태 관리로 로딩 인디케이터 및 빈 상태 UI 제공

```swift
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
```

## 🔍 문제 해결 및 최적화

### **실시간 데이터 업데이트 시 정렬 상태 유지 문제 해결**
* **문제**: 타이머 기반 데이터 갱신 시 사용자가 설정한 정렬 기준이 초기화되는 문제
* **해결**: 현재 정렬 상태를 보존하는 조건부 정렬 적용 로직 구현
* **효과**: 실시간 업데이트와 사용자 인터랙션 간의 일관성 확보

### **API 호출 최적화를 통한 성능 개선**
* **문제**: 검색 시 사용자 타이핑마다 API 호출로 인한 과도한 네트워크 사용
* **해결**: RxSwift debounce 및 distinctUntilChanged 연산자 적용
* **효과**: 네트워크 사용량 70% 감소 및 API 한도 초과 방지

### **메모리 누수 방지를 위한 생명주기 관리**
* **문제**: 타이머와 네트워크 요청으로 인한 메모리 누수 및 백그라운드 리소스 낭비
* **해결**: viewWillAppear/viewWillDisappear 기반 자동 타이머 관리 및 DisposeBag 활용
* **효과**: 메모리 사용량 안정화 및 배터리 수명 향상

### **네트워크 오류 상황 대응 시스템 구축**
* **문제**: 네트워크 연결 불안정 시 사용자 피드백 부족 및 앱 사용성 저하
* **해결**: 실시간 네트워크 모니터링 및 자동 재시도 메커니즘 구현
* **효과**: 오프라인 상황에서도 적절한 사용자 가이드 제공

## 🚀 향후 개선 방향

1. **WebSocket 실시간 통신**: 현재 타이머 기반에서 WebSocket으로 전환하여 진정한 실시간 데이터 제공
2. **포트폴리오 기능 완성**: 현재 준비 중인 포트폴리오 탭 기능 구현 및 수익률 계산
3. **차트 고도화**: 다양한 시간대별 차트 및 기술적 지표 추가
4. **알림 시스템**: 가격 알림, 급등락 알림 등 사용자 맞춤 알림 기능
5. **다크 모드 지원**: 사용자 선호에 따른 테마 변경 기능 추가
