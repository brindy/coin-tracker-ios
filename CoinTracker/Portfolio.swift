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

    let database = Database.shared

    var positions = [String: Position]()

    private init() {
        rebuildPositions()
    }

    func add(coinId: String, amount: Double, date: Date) {
        _ = database.addHistoryItem(coinId: coinId, amount: amount, date: date)
        rebuildPositions()
    }

    func delete(coinId: String) {
        positions[coinId] = nil
        database.removeHistoryItems(for: coinId)
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
