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

            let c1 = components1[i]
            let c2 = components2[i]

            let c1IsNumeric = c1.allSatisfy(\.isNumber)
            let c2IsNumeric = c2.allSatisfy(\.isNumber)

            switch (c1IsNumeric, c2IsNumeric) {
            case (true, true):
                // SemVer prohibits leading zeros, so length-then-lex gives correct integer ordering
                // for arbitrarily large values without overflow risk.
                if c1.count != c2.count {
                    return c1.count < c2.count ? .ascending : .descending
                }
                if c1 < c2 { return .ascending }
                if c1 > c2 { return .descending }
            case (true, false):
                return .ascending   // numeric < alphanumeric per SemVer 2.0
            case (false, true):
                return .descending
            case (false, false):
                if c1.lexicographicallyPrecedes(c2) { return .ascending }
                if c2.lexicographicallyPrecedes(c1) { return .descending }
            }
        }

        return .same
    }
}
