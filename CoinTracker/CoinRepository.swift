//
//  CoinRepository.swift
//  CoinTracker
//
//  Created by Christopher Brind on 12/08/2017.
//  Copyright © 2017 Christopher Brind. All rights reserved.
//

import Foundation
import RealmSwift

class CoinRepository {

    private struct Keys {
        static let lastUpdated = "coins_last_updated"
    }

    static var shared = CoinRepository()

    var coins: [Coin] {
        get {
            return Array(try! Realm().objects(Coin.self))
        }
    }

    var lastUpdated:Date {
        get {

            if let date = UserDefaults.standard.object(forKey: Keys.lastUpdated) as? Date {
                return date
            } else {
                return Date()
            }

        }

        set {
            UserDefaults.standard.set(newValue, forKey: Keys.lastUpdated)
        }

    }

    private init() {
    }

    func refresh(completion: @escaping () -> Void) {
        CoinMarketCapRequest().async { result in

            if let coins = result {

                let top10 = coins[0...10]
                let theRest = coins[11...coins.count - 1]

                let coins = top10 + theRest.sorted(by: { (left, right) -> Bool in
                    left.symbol.compare(right.symbol) == ComparisonResult.orderedAscending
                })

                let realm = try! Realm()
                realm.beginWrite()
                realm.delete(realm.objects(Coin.self))
                for coin in coins {
                    realm.add(coin)
                }
                try! realm.commitWrite()

                self.lastUpdated = Date()
            }

            DispatchQueue.main.async {
                completion()
            }

        }
    }

    func coin(for id: String) -> Coin? {

        for coin in coins {
            if coin.id == id {
                return coin
            }
        }

        return nil
    }

}


class Coin: Object {

    dynamic var id: String!
    dynamic var name: String!
    dynamic var symbol: String!
    dynamic var price: String! // In currency specified by AppSettings.currency
    dynamic var change: PriceChange!

}

class PriceChange: Object {

    dynamic var hour: String!
    dynamic var day: String!
    dynamic var sevenDays: String!

}
