//
//  TrendingView.swift
//  BitRise
//
//  Created by 권우석 on 3/10/25.
//

import UIKit
import SnapKit

final class TrendingView: BaseView {

    let headerView = TrendingHeaderView()
    
    lazy var coinsCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createCoinsLayout())
        cv.backgroundColor = .white
        cv.showsVerticalScrollIndicator = false
        cv.isScrollEnabled = false
        cv.register(TrendingCoinCell.self, forCellWithReuseIdentifier: TrendingCoinCell.identifier)
        return cv
    }()
    
    lazy var nftsCollectionView: UICollectionView = { // 얘만 이상하게 깨져서 컬렉션뷰 초기화시 속성설정
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createNFTsLayout())
        cv.backgroundColor = .white
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.register(TrendingNFTCell.self, forCellWithReuseIdentifier: TrendingNFTCell.identifier)
        return cv
    }()
    
    let coinsSectionLabel = UILabel()
    let coinsSectionTimestampLabel = UILabel()
    let nftsSectionLabel = UILabel()

    var timestamp: Date?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    override func configureHierarchy() {
        [headerView, coinsSectionLabel, coinsSectionTimestampLabel, coinsCollectionView,
         nftsSectionLabel, nftsCollectionView].forEach { addSubview($0) }
    }
    
    override func configureLayout() {
        headerView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.greaterThanOrEqualTo(44)
        }
        
        coinsSectionLabel.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        
        coinsSectionTimestampLabel.snp.makeConstraints { make in
            make.centerY.equalTo(coinsSectionLabel)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        coinsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(coinsSectionLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(392)
        }
        
        nftsSectionLabel.snp.makeConstraints { make in
            make.top.equalTo(coinsCollectionView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        
        nftsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(nftsSectionLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(170)
            make.bottom.lessThanOrEqualToSuperview().offset(-16)
        }
    }
    
    override func configureView() {
        backgroundColor = .white
        
        coinsSectionLabel.text = "인기 검색어"
        coinsSectionLabel.font = .systemFont(ofSize: 12, weight: .heavy)
        coinsSectionLabel.textColor = .brBlack
        
        coinsSectionTimestampLabel.font = .systemFont(ofSize: 12, weight: .regular)
        coinsSectionTimestampLabel.textColor = .lightGray
        updateTimestamp()
        
        nftsSectionLabel.text = "인기 NFT"
        nftsSectionLabel.font = .systemFont(ofSize: 12, weight: .heavy)
        nftsSectionLabel.textColor = .brBlack
    }
    
    func updateTimestamp(_ date: Date = Date()) {
        self.timestamp = date
        if let timestamp = self.timestamp {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM.dd HH:mm"
            let formattedTime = formatter.string(from: timestamp)
            coinsSectionTimestampLabel.text = "\(formattedTime) 기준"
        } else {
            coinsSectionTimestampLabel.text = "시간 정보 없음"
        }
    }
    
    private func createCoinsLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(56)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let verticalGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .absolute(392)
        )
        let verticalGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: verticalGroupSize,
            subitem: item,
            count: 7
        )
        
        let horizontalGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(392)
        )
        let horizontalGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: horizontalGroupSize,
            subitem: verticalGroup,
            count: 2
        )
        
        let section = NSCollectionLayoutSection(group: horizontalGroup)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    // MARK: - NFT
    private func createNFTsLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(90),
            heightDimension: .absolute(170)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(90),
            heightDimension: .absolute(170)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0)
        
        section.orthogonalScrollingBehavior = .continuous
    
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}
