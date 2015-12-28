//
//  MyExtensions.swift
//  PGprojekat
//
//  Created by Uros Zivaljevic on 12/28/15.
//  Copyright © 2015 Uros Zivaljevic. All rights reserved.
//

import Foundation

extension String {
    func endsWith (str: String) -> Bool {
        if let range = self.rangeOfString(str, options:NSStringCompareOptions.BackwardsSearch) {
            return range.endIndex == self.endIndex
        }
        return false
    }
}


extension Array {
    func getAverage() -> Double {
        var sum = 0.0
        if self[0] is Double {
            for i in 0..<self.count {
                sum += self[i] as! Double
            }
        } else {
            print("Nije Double array!!!")
        }
        return sum/Double(self.count)
    }
}

//
//func + (left: String, right: String) -> String {
//    var newString = left
//    newString.appendContentsOf(right)
//    return newString
//}
