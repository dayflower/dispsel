import Testing
@testable import DispselCore

@Suite("Input Source Resolver Tests")
struct InputSourceResolverTests {
    // MARK: - Keyword Resolution Tests

    @Test("Resolve DisplayPort keywords")
    func keywordResolutionDisplayPort() throws {
        let dp = try InputSourceResolver.resolve("dp")
        #expect(dp.value == 0x0f)
        #expect(dp.canonicalName == "displayport1")

        let displayport = try InputSourceResolver.resolve("displayport")
        #expect(displayport.value == 0x0f)
        #expect(displayport.canonicalName == "displayport1")

        let dp1 = try InputSourceResolver.resolve("dp1")
        #expect(dp1.value == 0x0f)
        #expect(dp1.canonicalName == "displayport1")

        let dp2 = try InputSourceResolver.resolve("dp2")
        #expect(dp2.value == 0x10)
        #expect(dp2.canonicalName == "displayport2")
    }

    @Test("Resolve HDMI keywords")
    func keywordResolutionHDMI() throws {
        let hdmi = try InputSourceResolver.resolve("hdmi")
        #expect(hdmi.value == 0x17)
        #expect(hdmi.canonicalName == "hdmi1")

        let hdmi1 = try InputSourceResolver.resolve("hdmi1")
        #expect(hdmi1.value == 0x17)

        let hdmi2 = try InputSourceResolver.resolve("hdmi2")
        #expect(hdmi2.value == 0x18)
    }

    @Test("Resolve Thunderbolt keywords")
    func keywordResolutionThunderbolt() throws {
        let usb = try InputSourceResolver.resolve("usb")
        #expect(usb.value == 0x25)
        #expect(usb.canonicalName == "thunderbolt1")

        let thunderbolt = try InputSourceResolver.resolve("thunderbolt")
        #expect(thunderbolt.value == 0x25)

        let usb2 = try InputSourceResolver.resolve("usb2")
        #expect(usb2.value == 0x27)
        #expect(usb2.canonicalName == "thunderbolt2")
    }

    @Test("Keyword matching is case insensitive")
    func keywordCaseInsensitive() throws {
        let upperDP = try InputSourceResolver.resolve("DP")
        #expect(upperDP.value == 0x0f)

        let mixedHDMI = try InputSourceResolver.resolve("Hdmi")
        #expect(mixedHDMI.value == 0x17)

        let upperUSB = try InputSourceResolver.resolve("USB")
        #expect(upperUSB.value == 0x25)
    }

    // MARK: - Hex Resolution Tests

    @Test("Resolve hexadecimal input sources")
    func hexResolution() throws {
        let hex0f = try InputSourceResolver.resolve("0x0f")
        #expect(hex0f.value == 0x0f)
        #expect(hex0f.canonicalName == "displayport1")

        let hex17 = try InputSourceResolver.resolve("0x17")
        #expect(hex17.value == 0x17)
        #expect(hex17.canonicalName == "hdmi1")

        let hexUppercase = try InputSourceResolver.resolve("0x0F")
        #expect(hexUppercase.value == 0x0f)
    }

    @Test("Resolve unknown hexadecimal values")
    func hexResolutionUnknown() throws {
        let unknown = try InputSourceResolver.resolve("0xFF")
        #expect(unknown.value == 0xFF)
        #expect(unknown.canonicalName == "unknown")
    }

    // MARK: - Decimal Resolution Tests

    @Test("Resolve decimal input sources")
    func decimalResolution() throws {
        let decimal15 = try InputSourceResolver.resolve("15")
        #expect(decimal15.value == 15)
        #expect(decimal15.canonicalName == "displayport1")

        let decimal23 = try InputSourceResolver.resolve("23")
        #expect(decimal23.value == 23)
        #expect(decimal23.canonicalName == "hdmi1")
    }

    @Test("Resolve unknown decimal values")
    func decimalResolutionUnknown() throws {
        let unknown = try InputSourceResolver.resolve("255")
        #expect(unknown.value == 255)
        #expect(unknown.canonicalName == "unknown")
    }

    // MARK: - Error Cases

    @Test("Invalid keyword throws error")
    func invalidKeyword() {
        #expect(throws: DispselError.self) {
            try InputSourceResolver.resolve("invalid")
        }
    }

    @Test("Invalid hex throws error")
    func invalidHex() {
        #expect(throws: (any Error).self) {
            try InputSourceResolver.resolve("0xGG")
        }
    }

    // MARK: - fromValue Tests

    @Test("Create InputSource from value")
    func fromValue() {
        let dp = InputSourceResolver.fromValue(0x0f)
        #expect(dp.value == 0x0f)
        #expect(dp.canonicalName == "displayport1")

        let hdmi = InputSourceResolver.fromValue(0x17)
        #expect(hdmi.value == 0x17)
        #expect(hdmi.canonicalName == "hdmi1")

        let unknown = InputSourceResolver.fromValue(0xFF)
        #expect(unknown.value == 0xFF)
        #expect(unknown.canonicalName == "unknown")
    }

    // MARK: - Formatted Output Tests

    @Test("Format input source for display")
    func formattedOutput() throws {
        let dp = try InputSourceResolver.resolve("dp")
        #expect(dp.formatted == "displayport1 (0x0f)")

        let hdmi = try InputSourceResolver.resolve("hdmi2")
        #expect(hdmi.formatted == "hdmi2 (0x18)")
    }
}
