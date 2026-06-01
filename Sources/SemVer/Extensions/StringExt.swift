//
//  StringExt.swift
//
//
//  Created by Craig Phillips on 17/10/2023.
//
//
//

extension String {
    func isLessThan(_ other: String) -> Bool {
        compareByPrecedence(with: other) == .ascending
    }

    func isGreaterThan(_ other: String) -> Bool {
        compareByPrecedence(with: other) == .descending
    }

    private enum Ordering { case ascending, same, descending }

    private func compareByPrecedence(with other: String) -> Ordering {
        let components1 = self.split(separator: ".")
        let components2 = other.split(separator: ".")

        let maxLength = max(components1.count, components2.count)

        for i in 0..<maxLength {
            if i >= components1.count { return .ascending }
            if i >= components2.count { return .descending }

            let component1 = components1[i]
            let component2 = components2[i]

            if let num1 = Int(component1), let num2 = Int(component2) {
                if num1 < num2 { return .ascending }
                if num1 > num2 { return .descending }
            } else {
                if component1.lexicographicallyPrecedes(component2) { return .ascending }
                if component2.lexicographicallyPrecedes(component1) { return .descending }
            }
        }

        return .same
    }
}
