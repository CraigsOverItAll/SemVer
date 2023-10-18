# Swift SemVer

A lightweight `struct` to contain a SemVer 2.0 version.

From the [SemVer Website](https://semver.org)

> Given a version number `MAJOR`.`MINOR`.`PATCH` is a "release version"

Versions are comparable and equatable with the following notes:
 - Pre-release versions have a lower precedence than the associated normal version.
 - Metadata is not used in comparison as it inherently has no ordering

Additional labels for pre-release and build metadata are available as extensions to the `MAJOR`.`MINOR`.`PATCH` format. SemVer defines build and pre-release components of a  version as `Optional` strings as such when comparing versions the pre-release component will be used if present. Where a pre-release component contains a "." seprated value, it is split into subcomponents and uses `String` or numeric comparison rules.

_N.B._ `metadata` is **not** used in version comparisons.

This implementation provides a *simple* `version` string and a comprehensive version string called `semVer`. These properties are also available via `description` and `debugDescription` respectively.
