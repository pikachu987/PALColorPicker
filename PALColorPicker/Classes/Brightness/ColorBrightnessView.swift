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

public protocol ColorBrightnessViewDelegate: AnyObject {
    func colorBrightnessView(_ sender: ColorBrightnessView, color: UIColor)
}

public class ColorBrightnessView: UIView {
    public weak var delegate: ColorBrightnessViewDelegate?

    public override var bounds: CGRect {
        didSet {
            guard bounds.width != 0 && bounds.height != 0 else { return }
            updateLayerFrame()
            updateIndicatorLayer()
        }
    }

    public var layerVerticalMargin: CGFloat = 3 {
        didSet {
            guard bounds.width != 0 && bounds.height != 0 else { return }
            updateLayerFrame()
            updateIndicatorLayer()
        }
    }

    public var indicatorWidth: CGFloat = 6 {
        didSet {
            updateIndicatorLayer()
        }
    }

    public var indicatorRadius: CGFloat = 3 {
        didSet {
            updateIndicatorLayer()
        }
    }

    public var indicatorStrokeColor: UIColor = .lightGray {
        didSet {
            indicatorLayer.strokeColor = indicatorStrokeColor.cgColor
        }
    }

    public var indicatorFillColor: UIColor = .gray {
        didSet {
            indicatorLayer.fillColor = indicatorFillColor.cgColor
        }
    }

    private let colorLayer: CAGradientLayer = {
        let colorLayer = CAGradientLayer()
        colorLayer.locations = [0.0, 1.0]
        colorLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        colorLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        return colorLayer
    }()
    
    private let indicatorLayer: CAShapeLayer = {
        let indicatorLayer = CAShapeLayer()
        indicatorLayer.lineWidth = 2
        return indicatorLayer
    }()
    
    private var point: CGPoint = .zero {
        didSet {
            updateIndicatorLayer()
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public var color: UIColor = .white {
        didSet {
            let hsb = color.hsb
            colorLayer.colors = [
                UIColor(hue: hsb.hue, saturation: hsb.saturation, brightness: 1, alpha: 1).cgColor,
                UIColor.black.cgColor
            ]
            updatePoint(CGPoint(x: (1 - hsb.brightness) * frame.width, y: frame.height / 2))
        }
    }
}

extension ColorBrightnessView {
    private func setupViews() {
        backgroundColor = .clear

        layer.insertSublayer(colorLayer, below: layer)
        layer.addSublayer(indicatorLayer)

        indicatorLayer.strokeColor = indicatorStrokeColor.cgColor
        indicatorLayer.fillColor = indicatorFillColor.cgColor

        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(gesture(_:))))
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gesture(_:))))
    }

    private func updateLayerFrame() {
        colorLayer.frame = CGRect(x: 0, y: layerVerticalMargin, width: bounds.width, height: bounds.height - (layerVerticalMargin * 2))
    }

    private func updateIndicatorLayer() {
        indicatorLayer.drawRoundRectIndicator(point, width: indicatorWidth, height: bounds.height, radius: indicatorRadius)
    }
}

extension ColorBrightnessView {
    private func updatePoint(_ point: CGPoint) {
        if (point.x < 1) {
            self.point = .init(x: 1, y: point.y)
            return
        }
        if (point.x > frame.size.width - 1) {
            self.point = .init(x: frame.size.width - 1, y: point.y)
            return
        }
        self.point = point
    }

    @objc private func gesture(_ gesture: UIGestureRecognizer) {
        let gesturePoint = gesture.location(in: self)
        updatePoint(CGPoint(x: gesturePoint.x, y: frame.height/2))
        let brightness = 1 - (point.x / frame.width)
        let hsb = color.hsb
        let color = UIColor(hue: hsb.hue, saturation: hsb.saturation, brightness: brightness, alpha: 1)
        delegate?.colorBrightnessView(self, color: color)
    }
}
