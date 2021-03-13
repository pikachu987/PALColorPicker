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

extension CAShapeLayer {
    func drawCircleIndicator(_ point: CGPoint?, color: UIColor, radius: CGFloat) {
        guard let point = point else { return }
        let path = UIBezierPath(
            roundedRect: CGRect(
                x: point.x - radius,
                y: point.y - radius,
                width: radius * 2,
                height: radius * 2),
            cornerRadius: radius)
        self.path = path.cgPath
        self.fillColor = color.cgColor
    }
    
    func drawRoundRectIndicator(_ point: CGPoint?) {
        guard let point = point else { return }
        let path = UIBezierPath(
            roundedRect: CGRect(x: point.x-3, y: 0, width: 6, height: ColorPickerBrightnessView.height),
            cornerRadius: 3)
        self.path = path.cgPath
    }
}
