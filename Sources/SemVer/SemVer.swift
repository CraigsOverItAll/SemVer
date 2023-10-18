//
//  SemVer.swift
//
//
//  Created by Craig Phillips on 12/7/2023.
//
//
//

/// A lightweight `struct` to contain a SemVer 2.0 version.
///
/// From the [SemVer Website](https://semver.org)
///
/// > Given a version number `MAJOR`.`MINOR`.`PATCH` is a "release version"
///
/// Versions are comparable and equatable with the following notes:
///  - Pre-release versions have a lower precedence than the associated normal version.
///  - Metadata is not used in comparison as it inherently has no ordering
///
/// Additional labels for pre-release and build metadata are available as
/// extensions to the `MAJOR`.`MINOR`.`PATCH` format. SemVer defines build
/// and pre-release components of a  version as `Optional` strings as such
/// when comparing versions the pre-release component will be used if
/// present. Where a pre-release component contains a "." seprated value,
/// it is split into subcomponents and uses `String` or numeric comparison
/// rules.
///
/// _N.B._ `metadata` is **not** used in version comparisons.
///
/// This implementation provides an identical operator `===`
/// The `===` operator includes the comparison of metadata.
///
/// This implementation provides a *simple* `version` string and a
/// comprehensive version string called `semVer`. These properties are also
/// available via `description` and `debugDescription` respectively.
///
public struct Version: Codable, CustomStringConvertible, CustomDebugStringConvertible {
    public enum Errors: Error {
        case prereleaseInvalid
        case metadataInvalid
    }
    
    /// Increment MAJOR version when you make incompatible API changes
    public let major: UInt
    /// Increment MINOR version when you add functionality in a backward compatible manner
    public let minor: UInt
    /// Increment PATCH version when you make backward compatible bug fixes
    public let patch: UInt
    /// A pre-release version MAY be denoted by appending a hyphen and a
    /// series of dot separated identifiers immediately following the patch
    /// version.
    ///
    /// Identifiers MUST comprise only ASCII alphanumerics and
    /// hyphens [0-9A-Za-z-]. Identifiers MUST NOT be empty. Numeric
    /// identifiers MUST NOT include leading zeroes. Pre-release versions
    /// have a **lower precedence** than the associated normal version.
    ///
    /// A pre-release version indicates that the version is unstable and might
    /// not satisfy the intended compatibility requirements as denoted by its
    /// associated normal version.
    ///
    /// **Examples**
    /// - 1.0.0-alpha
    /// - 1.0.0-alpha.1
    /// - 1.0.0-0.3.7
    /// - 1.0.0-x.7.z.92
    /// - 1.0.0-x-y-z.--
    ///
    public let prerelease: String?
    private static let prereleaseRegex = #/^(?P<prerelease>[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?$/#
    
    /// Build metadata MAY be denoted by appending a plus sign and a series of dot separated
    /// identifiers immediately following the patch or pre-release version.
    ///
    /// Identifiers MUST comprise only ASCII alphanumerics and hyphens [0-9A-Za-z-].
    ///
    /// Identifiers MUST NOT be empty. Build metadata MUST be ignored when determining
    /// version precedence. Thus two versions that differ only in the build metadata, have the
    /// same precedence
    ///
    /// **Examples:**
    ///
    /// - 1.0.0-alpha+001
    /// - 1.0.0+20130313144700
    /// - 1.0.0-beta+exp.sha.5114f85
    /// - 1.0.0+21AF26D3----117B344092BD
    ///
    public let metadata: String?
    private static let metadataRegex = #/^(?P<metadata>[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?$/#
    
    /// Version initialiser
    ///
    /// **N.B.** The initialiser will throw if the `prerelease` or  `metadata` strings
    /// don't met the SemVer limitations
    init(major: UInt, minor: UInt, patch: UInt, prerelease: String? = nil, metadata: String? = nil) throws {
        self.major = major
        self.minor = minor
        self.patch = patch
        
        if let prerelease {
            guard let prereleaseMatch = prerelease.firstMatch(of: Self.prereleaseRegex)?.output.prerelease else {
                throw Errors.prereleaseInvalid
            }
            
            self.prerelease = String(prereleaseMatch)
            
        } else {
            self.prerelease = nil
        }
        
        if let metadata {
            guard let metadataMatch = metadata.firstMatch(of: Self.metadataRegex)?.output.metadata else {
                throw Errors.metadataInvalid
            }
            
            self.metadata = String(metadataMatch)
            
        } else {
            self.metadata = nil
        }
    }
    
    
    public var version: String {
        return "\(major).\(minor).\(patch)"
    }
    
    public var semVer: String {
        var versionString = "\(major).\(minor).\(patch)"
        if let prerelease {
            versionString += "-\(prerelease)"
        }
        if let metadata {
            versionString += "+\(metadata)"
        }
        return versionString
    }
    
    public var description: String { version }
    
    public var debugDescription: String { semVer }
}

extension Version: Comparable {
    public static func < (lhs: Version, rhs: Version) -> Bool {
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        }
        if lhs.minor != rhs.minor {
            return lhs.minor < rhs.minor
        }
        if lhs.patch != rhs.patch {
            return lhs.patch < rhs.patch
        }
        
        // Compare prerelease identifiers
        if let lhsPrerelease = lhs.prerelease, let rhsPrerelease = rhs.prerelease {
            if lhsPrerelease != rhsPrerelease {
                return lhsPrerelease.isLessThan(rhsPrerelease)
            }
        } else if lhs.prerelease != nil, rhs.prerelease == nil {
            // Precedence for versions with prerelease identifiers
            return true
        } else if lhs.prerelease == nil, rhs.prerelease != nil {
            return false
        }
        
        return true
    }
    
    public static func == (lhs: Version, rhs: Version) -> Bool {
        return lhs.major == rhs.major &&
        lhs.minor == rhs.minor &&
        lhs.patch == rhs.patch &&
        lhs.prerelease == rhs.prerelease
    }
    
    /// `===` provides an "is identical" comparision that includes version metadata.
    /// - Parameters:
    ///   - lhs: A ``Version``
    ///   - rhs: A ``Version``
    /// - Returns: `true` if all components are identical
    public static func === (lhs: Version, rhs: Version) -> Bool {
        return lhs.major == rhs.major &&
        lhs.minor == rhs.minor &&
        lhs.patch == rhs.patch &&
        lhs.prerelease == rhs.prerelease &&
        lhs.metadata == rhs.metadata
    }
}

extension Version: LosslessStringConvertible {
    public init?(_ description: String) {
        let semVerRegex =  #/^(?P<major>0|[1-9]\d*)\.(?P<minor>0|[1-9]\d*)\.(?P<patch>0|[1-9]\d*)(?:-(?P<prerelease>[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+(?P<metadata>[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?$/#
        
        let matched = description.matches(of: semVerRegex)
        
        guard let result = matched.first else { return nil }
        
        let componentMatch = result.output
        
        // We must have a major value and it can't be zero
        guard let majorValue = UInt(String(componentMatch.major)), majorValue != .zero else { return nil }
        
        major = majorValue
        minor = UInt(String(componentMatch.minor)) ?? .zero
        patch = UInt(String(componentMatch.patch)) ?? .zero
        
        if let prereleaseSubstring = componentMatch.prerelease {
            prerelease = String(prereleaseSubstring)
        } else {
            prerelease = nil
        }
        
        if let metadataSubstring = componentMatch.metadata {
            metadata = String(metadataSubstring)
        } else {
            metadata = nil
        }
    }
    
    
}

extension Version: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self = .init(value)!
    }
}


public extension Version {
    static var max: Version {
        try! Version(major: .max, minor: .max, patch: .max)
    }
}
