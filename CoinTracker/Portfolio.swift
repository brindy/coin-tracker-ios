//
//  Portfolio.swift
//  CoinTracker
//
//  Created by Christopher Brind on 12/08/2017.
//  Copyright © 2017 Christopher Brind. All rights reserved.
//

import Foundation
import RealmSwift

class Portfolio {

    public static let shared = Portfolio()

    var positions = [String: Position]()
    var historyItems: [HistoryItem] {
        get {
            return Array(try! Realm().objects(HistoryItem.self).sorted(byKeyPath: "date", ascending: false))
        }
    }


    private init() {
        rebuildPositions()
    }

    func add(coinId: String, amount: Double, date: Date) {

        let item = HistoryItem()
        item.coinId = coinId
        item.amount = amount
        item.date = date

        let realm = try! Realm()
        realm.beginWrite()
        realm.add(item)
        try! realm.commitWrite()

        rebuildPositions()
    }

    func delete(coinId: String) {
        positions[coinId] = nil

        let realm = try! Realm()
        realm.beginWrite()
        realm.delete(realm.objects(HistoryItem.self).filter("coinId = %@", coinId))
        try! realm.commitWrite()

    }

    func rebuildPositions() {
        positions = [String : Position]()
        let realm = try! Realm()
        for entry in realm.objects(HistoryItem.self) {
            updatePosition(with: entry)
        }        
    }

    func updatePosition(with item: HistoryItem) {

        var foundPosition = positions[item.coinId]
        if foundPosition == nil {
            foundPosition = Position(coinId: item.coinId, amount: item.amount)
        } else {
            foundPosition?.amount += item.amount
        }

        positions[item.coinId] = foundPosition
    }

}

struct Position {

    var coinId: String
    var amount: Double

}

class HistoryItem: Object {

    dynamic var coinId: String = ""
    dynamic var amount: Double = 0.0
    dynamic var date: Date = Date()

}

