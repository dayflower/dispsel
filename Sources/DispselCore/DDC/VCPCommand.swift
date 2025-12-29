import Foundation

/// VCP (Virtual Control Panel) command codes
public enum VCPCode: UInt8 {
    /// Input source selection (read/write)
    case inputSource = 0x60
    /// KVM switch control (write)
    case kvmSwitch = 0xE7
}

/// Predefined VCP values for specific commands
public struct VCPValue {
    /// Value to write to VCP 0xE7 for KVM next operation
    public static let kvmNext: UInt16 = 0xff00
}
