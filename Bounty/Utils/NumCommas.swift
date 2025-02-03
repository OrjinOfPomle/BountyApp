//
//  NumCommas.swift
//  Bounty
//
//  Created by Keleabe M. on 6/10/20.
//  Copyright © 2020 FireflyGlobe. All rights reserved.
//

import Foundation

extension Int {
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}
