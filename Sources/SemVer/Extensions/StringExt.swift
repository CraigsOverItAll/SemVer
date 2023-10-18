//
//  StringExt.swift
//
//
//  Created by Craig Phillips on 17/10/2023.
//
//
//

import Foundation

extension String {
    func isLessThan(_ other: String) -> Bool {
        switch compareByPrecedence(with: other) {
        case .orderedAscending:
            true
        default:
            false
        }
    }

    func isGreaterThan(_ other: String) -> Bool {
        switch compareByPrecedence(with: other) {
        case .orderedDescending:
            true
        default:
            false
        }
    }

    func compareByPrecedence(with other: String) -> ComparisonResult {
        let components1 = self.split(separator: ".")
        let components2 = other.split(separator: ".")

        let maxLength = max(components1.count, components2.count)

        for i in 0..<maxLength {
            // If one of the strings runs out of components, it's considered "less than" the other
            if i >= components1.count {
                return .orderedAscending
            }
            if i >= components2.count {
                return .orderedDescending
            }

            let component1 = components1[i]
            let component2 = components2[i]

            // Check if components are numeric
            if let num1 = Int(component1), let num2 = Int(component2) {
                // Compare numerically
                if num1 < num2 {
                    return .orderedAscending
                } else if num1 > num2 {
                    return .orderedDescending
                }
            } else {
                // Compare lexicographically
                let result = component1.lexicographicallyPrecedes(component2)
                if result {
                    return .orderedAscending
                } else if !result && component1 != component2 {
                    return .orderedDescending
                }
            }
        }

        return .orderedSame
    }
}
