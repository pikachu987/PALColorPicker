//Copyright (c) 2021 pikachu987 <pikachu77769@gmail.com>
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.

import UIKit

final class ColorRectanglePaletteControl: ColorPaletteControl {
    private let hueHorizontal: Bool

    init(hueHorizontal: Bool = false) {
        self.hueHorizontal = hueHorizontal
    }
    
    var bounds: CGRect = .zero

    var initializePoint: CGPoint {
        CGPoint.zero
    }

    var brightnessPath: UIBezierPath {
        .init(rect: CGRect(origin: .zero, size: bounds.size))
    }

    var contents: CGImage? {
        var imageData = [UInt8](repeating: 1, count: (4 * intWidth * intHeight))
        for i in 0 ..< intWidth {
            for j in 0 ..< intHeight {
                let index = 4 * (i + j * intWidth)
                let (hue, saturation) = hueSaturation(at: CGPoint(x: i, y: j))
                let (r, g, b) = rgbFrom(hue: hue, saturation: saturation, brightness: 1)
                imageData[index] = colorComponentToUInt8(r)
                imageData[index + 1] = colorComponentToUInt8(g)
                imageData[index + 2] = colorComponentToUInt8(b)
                imageData[index + 3] = 255
            }
        }
        return UIImage(rgbaBytes: imageData, width: intWidth, height: intHeight)?.cgImage
    }

    func contains(at point: CGPoint) -> Bool {
        bounds.contains(point)
    }

    func touchPointData(at point: CGPoint) -> (point: CGPoint, hue: CGFloat, saturation: CGFloat) {
        let hueSaturation = hueSaturation(at: point)
        return (point, hueSaturation.hue, hueSaturation.saturation)
    }

    func point(hue: CGFloat, saturation: CGFloat) -> CGPoint {
        let x = (hueHorizontal ? hue : 1 - saturation) * bounds.width
        let y = (hueHorizontal ? 1 - saturation : hue) * bounds.height
        return CGPoint(x: x, y: y)
    }
}

extension ColorRectanglePaletteControl {
    private var intWidth: Int { Int(bounds.width) }
    private var intHeight: Int { Int(bounds.height) }

    private func hueSaturation(at point: CGPoint) -> (hue: CGFloat, saturation: CGFloat) {
        let hue = hueHorizontal ? point.x / bounds.width : point.y / bounds.height
        let saturation = hueHorizontal ? point.y / bounds.height : point.x / bounds.width
        return (max (0, min(1, hue)), 1 - max(0, min(1, saturation)))
    }

    private func colorComponentToUInt8(_ component: CGFloat) -> UInt8 {
        UInt8(max(0, min(255, round(255 * component))))
    }

    private func rgbFrom(hue: CGFloat, saturation: CGFloat, brightness: CGFloat) -> (red: CGFloat, green: CGFloat, blue: CGFloat) {
        let hPrime = Int(hue * 6)
        let f = hue * 6 - CGFloat(hPrime)
        let p = brightness * (1 - saturation)
        let q = brightness * (1 - f * saturation)
        let t = brightness * (1 - (1 - f) * saturation)

        switch hPrime % 6 {
        case 0: return (brightness, t, p)
        case 1: return (q, brightness, p)
        case 2: return (p, brightness, t)
        case 3: return (p, q, brightness)
        case 4: return (t, p, brightness)
        default: return (brightness, p, q)
        }
    }
}

fileprivate extension UIImage {
    convenience init?(rgbaBytes: [UInt8], width: Int, height: Int) {
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let data = Data(rgbaBytes)
        let mutableData = UnsafeMutableRawPointer.init(mutating: (data as NSData).bytes)
        let context = CGContext(data: mutableData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 4 * width, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapInfo.rawValue)
        guard let cgImage = context?.makeImage() else { return nil }
        self.init(cgImage: cgImage)
    }
}
