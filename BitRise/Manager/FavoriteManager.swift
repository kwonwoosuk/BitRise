//
//  FavoriteManager.swift
//  BitRise
//
//  Created by 권우석 on 3/11/25.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa

final class FavoriteManager {
    static let shared = FavoriteManager()
    
    private let realm: Realm
    private let favoritesChangedRelay = PublishRelay<Void>()
    
    var favoritesChanged: Observable<Void> {
        return favoritesChangedRelay.asObservable()
    }
    
    private init() {
        do {
            realm = try Realm()
        } catch {
            fatalError("렘 찾기 실패: \(error)")
        }
    }
    
    func isFavorite(coinId: String) -> Bool {
        return realm.object(ofType: FavoriteCoin.self, forPrimaryKey: coinId) != nil
    }
    
    func getAllFavorites() -> [FavoriteCoin] {
        let favorites = realm.objects(FavoriteCoin.self).sorted(byKeyPath: "dateAdded", ascending: false)
        return Array(favorites)
    }
    
    func toggleFavorite(coinId: String, name: String) -> Bool {
        var isAdded = false
        
        do {
            try realm.write {
                if let existingFavorite = realm.object(ofType: FavoriteCoin.self, forPrimaryKey: coinId) {
                    // 즐겨찾기에서 제거
                    realm.delete(existingFavorite)
                    isAdded = false
                } else {
                    // 즐겨찾기에 추가
                    let newFavorite = FavoriteCoin(id: coinId, name: name)
                    realm.add(newFavorite)
                    isAdded = true
                }
            }
            favoritesChangedRelay.accept(())
            return isAdded
        } catch {
            print("즐겨찾기 토글 실패 \(error)")
            return false
        }
    }
}
