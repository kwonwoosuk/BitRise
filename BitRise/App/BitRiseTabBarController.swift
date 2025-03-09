//
//  TabBarController.swift
//  BitRise
//
//  Created by 권우석 on 3/8/25.
//

import UIKit

final class BitRiseTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBarController()
        setupTabBarAppearance()
        tabBar.delegate = self
    }
    
    private func configureTabBarController() {
        
        let firstTab = ExchangeViewController()
        firstTab.tabBarItem.image = UIImage(systemName: Constants.Icon.exchange)
        firstTab.tabBarItem.title  = "거래소"
        
        let secondTab = SearchViewController()
        secondTab.tabBarItem.image = UIImage(systemName: Constants.Icon.coinInfo)
        secondTab.tabBarItem.title = "코인정보"
        
        let thirdTab = ExchangeViewController()
        thirdTab.tabBarItem.title = "포트폴리오"
        thirdTab.tabBarItem.image = UIImage(systemName: Constants.Icon.star)
        
        
        let firstNav = UINavigationController(rootViewController: firstTab)
        firstNav.view.backgroundColor = .white
        // 네비게이션 바 설정 추가
        setupNavigationBarAppearance(nav: firstNav)
        
        let secondNav = UINavigationController(rootViewController: secondTab)
        setupNavigationBarAppearance(nav: secondNav)
        
        let thirdNav = UINavigationController(rootViewController: thirdTab)
        thirdNav.view.backgroundColor = .white
        setupNavigationBarAppearance(nav: thirdNav)
        
        setViewControllers([firstNav, secondNav, thirdNav], animated: true)
    }
    
    private func setupNavigationBarAppearance(nav: UINavigationController) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        
        nav.navigationBar.standardAppearance = appearance
        nav.navigationBar.scrollEdgeAppearance = appearance
        nav.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        nav.navigationBar.layer.shadowRadius = 0
        nav.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        nav.navigationBar.layer.shadowOpacity = 0.5
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .white
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -0.5)
        tabBar.layer.shadowRadius = 0
        tabBar.layer.shadowColor = UIColor.lightGray.cgColor
        tabBar.layer.shadowOpacity = 0.3
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = .brBlack
    }
    
    
    
}

