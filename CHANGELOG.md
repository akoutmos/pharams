# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.8.0] - 2019-1-10

### Fixed

- Fixed issue when default value is set to false

## [0.7.0] - 2018-11-01

### Added

- The ability to chose your key type of the params map

### Fixed

- Alias issue inside of validation functions

## [0.6.0] - 2018-10-29

### Added

- Example project which is also used for integration testing

### Fixed

- Bug when aliases are used in macro

## [0.5.0] - 2018-09-27

### Added

- Added ability to embed external module schemas (still need to allow using `with:` to specify non default changeset function).

## [0.4.0] - 2018-09-20

### Added

- Added additional documentation around embedded schemas and one vs many

### Fixed

- Fixed error with view when casting type was tuple ({:array, :map} for example)

## [0.3.0] - 2018-09-19

### Added

- Improved documentation
- Fixed compiler warnings

## [0.2.0] - 2018-09-19

### Removed

- Output of generated ecto schema during compilation

### Changed

- Directory structure

## [0.1.0] - 2018-09-19

### Added

- Initial release of Pharams. API is not stable and subject to change.
