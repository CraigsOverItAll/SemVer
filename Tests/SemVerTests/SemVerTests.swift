//
//  SemVerTests.swift
//  
//
//  Created by Craig Phillips on 13/10/2023.
//  
//
//  

@testable import SemVer
import XCTest

final class VersionTests: XCTestCase {
    private let onePointZero = try! Version(major: 1, minor: 0, patch: 0)

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testVersionComparisons() throws {
        let firstMeta = try Version(major: 1, minor: 0, patch: 0, metadata: "some-commit-hash")
        
        XCTAssertTrue(onePointZero == firstMeta)
        
        XCTAssertFalse(onePointZero === firstMeta)
        
        let firstPreRelease = try Version(major: 1, minor: 0, patch: 0, prerelease: "alpha")
        
        XCTAssertLessThan(firstPreRelease, onePointZero)
        
        let second = try Version(major: 2, minor: 0, patch: 0)
        
        XCTAssertTrue(onePointZero < second)
        
        let secondPreRelease = try Version(major: 2, minor: 0, patch: 0, prerelease: "alpha")
        
        XCTAssertFalse(second < secondPreRelease)
        XCTAssertTrue(secondPreRelease > onePointZero)
    }

    func testSemVerEmitted() throws {
        let basicVersion = try Version(major: 1, minor: 2, patch: 3)
        XCTAssertEqual(basicVersion.semVer, "1.2.3")
        
        let prereleaseVersion = try Version(major: 1, minor: 2, patch: 3, prerelease: "alpha")
        XCTAssertEqual(prereleaseVersion.semVer, "1.2.3-alpha")
        
        let metaVersion = try Version(major: 1, minor: 2, patch: 3, metadata: "123.456")
        XCTAssertEqual(metaVersion.semVer, "1.2.3+123.456")

        let complexVersion = try Version(major: 1, minor: 2, patch: 3, prerelease: "beta2", metadata: "123.456")
        XCTAssertEqual(complexVersion.semVer, "1.2.3-beta2+123.456")
    }
    
    func testCreateFromString() throws {
        assertStringCreation("1.2.3")
        assertStringCreation("1.2.3-alpha")
        assertStringCreation("1.2.3+123.456")
        assertStringCreation("1.2.3-beta2+123.456")
    }
    
    func testThrowInvalid() throws {
        XCTAssertThrowsError(try Version(major: 1, minor: 0, patch: 0, prerelease: "#invalid"))
        XCTAssertThrowsError(try Version(major: 1, minor: 0, patch: 0, prerelease: "alpha", metadata: "#invalid"))
    }
    
    func testStringAssignment() throws {
        var sut: Version = "1.2.3"
        
        XCTAssertGreaterThan(sut, onePointZero)
        
        let one23 = sut
        
        sut = "1.2.3-alpha"
        XCTAssertLessThan(sut, one23)
    }

    /// **Pre-release:**
    /// Examples: 1.0.0-alpha, 1.0.0-alpha.1, 1.0.0-0.3.7, 1.0.0-x.7.z.92, 1.0.0-x-y-z.--
    ///
    /// **Metadata:**
    /// Examples: 1.0.0-alpha+001, 1.0.0+20130313144700, 1.0.0-beta+exp.sha.5114f85, 1.0.0+21AF26D3----117B344092BD
    ///
    /// ** Precedence**
    /// Example: 1.0.0 < 2.0.0 < 2.1.0 < 2.1.1
    /// Example: 1.0.0-alpha < 1.0.0
    /// Example: 1.0.0-alpha < 1.0.0-alpha.1 < 1.0.0-alpha.beta < 1.0.0-beta < 1.0.0-beta.2 < 1.0.0-beta.11 < 1.0.0-rc.1 < 1.0.0
    func testSemVerOrgExamples() throws {
        // Example: 1.0.0 < 2.0.0 < 2.1.0 < 2.1.1
        let onePointZero = try Version(major: 1, minor: 0, patch: 0)
        let twoPointZero = try Version(major: 2, minor: 0, patch: 0)
        let twoPointOne = try Version(major: 2, minor: 1, patch: 0)
        let twoPointOneOne = try Version(major: 2, minor: 1, patch: 1)
        XCTAssertTrue(onePointZero < twoPointZero)
        XCTAssertTrue(twoPointZero < twoPointOne)
        XCTAssertTrue(twoPointOne < twoPointOneOne)

        // Example: 1.0.0-alpha < 1.0.0
        let onePointAlpha = try Version(major: 1, minor: 0, patch: 0, prerelease: "alpha")
        XCTAssertTrue(onePointAlpha < onePointZero)

        // Example: 1.0.0-alpha < 1.0.0-alpha.1 < 1.0.0-alpha.beta < 1.0.0-beta < 1.0.0-beta.2 < 1.0.0-beta.11 < 1.0.0-rc.1 < 1.0.0
        let onePointAlpha1 = try Version(major: 1, minor: 0, patch: 0, prerelease: "alpha.1")
        XCTAssertTrue(onePointAlpha < onePointAlpha1)

        let onePointAlphaBeta = try Version(major: 1, minor: 0, patch: 0, prerelease: "alpha.beta")
        XCTAssertTrue(onePointAlpha1 < onePointAlphaBeta)

        let onePointBeta = try Version(major: 1, minor: 0, patch: 0, prerelease: "beta")
        XCTAssertTrue(onePointAlphaBeta < onePointBeta)

        let onePointBeta2 = try Version(major: 1, minor: 0, patch: 0, prerelease: "beta.2")
        XCTAssertTrue(onePointBeta < onePointBeta2)

        let onePointBeta11 = try Version(major: 1, minor: 0, patch: 0, prerelease: "beta.11")
        XCTAssertTrue(onePointBeta2 < onePointBeta11)

        let onePointRC1 = try Version(major: 1, minor: 0, patch: 0, prerelease: "rc.1")
        XCTAssertTrue(onePointBeta11 < onePointRC1)
        XCTAssertTrue(onePointRC1 < onePointZero)
    }

    func assertStringCreation(_ sutStr: String) {
        let sutVersion = Version(sutStr)
        
        XCTAssertNotNil(sutVersion)
        XCTAssertEqual(sutVersion!.semVer, sutStr)
    }
}
