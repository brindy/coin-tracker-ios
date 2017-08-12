//
//  SelectCoinViewController.swift
//  CoinTracker
//
//  Created by Christopher Brind on 12/08/2017.
//  Copyright © 2017 Christopher Brind. All rights reserved.
//

import Foundation
import UIKit

class SelectCoinViewController: UITableViewController {

    lazy var coinRepository = CoinRepository()

    var busy = false

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)

        if coinRepository.coins.isEmpty {
            refresh()
            tableView.setContentOffset(CGPoint(x: 0, y: -refreshControl!.frame.size.height), animated: true)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let controller = segue.destination as? EnterCoinDetailsViewController else {
            return;
        }

        controller.coin = coinRepository.coins[tableView.indexPathForSelectedRow!.row]
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coinRepository.coins.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Symbol")!
        cell.textLabel?.text = coinRepository.coins[indexPath.row].symbol
        cell.detailTextLabel?.text = coinRepository.coins[indexPath.row].name
        return cell
    }

    func refresh() {

        guard !busy else {
            return
        }

        busy = true
        refreshControl?.beginRefreshing()

        coinRepository.refresh {
            self.busy = false
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }

    }

}
