//
//  File.swift
//
//
//  Created by linhey on 2022/6/6.
//

import Foundation

public extension StemColor {
    
    /// 十六进制色: 0x666666
    ///
    /// - Parameter str: "#666666" / "0X666666" / "0x666666"
    convenience init(_ value: String) {
        do {
            try self.init(throwing: value)
        } catch {
            print("Error initializing StemColor: \(error)")
            self.init(rgb: .init(red: 0, green: 0, blue: 0))
        }
    }
    
    /// 十六进制色: 0x666666
    ///
    /// - Parameter str: "#666666" / "0X666666" / "0x666666"
    convenience init(throwing value: String) throws {
        var string = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if string.hasPrefix("0X") {
            string = String(string.dropFirst(2))
        } else if string.hasPrefix("#") {
            string = String(string.dropFirst(1))
        }
        guard let parsedValue = UInt64(string, radix: 16) else {
            throw ThrowError("StemColor: 无效的十六进制颜色值。支持格式为 3 位 (RGB)、6 位 (RRGGBB)、或 8 位 (RRGGBBAA)。输入值: \(string)")
        }
        try self.init(throwing: parsedValue)
    }
    
    /// 十六进制色: 0x666666
    ///
    /// - Parameter RGBValue: 十六进制颜色
    convenience init(throwing value: UInt64) throws {
        let count: Int
        switch value {
        case 0x000...0xFFF:    count = 3
        case 0x00000...0xFFFFFF: count = 6
        case 0x00000000...0xFFFFFFFF: count = 8
        default:
            throw ThrowError("StemColor: 无效的十六进制颜色值。支持格式为 3 位 (RGB)、6 位 (RRGGBB)、或 8 位 (RRGGBBAA)。输入值: \(value)")
        }
        
        let a, r, g, b: UInt64
        switch count {
        case 3: // 0xRGB
            (a, r, g, b) = (255, (value >> 8) * 17, (value >> 4 & 0xF) * 17, (value & 0xF) * 17)
        case 6: // 0xRRGGBB
            (a, r, g, b) = (255, value >> 16, value >> 8 & 0xFF, value & 0xFF)
        case 8: // 0xRRGGBBAA
            (r, g, b, a) = (value >> 24, value >> 16 & 0xFF, value >> 8 & 0xFF, value & 0xFF)
        default:
            throw ThrowError("StemColor: 无效的十六进制颜色值。输入值: \(value)")
        }
        
        self.init(
            rgb: RGBSpace(
                red: min(max(Double(r) / 255.0, 0.0), 1.0),
                green: min(max(Double(g) / 255.0, 0.0), 1.0),
                blue: min(max(Double(b) / 255.0, 0.0), 1.0)
            ),
            alpha: min(max(Double(a) / 255.0, 0.0), 1.0)
        )
    }
}


public extension StemColor {
    
    enum HexFormatter {
        case auto
        case digits6
        case digits8
    }
    
    enum HexPrefixFormatter: String {
        /// "#"
        case hashKey = "#"
        /// "0x"
        case bits = "0x"
        /// ""
        case none = ""
    }
    
    func hexString(_ formatter: HexFormatter = .auto, prefix: HexPrefixFormatter = .hashKey) -> String {
        func map(_ value: Double) -> Int {
            if value.isNaN {
                return 255
            } else {
                return Int(round(value * 255))
            }
        }
        
        switch formatter {
        case .auto:
            return hexString(alpha >= 1 ? .digits6 : .digits8, prefix: prefix)
        case .digits6:
            return prefix.rawValue + String(format: "%02lX%02lX%02lX", map(rgbSpace.red), map(rgbSpace.green), map(rgbSpace.blue))
        case .digits8:
            return prefix.rawValue + String(format: "%02lX%02lX%02lX%02lX", map(alpha), map(rgbSpace.red), map(rgbSpace.green), map(rgbSpace.blue))
        }
    }
    
    /// 获取颜色16进制
    var uInt: UInt {
        var value: UInt = 0
        
        func map(_ value: Double) -> UInt {
            return UInt(round(value * 255))
        }
        
        value += map(alpha) << 24
        value += map(rgbSpace.red)   << 16
        value += map(rgbSpace.green) << 8
        value += map(rgbSpace.blue)
        return value
    }
    
}
