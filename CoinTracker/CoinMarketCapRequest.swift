//
//  CoinMarketCapRequest.swift
//  CoinTracker
//
//  Created by Christopher Brind on 12/08/2017.
//  Copyright © 2017 Christopher Brind. All rights reserved.
//

import Foundation
import Alamofire

class CoinMarketCapRequest {

    lazy var settings = AppSettings()

    func async(completion: @escaping ([Coin]?) -> Void) {
        let background = DispatchQueue.global(qos: .utility)
        Alamofire.request("https://api.coinmarketcap.com/v1/ticker/?convert=\(settings.currency)&limit=100").responseJSON(queue: background) { response in
            completion(response.toCoins())
        }
    }

}

fileprivate extension DataResponse where Value == Any {

    func toCoins() -> [Coin]? {
        guard let json = result.value as? Array<Dictionary<String, Any?>> else { return nil }

        let currency = AppSettings().currency.lowercased()
        var coins = [Coin]()
        json.forEach { coinJson in
            coins.append(coinJson.toCoin(for: currency))
        }

        return coins
    }

}

fileprivate extension Dictionary where Key == String {

    func toCoin(for currency: String) -> Coin {
        let coin = Coin()
        coin.id = self["id"] as? String ?? "id?"
        coin.name = self["name"] as? String ?? "name?"
        coin.symbol = self["symbol"] as? String ?? "symbol?"
        coin.price = self["price_\(currency)"] as? String ?? "price??"
        coin.change = toPriceChange()
        return coin
    }

    func toPriceChange() -> PriceChange {
        let change = PriceChange()
        change.hour = self["percent_change_1h"] as? String ?? "1h?"
        change.day = self["percent_change_24h"] as? String ?? "24h?"
        change.sevenDays = self["percent_change_7d"] as? String ?? "7d?"
        return change
    }

}
