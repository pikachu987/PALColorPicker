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

extension CALayer {
    func makeContentsWheel(callback: @escaping (() -> Void)) {
        let size = self.frame.size
        let scale = UIScreen.main.scale
        DispatchQueue.global().async {
            let dimension: CGFloat = size.width * scale
            let bufferLength = Int(dimension * dimension * 4)
            
            let bitmapData: CFMutableData = CFDataCreateMutable(nil, 0)
            CFDataSetLength(bitmapData, CFIndex(bufferLength))
            let bitmap = CFDataGetMutableBytePtr(bitmapData)
            
            for y in stride(from: CGFloat(0), to: dimension, by: CGFloat(1)) {
                for x in stride(from: CGFloat(0), to: dimension, by: CGFloat(1)) {
                    var hsbColor = UIColor()
                    
                    let hueSaturation = self.hueSaturation(position: CGPoint(x: x, y: y), scale: scale, width: size.width)
                    let hue = hueSaturation.hue
                    let saturation = hueSaturation.saturation
                    if (saturation < 1.0) {
                        let alpha = saturation > 0.99 ? (1.0 - saturation) * 100 : 1
                        hsbColor = UIColor(hue: hue, saturation: saturation, brightness: 1, alpha: alpha)
                    }
                    let rgb = hsbColor.rgb
                    let offset = Int(4 * (x + y * dimension))
                    bitmap?[offset] = UInt8(rgb.red*255)
                    bitmap?[offset + 1] = UInt8(rgb.green*255)
                    bitmap?[offset + 2] = UInt8(rgb.blue*255)
                    bitmap?[offset + 3] = UInt8(rgb.alpha*255)
                }
            }
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            guard let dataProvider = CGDataProvider(data: bitmapData) else { return }
            let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo().rawValue | CGImageAlphaInfo.last.rawValue)
            let imageRef = CGImage(
                width: Int(dimension),
                height: Int(dimension),
                bitsPerComponent: 8,
                bitsPerPixel: 32,
                bytesPerRow: Int(dimension) * 4,
                space: colorSpace,
                bitmapInfo: bitmapInfo,
                provider: dataProvider,
                decode: nil,
                shouldInterpolate: false,
                intent: CGColorRenderingIntent.defaultIntent)
            DispatchQueue.main.async {
                self.contents = imageRef
                callback()
            }
        }
    }
    
    private func hueSaturation(position: CGPoint, scale: CGFloat, width: CGFloat) -> (hue: CGFloat, saturation: CGFloat) {
        let c = width * scale / 2
        let dx = CGFloat(position.x - c) / c
        let dy = CGFloat(position.y - c) / c
        let saturation: CGFloat = sqrt(CGFloat (dx * dx + dy * dy))
        var hue: CGFloat
        if (saturation == 0) {
            hue = 0
        } else {
            hue = acos(dx/saturation) / CGFloat.pi / 2.0
            if (dy < 0) { hue = 1.0 - hue }
        }
        return (hue: hue, saturation: saturation)
    }
    
    func hueSaturation(position: CGPoint) -> (hue: CGFloat, saturation: CGFloat) {
        return self.hueSaturation(position: position, scale: UIScreen.main.scale, width: self.frame.size.width)
    }
    
    func point(hue: CGFloat, saturation: CGFloat) -> CGPoint {
        let dimension: CGFloat = self.frame.width
        let radius = saturation * dimension / 2
        let x = dimension / 2 + radius * cos(hue * CGFloat.pi * 2)
        let y = dimension / 2 + radius * sin(hue * CGFloat.pi * 2)
        return CGPoint(x: x, y: y)
    }
    
    func indicatorCoordinate(_ point: CGPoint) -> (point: CGPoint, isCenter: Bool) {
        let dimension: CGFloat = self.frame.width
        let radius = dimension/2
        let wheelLayerCenter = CGPoint(x: self.frame.origin.x + radius, y: self.frame.origin.y + radius)
        
        let dx = point.x - wheelLayerCenter.x
        let dy = point.y - wheelLayerCenter.y
        let distance = sqrt(dx*dx + dy*dy)
        var outputPoint = point
        
        if (distance > radius) {
            let theta: CGFloat = atan2(dy, dx)
            outputPoint.x = radius * cos(theta) + wheelLayerCenter.x
            outputPoint.y = radius * sin(theta) + wheelLayerCenter.y
        }
        let whiteThreshold: CGFloat = 10
        var isCenter = false
        if (distance < whiteThreshold) {
            outputPoint.x = wheelLayerCenter.x
            outputPoint.y = wheelLayerCenter.y
            isCenter = true
        }
        return (point: outputPoint, isCenter: isCenter)
    }
}
