//
//  HistoryViewController.swift
//  CoinTracker
//
//  Created by Christopher Brind on 13/08/2017.
//  Copyright © 2017 Christopher Brind. All rights reserved.
//

import Foundation
import UIKit

class HistoryViewController: UITableViewController {

    let repository = CoinRepository.shared
    let database = Database.shared
    var items = [HistoryItem]()

    override func viewDidAppear(_ animated: Bool) {
        items = database.history
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Item")!

        let item = items[indexPath.row]
        let coin = repository.coin(for: item.coinId!)!

        cell.textLabel?.text = String(format: "%.2f %@", item.amount, coin.name)

        let dateFormatter = DateFormatter();
        dateFormatter.dateStyle = .medium
        let data = dateFormatter.string(from: item.date! as Date)
        cell.detailTextLabel?.text = "\(data)"

        return cell
    }

}
