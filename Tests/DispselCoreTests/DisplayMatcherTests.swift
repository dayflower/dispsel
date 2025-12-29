import Testing
@testable import DispselCore
import IOKit

@Suite("Display Matcher Tests")
struct DisplayMatcherTests {
    // Mock service for testing
    private class MockService: NSObject {}

    // Mock displays for testing
    func mockDisplays() -> [Display] {
        return [
            Display(
                uuid: "10FF0FFF-0000-0000-7777-333311112222",
                manufacturerID: "DEL",
                productName: "DELL U4025QW",
                serialNumber: "99XX99",
                transportUpstream: "DP",
                transportDownstream: "DP",
                service: MockService()
            ),
            Display(
                uuid: "20FF0FFF-0000-0000-8888-444422223333",
                manufacturerID: "SAM",
                productName: "Samsung Odyssey",
                serialNumber: "AB123CD",
                transportUpstream: "HDMI",
                transportDownstream: "HDMI",
                service: MockService()
            ),
            Display(
                uuid: "30FF0FFF-0000-0000-9999-555533334444",
                manufacturerID: "LG",
                productName: "LG UltraWide",
                serialNumber: "XY789ZW",
                transportUpstream: "DP",
                transportDownstream: "DP",
                service: MockService()
            )
        ]
    }

    // MARK: - No Specifier Tests

    @Test("No specifier uses first display")
    func noSpecifierUsesFirstDisplay() throws {
        let displays = mockDisplays()
        let (display, warning) = try DisplayMatcher.selectDisplay(
            from: displays,
            specifier: nil
        )

        #expect(display.uuid == displays[0].uuid)
        #expect(warning == nil)
    }

    @Test("Empty displays throws error")
    func emptyDisplaysThrowsError() {
        #expect(throws: DispselError.self) {
            try DisplayMatcher.selectDisplay(from: [], specifier: nil)
        }
    }

    // MARK: - UUID Matching Tests

    @Test("UUID exact match")
    func uuidExactMatch() throws {
        let displays = mockDisplays()
        let spec = try DisplaySpecifier.parse("uuid=10FF0FFF-0000-0000-7777-333311112222")
        let (display, warning) = try DisplayMatcher.selectDisplay(
            from: displays,
            specifier: spec
        )

        #expect(display.uuid == "10FF0FFF-0000-0000-7777-333311112222")
        #expect(warning == nil)
    }

    @Test("UUID matching is case insensitive")
    func uuidCaseInsensitive() throws {
        let displays = mockDisplays()
        let spec = try DisplaySpecifier.parse("uuid=10ff0fff-0000-0000-7777-333311112222")
        let (display, warning) = try DisplayMatcher.selectDisplay(
            from: displays,
            specifier: spec
        )

        #expect(display.uuid == "10FF0FFF-0000-0000-7777-333311112222")
        #expect(warning == nil)
    }

    @Test("UUID hyphens are optional")
    func uuidHyphensOptional() throws {
        let displays = mockDisplays()
        let spec = try DisplaySpecifier.parse("uuid=10FF0FFF000000007777333311112222")
        let (display, warning) = try DisplayMatcher.selectDisplay(
            from: displays,
            specifier: spec
        )

        #expect(display.uuid == "10FF0FFF-0000-0000-7777-333311112222")
        #expect(warning == nil)
    }

    @Test("UUID no match throws error")
    func uuidNoMatch() {
        let displays = mockDisplays()
        #expect(throws: DispselError.self) {
            try DisplayMatcher.selectDisplay(
                from: displays,
                specifier: try DisplaySpecifier.parse("uuid=NONEXISTENT")
            )
        }
    }

    // MARK: - Product Name Matching Tests

    @Test("Product name exact match")
    func productNameExactMatch() throws {
        let displays = mockDisplays()
        let spec = try DisplaySpecifier.parse("productName=DELL U4025QW")
        let (display, warning) = try DisplayMatcher.selectDisplay(
            from: displays,
            specifier: spec
        )

        #expect(display.productName == "DELL U4025QW")
        #expect(warning == nil)
    }

    @Test("Product name is case sensitive")
    func productNameCaseSensitive() {
        let displays = mockDisplays()
        #expect(throws: DispselError.self) {
            try DisplayMatcher.selectDisplay(
                from: displays,
                specifier: try DisplaySpecifier.parse("productName=dell u4025qw")
            )
        }
    }

    @Test("Product name like partial match")
    func productNameLikePartialMatch() throws {
        let displays = mockDisplays()
        let spec = try DisplaySpecifier.parse("productNameLike=U4025QW")
        let (display, warning) = try DisplayMatcher.selectDisplay(
            from: displays,
            specifier: spec
        )

        #expect(display.productName == "DELL U4025QW")
        #expect(warning == nil)
    }

    @Test("Product name like is case insensitive")
    func productNameLikeCaseInsensitive() throws {
        let displays = mockDisplays()
        let spec = try DisplaySpecifier.parse("productNameLike=odyssey")
        let (display, warning) = try DisplayMatcher.selectDisplay(
            from: displays,
            specifier: spec
        )

        #expect(display.productName == "Samsung Odyssey")
        #expect(warning == nil)
    }

    // MARK: - Serial Number Matching Tests

    @Test("Serial number exact match")
    func serialNumberExactMatch() throws {
        let displays = mockDisplays()
        let spec = try DisplaySpecifier.parse("serialNumber=99XX99")
        let (display, warning) = try DisplayMatcher.selectDisplay(
            from: displays,
            specifier: spec
        )

        #expect(display.serialNumber == "99XX99")
        #expect(warning == nil)
    }

    @Test("Serial number is case sensitive")
    func serialNumberCaseSensitive() {
        let displays = mockDisplays()
        #expect(throws: DispselError.self) {
            try DisplayMatcher.selectDisplay(
                from: displays,
                specifier: try DisplaySpecifier.parse("serialNumber=99xx99")
            )
        }
    }

    // MARK: - Multiple Criteria Tests

    @Test("Multiple criteria use AND logic")
    func multipleCriteriaAND() throws {
        let displays = mockDisplays()
        let spec = try DisplaySpecifier.parse("productNameLike=DELL:serialNumber=99XX99")
        let (display, warning) = try DisplayMatcher.selectDisplay(
            from: displays,
            specifier: spec
        )

        #expect(display.productName == "DELL U4025QW")
        #expect(display.serialNumber == "99XX99")
        #expect(warning == nil)
    }

    @Test("Multiple criteria with no match")
    func multipleCriteriaNoMatch() {
        let displays = mockDisplays()
        // productNameLike matches DELL, but serialNumber doesn't
        #expect(throws: DispselError.self) {
            try DisplayMatcher.selectDisplay(
                from: displays,
                specifier: try DisplaySpecifier.parse("productNameLike=DELL:serialNumber=WRONG")
            )
        }
    }

    // MARK: - Multiple Matches Warning Tests

    @Test("Multiple matches produce warning")
    func multipleMatchesWarning() throws {
        let duplicateDisplays = [
            Display(
                uuid: "UUID1",
                manufacturerID: "DEL",
                productName: "DELL Monitor",
                serialNumber: "SN1",
                transportUpstream: nil,
                transportDownstream: nil,
                service: MockService()
            ),
            Display(
                uuid: "UUID2",
                manufacturerID: "DEL",
                productName: "DELL Monitor",
                serialNumber: "SN2",
                transportUpstream: nil,
                transportDownstream: nil,
                service: MockService()
            )
        ]

        let spec = try DisplaySpecifier.parse("productName=DELL Monitor")
        let (display, warning) = try DisplayMatcher.selectDisplay(
            from: duplicateDisplays,
            specifier: spec
        )

        #expect(display.uuid == "UUID1")  // First match
        #expect(warning != nil)
        #expect(warning?.contains("Multiple displays (2) matched") ?? false)
    }
}
