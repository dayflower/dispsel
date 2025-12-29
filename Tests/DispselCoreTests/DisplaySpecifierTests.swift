import Testing
@testable import DispselCore

@Suite("Display Specifier Tests")
struct DisplaySpecifierTests {
    // MARK: - UUID Specifier Tests

    @Test("Parse UUID specifier with field name")
    func uuidSpecifierWithFieldName() throws {
        let spec = try DisplaySpecifier.parse("uuid=ABC123")
        #expect(spec.criteria.count == 1)

        guard case .uuid(let value) = spec.criteria[0] else {
            Issue.record("Expected uuid criterion")
            return
        }
        #expect(value == "ABC123")
    }

    @Test("Parse UUID specifier without field name")
    func uuidSpecifierWithoutFieldName() throws {
        let spec = try DisplaySpecifier.parse("ABC123")
        #expect(spec.criteria.count == 1)

        guard case .uuid(let value) = spec.criteria[0] else {
            Issue.record("Expected uuid criterion")
            return
        }
        #expect(value == "ABC123")
    }

    // MARK: - Product Name Specifier Tests

    @Test("Parse product name exact match")
    func productNameExact() throws {
        let spec = try DisplaySpecifier.parse("productName=DELL U4025QW")
        #expect(spec.criteria.count == 1)

        guard case .productName(let value) = spec.criteria[0] else {
            Issue.record("Expected productName criterion")
            return
        }
        #expect(value == "DELL U4025QW")
    }

    @Test("Parse product name like match")
    func productNameLike() throws {
        let spec = try DisplaySpecifier.parse("productNameLike=U4025QW")
        #expect(spec.criteria.count == 1)

        guard case .productNameLike(let value) = spec.criteria[0] else {
            Issue.record("Expected productNameLike criterion")
            return
        }
        #expect(value == "U4025QW")
    }

    // MARK: - Serial Number Specifier Tests

    @Test("Parse serial number specifier")
    func serialNumber() throws {
        let spec = try DisplaySpecifier.parse("serialNumber=99XX99")
        #expect(spec.criteria.count == 1)

        guard case .serialNumber(let value) = spec.criteria[0] else {
            Issue.record("Expected serialNumber criterion")
            return
        }
        #expect(value == "99XX99")
    }

    // MARK: - Multiple Criteria Tests

    @Test("Parse multiple criteria")
    func multipleCriteria() throws {
        let spec = try DisplaySpecifier.parse("productNameLike=U4025QW:serialNumber=99XX99")
        #expect(spec.criteria.count == 2)

        guard case .productNameLike(let name) = spec.criteria[0],
              case .serialNumber(let serial) = spec.criteria[1] else {
            Issue.record("Expected productNameLike and serialNumber criteria")
            return
        }

        #expect(name == "U4025QW")
        #expect(serial == "99XX99")
    }

    @Test("Parse three criteria")
    func threeCriteria() throws {
        let spec = try DisplaySpecifier.parse("uuid=ABC:productName=DELL:serialNumber=123")
        #expect(spec.criteria.count == 3)
    }

    // MARK: - Whitespace Handling Tests

    @Test("Handle whitespace around specifier")
    func whitespaceHandling() throws {
        let spec = try DisplaySpecifier.parse("  uuid=ABC123  ")
        #expect(spec.criteria.count == 1)

        guard case .uuid(let value) = spec.criteria[0] else {
            Issue.record("Expected uuid criterion")
            return
        }
        #expect(value == "ABC123")
    }

    @Test("Handle whitespace around equals sign")
    func whitespaceAroundEquals() throws {
        let spec = try DisplaySpecifier.parse("uuid = ABC123")
        #expect(spec.criteria.count == 1)

        guard case .uuid(let value) = spec.criteria[0] else {
            Issue.record("Expected uuid criterion")
            return
        }
        #expect(value == "ABC123")
    }

    // MARK: - Error Cases

    @Test("Invalid field name throws error")
    func invalidFieldName() {
        #expect(throws: DispselError.self) {
            try DisplaySpecifier.parse("invalid=value")
        }
    }

    @Test("Empty specifier throws error")
    func emptySpecifier() {
        #expect(throws: DispselError.self) {
            try DisplaySpecifier.parse("")
        }
    }

    @Test("Malformed equals throws error")
    func malformedEquals() {
        #expect(throws: DispselError.self) {
            try DisplaySpecifier.parse("uuid=")
        }
    }
}
