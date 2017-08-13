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

    private init() {
        rebuildPositions()
    }

    func add(_ coin: Coin, amount: Double, date: Date) {
        _ = Database.shared.addHistoryItem(coinId: coin.id, amount: amount, date: date)
        rebuildPositions()
    }

    func rebuildPositions() {
        positions = [String : Position]()
        for entry in Database.shared.history {
            updatePosition(with: entry)
        }        
    }

    func updatePosition(with item: HistoryItem) {

        var foundPosition = positions[item.coinId!]
        if foundPosition == nil {
            foundPosition = Position(coinId: item.coinId!, amount: item.amount)
        } else {
            foundPosition?.amount += item.amount
        }

        positions[item.coinId!] = foundPosition
    }

}

struct Position {

    var coinId: String
    var amount: Double

}
