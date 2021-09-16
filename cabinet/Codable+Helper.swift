// Copyright © 2021 evan. All rights reserved.

import UIKit
import Foundation

extension Decodable {
    static func decode(from data: Data, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .secondsSince1970) -> Self? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        do {
            return try decoder.decode(Self.self, from: data)
        } catch {
            #if DEBUG
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else { return nil }
            guard let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) else { return nil }
            guard let string = String(data: data, encoding: .utf8) else { return nil }
            print("😡😡😡 ----------------- Parse JSON error begin -----------------")
            print(string)
            print("😡😡😡 ----------------- Parse JSON error end -------------------")
            #endif
            print(error)
            return nil
        }
    }
}
