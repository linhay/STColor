// MIT License
//
// Copyright (c) 2020 linhey
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import Combine

public struct StemColorAnalysis {
    
    public struct MMCQOption {
        
        public static let `default` = MMCQOption(filterTransparency: true, filterWhite: true, filterBlank: false)
        
        let filterTransparency: Bool
        let filterWhite: Bool
        let filterBlank: Bool
        
        public init(filterTransparency: Bool, filterWhite: Bool, filterBlank: Bool) {
            self.filterTransparency = filterTransparency
            self.filterWhite = filterWhite
            self.filterBlank = filterBlank
        }
    }

    public static func mmcqPublisher(_ data: StemColorImage, maxCount: Int, quality: Int, option: MMCQOption = .default) -> AnyPublisher<[StemColor], Never> {
        Future { callback in
            callback(.success(mmcq(StemColor.pixels(from: data), maxCount: maxCount, quality: quality)))
        }.eraseToAnyPublisher()
    }
    
    public static func mmcq(_ data: StemColorImage, maxCount: Int, quality: Int, option: MMCQOption = .default) -> [StemColor] {
        mmcq(StemColor.pixels(from: data), maxCount: maxCount, quality: quality)
    }
    
    public static func mmcq(_ data: [UInt8], maxCount: Int, quality: Int, option: MMCQOption = .default) -> [StemColor] {
        StemColor.RGBSpace.Unpack<UInt8>
            .array(fromRGBAs: data, filter: { rgb, alpha in
                if option.filterTransparency, alpha < 125 {
                    return false
                }
                if option.filterWhite, rgb.min() >= 250 {
                    return false
                }
                if option.filterBlank, rgb.max() <= 5 {
                    return false
                }
                return true
            })
            .mmcq(maxCount: maxCount, quality: quality)
            .map({ .init(rgb: .init($0), alpha: 1) })
    }
    
}

public extension Array where Element == StemColor {
    
    struct KmeansResult {
        public let center: Element
        public let size: Int
    }
    
    /// MMCQ (modified median cut quantization) algorithm from
    /// the Leptonica library (http://www.leptonica.com/).
    func mmcq(maxCount: Int, quality: Int) -> [StemColor] {
        return self.map(\.rgbSpace)
            .map({ $0.unpack(as: UInt8.self) })
            .mmcq(maxCount: maxCount, quality: quality)
            .map({ .init(rgb: .init($0), alpha: 1) })
    }
    
    /// k-均值算法
    /// - Parameters:
    ///   - count: 中心点数量
    ///   - formula: 颜色差异公式
    /// - Returns: 聚类颜色与比例
//    func kmeansClusterAnalysis(count: Int, difference formula: StemColor.DifferenceFormula) -> [KmeansResult] {
//        let kmeas = KMeans(self.map(\.labSpace.simd))
//        return kmeas.train(k: count) { lhs, rhs in
//            switch formula {
//            case .cie76:
//                return StemColor.difference(.cie76(.init(lhs), .init(rhs)))
//            case .cie94(let value):
//                return StemColor.difference(.cie94(.init(lhs), .init(rhs), value))
//            case .ciede2000:
//                return StemColor.difference(.ciede2000(.init(lhs), .init(rhs)))
//            case .euclidean:
//                /// 不划算
//                return StemColor.difference(.cie76(.init(lhs), .init(rhs)))
//            }
//        }.map { result in
//            KmeansResult(center: StemColor(lab: .init(result.center)), size: result.size)
//        }.sorted(by: { $0.size > $1.size })
//    }
    
}
