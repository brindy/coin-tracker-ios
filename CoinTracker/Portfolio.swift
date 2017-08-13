//
//  Portfolio.swift
//  CoinTracker
//
//  Created by Christopher Brind on 12/08/2017.
//  Copyright © 2017 Christopher Brind. All rights reserved.
//

import Foundation

class Portfolio {

    public static let shared = Portfolio()

    var positions = [String: Position]()
    var history = [HistoricalEntry]()

    private init() {
        
    }

    func add(_ coin: Coin, amount: Double, date: Date) {
        history.append(HistoricalEntry(coinId: coin.id, amount: amount, date: date))
        rebuildPosition()
    }

    func rebuildPosition() {
        positions = [String : Position]()
        for entry in history {
            updatePosition(with: entry)
        }
    }

    func updatePosition(with entry: HistoricalEntry) {

        var foundPosition = positions[entry.coinId]
        if foundPosition == nil {
            foundPosition = Position(coinId: entry.coinId, amount: entry.amount)
        } else {
            foundPosition?.amount += entry.amount
        }

        positions[entry.coinId] = foundPosition
    }

}

struct Position {

    var coinId: String
    var amount: Double

}

struct HistoricalEntry {

    var coinId: String
    var amount: Double
    var date: Date

}
