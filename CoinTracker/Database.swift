//
//  Database.swift
//  CoinTracker
//
//  Created by Christopher Brind on 13/08/2017.
//  Copyright © 2017 Christopher Brind. All rights reserved.
//

import Foundation
import CoreData

class Database {

    static let shared = Database()

    let container: NSPersistentContainer

    var history: [HistoryItem] {
        get {
            return try! container.viewContext.fetch(HistoryItem.fetchRequest())
        }
    }

    private init() {
        container = NSPersistentContainer(name: "App")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                assertionFailure(error.localizedDescription)
            }
        }
    }

    func addHistoryItem(coinId: String, amount: Double, date: Date) -> HistoryItem {
        let dbItem = HistoryItem(context: container.viewContext)
        dbItem.amount = amount
        dbItem.coinId = coinId
        dbItem.date = date as NSDate
        try! container.viewContext.save()
        return dbItem
    }

    func removeHistoryItems(for coinId: String) {

        for item in history {
            if item.coinId == coinId {
                container.viewContext.delete(item)
            }
        }

        try! container.viewContext.save()

    }

}
