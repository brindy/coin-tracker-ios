//
//  CoinRepository.swift
//  CoinTracker
//
//  Created by Christopher Brind on 12/08/2017.
//  Copyright © 2017 Christopher Brind. All rights reserved.
//

import Foundation

class CoinRepository {

    var coins = [Coin]()

    func refresh(completion: @escaping () -> Void) {
        CoinMarketCapRequest().async { result in
            if let coins = result {

                let top10 = coins[0...10]
                let theRest = coins[11...coins.count - 1]

                self.coins = top10 + theRest.sorted(by: { (left, right) -> Bool in
                    left.symbol.compare(right.symbol) == ComparisonResult.orderedAscending
                })

            }

            DispatchQueue.main.async {
                completion()
            }
        }
    }

}


struct Coin {

    var id: String
    var name: String
    var symbol: String
    var price: String // In currency specified by AppSettings.currency
    var change: PriceChange

}

struct PriceChange {

    var hour: String
    var day: String
    var sevenDays: String

}
