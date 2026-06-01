//
//  SemVerTests.swift
//
//
//  Created by Craig Phillips on 13/10/2023.
//
//
//

@testable import SemVer
import Testing

struct VersionTests {
    private let onePointZero = try! Version(major: 1, minor: 0, patch: 0)

    @Test func versionComparisons() throws {
        let firstMeta = try Version(major: 1, minor: 0, patch: 0, metadata: "some-commit-hash")

        #expect(onePointZero == firstMeta)
        #expect(!(onePointZero === firstMeta))

        let firstPreRelease = try Version(major: 1, minor: 0, patch: 0, prerelease: "alpha")
        #expect(firstPreRelease < onePointZero)

        let second = try Version(major: 2, minor: 0, patch: 0)
        #expect(onePointZero < second)

        let secondPreRelease = try Version(major: 2, minor: 0, patch: 0, prerelease: "alpha")
        #expect(!(second < secondPreRelease))
        #expect(secondPreRelease > onePointZero)
    }

    @Test func semVerEmitted() throws {
        let basicVersion = try Version(major: 1, minor: 2, patch: 3)
        #expect(basicVersion.semVer == "1.2.3")

        let prereleaseVersion = try Version(major: 1, minor: 2, patch: 3, prerelease: "alpha")
        #expect(prereleaseVersion.semVer == "1.2.3-alpha")

        let metaVersion = try Version(major: 1, minor: 2, patch: 3, metadata: "123.456")
        #expect(metaVersion.semVer == "1.2.3+123.456")

        let complexVersion = try Version(major: 1, minor: 2, patch: 3, prerelease: "beta2", metadata: "123.456")
        #expect(complexVersion.semVer == "1.2.3-beta2+123.456")
    }

    @Test func createFromString() {
        assertStringCreation("1.2.3")
        assertStringCreation("1.2.3-alpha")
        assertStringCreation("1.2.3+123.456")
        assertStringCreation("1.2.3-beta2+123.456")
    }

    @Test func throwInvalid() {
        #expect(throws: Version.Errors.prereleaseInvalid) {
            try Version(major: 1, minor: 0, patch: 0, prerelease: "#invalid")
        }
        #expect(throws: Version.Errors.metadataInvalid) {
            try Version(major: 1, minor: 0, patch: 0, prerelease: "alpha", metadata: "#invalid")
        }
    }

    @Test func stringAssignment() {
        var sut: Version = "1.2.3"
        #expect(sut > onePointZero)

        let one23 = sut
        sut = "1.2.3-alpha"
        #expect(sut < one23)
    }

    /// **Pre-release:**
    /// Examples: 1.0.0-alpha, 1.0.0-alpha.1, 1.0.0-0.3.7, 1.0.0-x.7.z.92, 1.0.0-x-y-z.--
    ///
    /// **Metadata:**
    /// Examples: 1.0.0-alpha+001, 1.0.0+20130313144700, 1.0.0-beta+exp.sha.5114f85, 1.0.0+21AF26D3----117B344092BD
    ///
    /// **Precedence:**
    /// Example: 1.0.0 < 2.0.0 < 2.1.0 < 2.1.1
    /// Example: 1.0.0-alpha < 1.0.0
    /// Example: 1.0.0-alpha < 1.0.0-alpha.1 < 1.0.0-alpha.beta < 1.0.0-beta < 1.0.0-beta.2 < 1.0.0-beta.11 < 1.0.0-rc.1 < 1.0.0
    @Test func semVerOrgExamples() throws {
        let onePointZero = try Version(major: 1, minor: 0, patch: 0)
        let twoPointZero = try Version(major: 2, minor: 0, patch: 0)
        let twoPointOne = try Version(major: 2, minor: 1, patch: 0)
        let twoPointOneOne = try Version(major: 2, minor: 1, patch: 1)
        #expect(onePointZero < twoPointZero)
        #expect(twoPointZero < twoPointOne)
        #expect(twoPointOne < twoPointOneOne)

        let onePointAlpha = try Version(major: 1, minor: 0, patch: 0, prerelease: "alpha")
        #expect(onePointAlpha < onePointZero)

        let onePointAlpha1 = try Version(major: 1, minor: 0, patch: 0, prerelease: "alpha.1")
        #expect(onePointAlpha < onePointAlpha1)

        let onePointAlphaBeta = try Version(major: 1, minor: 0, patch: 0, prerelease: "alpha.beta")
        #expect(onePointAlpha1 < onePointAlphaBeta)

        let onePointBeta = try Version(major: 1, minor: 0, patch: 0, prerelease: "beta")
        #expect(onePointAlphaBeta < onePointBeta)

        let onePointBeta2 = try Version(major: 1, minor: 0, patch: 0, prerelease: "beta.2")
        #expect(onePointBeta < onePointBeta2)

        let onePointBeta11 = try Version(major: 1, minor: 0, patch: 0, prerelease: "beta.11")
        #expect(onePointBeta2 < onePointBeta11)

        let onePointRC1 = try Version(major: 1, minor: 0, patch: 0, prerelease: "rc.1")
        #expect(onePointBeta11 < onePointRC1)
        #expect(onePointRC1 < onePointZero)
    }

    private func assertStringCreation(_ sutStr: String) {
        let sutVersion = Version(sutStr)
        #expect(sutVersion != nil)
        #expect(sutVersion?.semVer == sutStr)
    }
}
