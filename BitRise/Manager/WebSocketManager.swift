//
//  WebSocketManager.swift
//  BitRise
//
//  Created by 권우석 on 6/19/25.
//

import Foundation
import RxSwift
import RxCocoa

struct TickerResponseDTO: Decodable {
    let code: String
    let tradePrice: Double
    let change: String
    let signedChangePrice: Double
    let signedChangeRate: Double
    let accTradePrice: Double
    
    enum CodingKeys: String, CodingKey {
        
        case code = "cd"
        case tradePrice = "tp"
        case change = "c"
        case signedChangePrice = "scp"
        case signedChangeRate = "scr"
        case accTradePrice = "atp"
        
        case codeDefault = "code"
        case tradePriceDefault = "trade_price"
        case changeDefault = "change"
        case signedChangePriceDefault = "signed_change_price"
        case signedChangeRateDefault = "signed_change_rate"
        case accTradePriceDefault = "acc_trade_price"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let cd = try? container.decode(String.self, forKey: .code) {
            code = cd
            tradePrice = try container.decode(Double.self, forKey: .tradePrice)
            change = try container.decode(String.self, forKey: .change)
            signedChangePrice = try container.decode(Double.self, forKey: .signedChangePrice)
            signedChangeRate = try container.decode(Double.self, forKey: .signedChangeRate)
            accTradePrice = try container.decode(Double.self, forKey: .accTradePrice)
        } else {
            code = try container.decode(String.self, forKey: .codeDefault)
            tradePrice = try container.decode(Double.self, forKey: .tradePriceDefault)
            change = try container.decode(String.self, forKey: .changeDefault)
            signedChangePrice = try container.decode(Double.self, forKey: .signedChangePriceDefault)
            signedChangeRate = try container.decode(Double.self, forKey: .signedChangeRateDefault)
            accTradePrice = try container.decode(Double.self, forKey: .accTradePriceDefault)
        }
    }
    
    func toUpbitTicker() -> UpbitTicker {
        return UpbitTicker(
            market: code,
            change: change,
            tradePrice: tradePrice,
            signedChangeRate: signedChangeRate,
            signedChangePrice: signedChangePrice,
            accTradePrice: accTradePrice
        )
    }
}

final class WebSocketManager {
    static let shared = WebSocketManager()
    
    private var webSocketTask: URLSessionWebSocketTask?
    private let session = URLSession(configuration: .default)
    
    private let tickerSubject = PublishSubject<UpbitTicker>()
    private let connectionSubject = BehaviorSubject<Bool>(value: false)
    private var retryCount = 0
    private let maxRetryCount = 3
    
    var tickerObservable: Observable<UpbitTicker> {
        return tickerSubject.asObservable()
    }
    
    var isConnected: Observable<Bool> {
        return connectionSubject.asObservable()
    }
    
    private init() {}
    
    func connectIfNeeded() {
        // 이미 연결 중이거나 실행 중이면 새로 연결하지 않음
        if webSocketTask?.state == .running {
            print("WebSocket already running, skipping connection")
            return
        }
        
        connect()
    }
    
    func connect() {
        disconnect()
        
        guard let url = URL(string: "wss://api.upbit.com/websocket/v1") else {
            print("Invalid WebSocket URL")
            connectionSubject.onNext(false)
            return
        }
        
        print("Connecting to WebSocket...")
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        receiveMessages()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.sendSubscriptionMessage()
        }
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        retryCount = 0
        isFirstDataReceived = false
        connectionSubject.onNext(false)
        print("WebSocket disconnected")
    }
    
    private func sendSubscriptionMessage() {
        let message: [Any] = [
            ["ticket": "BitRise"],
            [
                "type": "ticker",
                "codes": getAllKRWMarkets(),
                "isOnlyRealtime": true
            ],
            ["format": "SIMPLE"]
        ]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: message)
            let socketMessage = URLSessionWebSocketTask.Message.data(data)
            
            webSocketTask?.send(socketMessage) { [weak self] error in
                if let error = error {
                    print("WebSocket send error: \(error)")
                    self?.connectionSubject.onNext(false)
                    self?.handleConnectionFailure()
                } else {
                    print("WebSocket subscription message sent successfully")
                    self?.connectionSubject.onNext(true)
                    self?.retryCount = 0
                }
            }
        } catch {
            print("Failed to serialize message: \(error)")
            connectionSubject.onNext(false)
            handleConnectionFailure()
        }
    }
    
    private func receiveMessages() {
        guard webSocketTask != nil else {
            print("WebSocket task is nil, stopping receive")
            return
        }
        
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    self?.handleData(data)
                case .string(let string):
                    print("Received string: \(string)")
                @unknown default:
                    break
                }
                // 성공시 다음 메시지 대기
                self?.receiveMessages()
                
            case .failure(let error):
                print("WebSocket receive error: \(error)")
                self?.connectionSubject.onNext(false)
                
                // 연결이 끊어진 상태에서만 재연결 시도
                if self?.webSocketTask?.state == .completed || self?.webSocketTask?.state == .canceling {
                    self?.handleConnectionFailure()
                }
            }
        }
    }
    
    private func handleConnectionFailure() {
        // 이미 재연결 중이면 무시
        guard webSocketTask?.state != .running else {
            print("WebSocket is still running, skipping reconnection")
            return
        }
        
        retryCount += 1
        
        if retryCount <= maxRetryCount {
            print("Connection failed. Retry \(retryCount)/\(maxRetryCount) in 5 seconds...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {  // 재연결 간격 늘림
                // 재연결 시도할 때 다시 한번 체크
                if self.webSocketTask?.state != .running {
                    self.connect()
                }
            }
        } else {
            print("Max retry attempts reached. Stopping reconnection.")
            connectionSubject.onNext(false)
            retryCount = 0  // 카운트 리셋하여 나중에 수동 재연결 가능하도록
        }
    }
    
    private var isFirstDataReceived = false
    
    private func handleData(_ data: Data) {
        do {
            let tickerDTO = try JSONDecoder().decode(TickerResponseDTO.self, from: data)
            let ticker = tickerDTO.toUpbitTicker()
            
            // 첫 번째 데이터 수신시에만 로그 출력
            if !isFirstDataReceived {
                print("🎉 First data received successfully: \(ticker.market)")
                isFirstDataReceived = true
            }
            
            tickerSubject.onNext(ticker)
        } catch {
            print("Failed to decode ticker: \(error)")
            // 디버깅을 위해 raw data도 출력
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw data: \(jsonString.prefix(200))...")  // 처음 200자만
            }
        }
    }
    
    func reconnect() {
        retryCount = 0  // 수동 재연결시 카운트 리셋
        isFirstDataReceived = false  // 데이터 수신 플래그 리셋
        connect()
    }
    
    private func getAllKRWMarkets() -> [String] {
        return [
            "KRW-BTC", "KRW-ETH", "KRW-NEO", "KRW-MTL", "KRW-LTC", "KRW-XRP", "KRW-ETC", "KRW-OMG",
            "KRW-SNT", "KRW-WAVES", "KRW-XEM", "KRW-QTUM", "KRW-LSK", "KRW-STEEM", "KRW-XLM", "KRW-ARDR",
            "KRW-ARK", "KRW-STORJ", "KRW-GRS", "KRW-REP", "KRW-ADA", "KRW-SBD", "KRW-POWR", "KRW-BTG",
            "KRW-ICX", "KRW-EOS", "KRW-TRX", "KRW-SC", "KRW-ONT", "KRW-ZIL", "KRW-POLY", "KRW-ZRX",
            "KRW-LOOM", "KRW-BCH", "KRW-BAT", "KRW-IOST", "KRW-RFR", "KRW-CVC", "KRW-IQ", "KRW-IOTA",
            "KRW-MFT", "KRW-ONG", "KRW-GAS", "KRW-UPP", "KRW-ELF", "KRW-KNC", "KRW-BSV", "KRW-THETA",
            "KRW-EDR", "KRW-QKC", "KRW-BTT", "KRW-MOC", "KRW-ENJ", "KRW-TFUEL", "KRW-MANA", "KRW-ANKR",
            "KRW-AERGO", "KRW-ATOM", "KRW-TT", "KRW-CRE", "KRW-MBL", "KRW-WAXP", "KRW-HBAR", "KRW-MED",
            "KRW-MLK", "KRW-STPT", "KRW-ORBS", "KRW-VET", "KRW-CHZ", "KRW-STMX", "KRW-DKA", "KRW-HIVE",
            "KRW-KAVA", "KRW-AHT", "KRW-LINK", "KRW-XTZ", "KRW-BORA", "KRW-JST", "KRW-CRO", "KRW-TON",
            "KRW-SXP", "KRW-HUNT", "KRW-PLA", "KRW-DOT", "KRW-SRM", "KRW-MVL", "KRW-PCI", "KRW-STRAX",
            "KRW-AQT", "KRW-GLM", "KRW-SSX", "KRW-META", "KRW-FCT2", "KRW-CBK", "KRW-SAND", "KRW-HUM",
            "KRW-DOGE", "KRW-1INCH", "KRW-ALGO", "KRW-NEAR", "KRW-WEMIX", "KRW-AVAX", "KRW-T", "KRW-CELO",
            "KRW-GMT", "KRW-APT", "KRW-SHIB", "KRW-MASK", "KRW-ARB", "KRW-EGLD", "KRW-BLUR", "KRW-ID",
            "KRW-SUI", "KRW-SEI", "KRW-CYBER", "KRW-MATIC", "KRW-SOL", "KRW-ASTR", "KRW-UNI", "KRW-FLOW",
            "KRW-MNT", "KRW-USDC", "KRW-XEC", "KRW-USDT", "KRW-BNB", "KRW-ONDO", "KRW-ETHFI", "KRW-STRK",
            "KRW-PYTH", "KRW-ALT", "KRW-JUP", "KRW-MANTA", "KRW-WIF", "KRW-DYM", "KRW-AUCTION", "KRW-LINA",
            "KRW-NU", "KRW-NKN", "KRW-PUNDIX", "KRW-GRT", "KRW-POLYX", "KRW-AXS", "KRW-TEMCO", "KRW-HIBS",
            "KRW-WIKEN", "KRW-FLUX", "KRW-GMX", "KRW-KLEVA", "KRW-ADX", "KRW-PROS", "KRW-STG", "KRW-POWR",
            "KRW-EOS", "KRW-GALA", "KRW-BAKE", "KRW-PROPC", "KRW-HPO", "KRW-CTC", "KRW-ARKM", "KRW-NTRN",
            "KRW-REQ", "KRW-ALTB", "KRW-UXLINK", "KRW-MANTRA", "KRW-XNO", "KRW-BZNT", "KRW-FX", "KRW-VALOR",
            "KRW-LBXC", "KRW-CARRY", "KRW-GOM2", "KRW-SMC", "KRW-ARW", "KRW-VIC", "KRW-IPX", "KRW-VSYS",
            "KRW-XLM", "KRW-BIOT", "KRW-DAWN", "KRW-JAM", "KRW-IGNIS", "KRW-LAMB", "KRW-OGN", "KRW-ZIL",
            "KRW-MED", "KRW-GRS", "KRW-ONT", "KRW-ONG", "KRW-BSV", "KRW-WNCG", "KRW-CKB", "KRW-MDT",
            "KRW-POLA", "KRW-ARDR", "KRW-XTZ", "KRW-HIVE", "KRW-BORA", "KRW-MVL", "KRW-KLAY", "KRW-PROS",
            "KRW-STG", "KRW-POWR", "KRW-EOS", "KRW-SXP", "KRW-XEC", "KRW-GALA", "KRW-T", "KRW-GMT",
            "KRW-LTC", "KRW-CELO", "KRW-PCI", "KRW-HUNT", "KRW-PUNDIX", "KRW-ZRX", "KRW-SC", "KRW-NKN",
            "KRW-NU", "KRW-LINA", "KRW-BAT", "KRW-AUCTION", "KRW-ADX", "KRW-BCH", "KRW-LOOM", "KRW-AHT",
            "KRW-LINK", "KRW-IOST", "KRW-POLYX", "KRW-GRT", "KRW-MASK", "KRW-CYBER", "KRW-SEI", "KRW-SUI",
            "KRW-ID", "KRW-ARB", "KRW-BLUR", "KRW-KLEVA", "KRW-GMX", "KRW-APT", "KRW-FLUX", "KRW-WIKEN",
            "KRW-HIBS", "KRW-TEMCO", "KRW-1INCH", "KRW-DOGE", "KRW-HUM", "KRW-SAND", "KRW-CBK", "KRW-FCT2",
            "KRW-META", "KRW-SSX", "KRW-GLM", "KRW-AQT", "KRW-STRAX", "KRW-TRX", "KRW-AERGO", "KRW-STORJ",
            "KRW-ANKR", "KRW-ICX", "KRW-QTUM", "KRW-SRM", "KRW-MANA", "KRW-TFUEL", "KRW-ENJ", "KRW-THETA",
            "KRW-CHZ", "KRW-VET", "KRW-CRO", "KRW-JST", "KRW-CTC", "KRW-STX", "KRW-AXS", "KRW-SAND",
            "KRW-FLOW", "KRW-WAVES", "KRW-NEAR", "KRW-ALGO", "KRW-HBAR", "KRW-WAXP", "KRW-SBD", "KRW-UNI",
            "KRW-SHIB", "KRW-DOGE", "KRW-SOL", "KRW-MATIC", "KRW-DOT", "KRW-ASTR", "KRW-AVAX", "KRW-ADA",
            "KRW-XRP", "KRW-ETH", "KRW-BTC", "KRW-TRUMP", "KRW-WCT"
        ]
    }
}
