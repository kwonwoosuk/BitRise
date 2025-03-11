//
//  NetworkMonitor.swift
//  BitRise
//
//  Created by 권우석 on 3/11/25.
//

import UIKit
import Network
import SnapKit

final class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor() //  모든 네트워크 감지 하도록 노파라미터
    var onNetworkStatusChanged: ((Bool) -> Void)?
    
    var isConnected: Bool {
        return status == .satisfied
    }
    
    private(set) var status: NWPath.Status = .requiresConnection
    
    private init() {
        startMonitoring()
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
    
    func stopMonitoring() {
        monitor.cancel()
    }
}

final class AlertInfoView {
    static let shared = AlertInfoView()
    var retryAction: (() -> Void)?
    
    private let containerView = UIView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let retryButton = UIButton(type: .system)
    
    private var isShowing = false
    
    private init() {
        setupViews()
    }
    
    private func setupViews() {
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        contentView.backgroundColor = .white
        
        titleLabel.text = "안내"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        
        messageLabel.text = "네트워크 연결이 일시적으로 원활하지 않습니다. 데이터 또는 Wi-Fi 연결 상태를 확인해주세요."
        messageLabel.font = .systemFont(ofSize: 14)
        messageLabel.textColor = .darkGray
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        retryButton.setTitle("다시 시도하기", for: .normal)
        retryButton.backgroundColor = .white
        retryButton.setTitleColor(.brBlack, for: .normal)
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        
        containerView.addSubview(contentView)
        
        [titleLabel, messageLabel, retryButton].forEach {
            contentView.addSubview($0)
        }
        
        contentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.85)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        retryButton.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    func showNetworkAlert() {
        guard !isShowing else { return }
        isShowing = true
        
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            containerView.frame = window.bounds
            window.addSubview(containerView)
        }
    }
    
    func hideNetworkAlert() {
        guard isShowing else { return }
        isShowing = false
        
        containerView.removeFromSuperview()
    }
    
    @objc private func retryButtonTapped() {
            if NetworkMonitor.shared.isConnected {
                hideNetworkAlert()
                retryAction?()
            } else {
                showNetworkToast()
            }
        }
    
    private func showNetworkToast() {
        if let topVC = getTopViewController() {
            topVC.showToast(message: "네트워크 통신이 원활하지 않습니다")
        }
    }
    
    private func getTopViewController() -> UIViewController? {
        if let rootController = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            var topController = rootController
            while let newTopController = topController.presentedViewController {
                topController = newTopController
            }
            return topController
        }
        return nil
    }
}
