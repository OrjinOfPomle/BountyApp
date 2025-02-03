//
//  Extensions.swift
//  Bounty
//
//  Created by Keleabe M. on 7/27/20.
//  Copyright © 2020 FireflyGlobe. All rights reserved.
//

import Foundation


extension Int {
        
    func penniesToFormattedCurrency() -> String{
        let dollars = Double(self)/100
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        if let dollarString = formatter.string(from: dollars as NSNumber){
            return dollarString
        }
        return "$0.00"
    }
}
