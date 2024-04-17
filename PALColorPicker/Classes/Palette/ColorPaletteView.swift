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

public protocol ColorPaletteViewDelegate: AnyObject {
    func colorPaletteView(_ sender: ColorPaletteView, color: UIColor)
}

public class ColorPaletteView: UIView {
    public weak var delegate: ColorPaletteViewDelegate?

    public override var bounds: CGRect {
        didSet {
            guard bounds.width != 0 && bounds.height != 0 else { return }
            setupLayerFrame()
        }
    }

    public var indicatorNormalRadius: CGFloat = 12 {
        didSet {
            updateIndicatorRadius()
        }
    }

    public var indicatorTouchRadius: CGFloat = 40 {
        didSet {
            updateIndicatorRadius()
        }
    }

    public var indicatorColor: UIColor = .blue {
        didSet {
            updateIndicatorColor()
            updateIndicatorRadius()
        }
    }

    public var brightnessColor: UIColor = .white {
        didSet {
            updateBrightnessColor()
            updateIndicatorColor()
            updateIndicatorRadius()
            guard bounds.width != 0 && bounds.height != 0 else { return }
            delegate?.colorPaletteView(self, color: color)
        }
    }

    public var indicatorLineWidth: CGFloat = 2 {
        didSet {
            indicatorLayer.lineWidth = indicatorLineWidth
        }
    }

    public var color: UIColor {
        set {
            if bounds.width != 0 && bounds.height != 0 {
                updateColor(newValue)
            } else {
                changeColorWhereBeforeSetupBound = newValue
            }
        }
        get {
            let touchPointData = paletteControl.touchPointData(at: point)
            let hsb = brightnessColor.hsb
            let color = UIColor(hue: touchPointData.hue, saturation: touchPointData.saturation, brightness: hsb.brightness, alpha: 1)
            return color
        }
    }

    public var changeColorWhereBeforeSetupBound: UIColor?

    private let colorLayer = CALayer()
    private let brightnessLayer = CAShapeLayer()
    private lazy var indicatorLayer: CAShapeLayer = {
        $0.lineWidth = indicatorLineWidth
        $0.fillColor = nil
        return $0
    }(CAShapeLayer())
    private var paletteControl: ColorPaletteControl
    private var point: CGPoint = .zero
    private var touchType: IndicatorTouchType = .normal

    public init(paletteType: ColorPaletteType) {
        switch paletteType {
        case .circle:
            paletteControl = ColorCirclePaletteControl()
        case .rectangle(let hueHorizontal):
            paletteControl = ColorRectanglePaletteControl(hueHorizontal: hueHorizontal)
        }
        super.init(frame: .zero)

        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ColorPaletteView {
    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false

        layer.addSublayer(colorLayer)
        layer.addSublayer(brightnessLayer)
        layer.addSublayer(indicatorLayer)

        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(gesture(_:))))
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gesture(_:))))
        updateIndicatorColor()
        updateIndicatorRadius()
        updateBrightnessColor()
    }

    private func setupLayerFrame() {
        colorLayer.frame = bounds
        paletteControl.bounds = colorLayer.frame
        colorLayer.contents = paletteControl.contents
        brightnessLayer.path = paletteControl.brightnessPath.cgPath
        if let changeColorWhereBeforeSetupBound = changeColorWhereBeforeSetupBound {
            updateColor(changeColorWhereBeforeSetupBound)
            self.changeColorWhereBeforeSetupBound = nil
        } else {
            point = paletteControl.initializePoint
            updateIndicatorRadius()
        }
        delegate?.colorPaletteView(self, color: color)
    }

    private func updateIndicatorColor() {
        indicatorLayer.strokeColor = indicatorColor.cgColor
    }

    private func touchTypeToRadius() -> CGFloat {
        switch touchType {
        case .normal: return indicatorNormalRadius
        case .touch: return indicatorTouchRadius
        }
    }

    private func updateIndicatorRadius(color: UIColor? = nil) {
        indicatorLayer.drawCircleIndicator(point, color: color ?? .clear, radius: touchTypeToRadius())
    }

    private func updateBrightnessColor() {
        let hsb = brightnessColor.hsb
        brightnessLayer.fillColor = UIColor(white: 0, alpha: 1.0 - hsb.brightness).cgColor
    }

    private func updateColor(_ color: UIColor) {
        let hsb = color.hsb
        point = paletteControl.point(hue: hsb.hue, saturation: hsb.saturation)
        updateIndicatorRadius()
        brightnessLayer.fillColor = UIColor(white: 0, alpha: 1.0 - hsb.brightness).cgColor
    }
}

extension ColorPaletteView {
    private func updatePoint(_ point: CGPoint) {
        if paletteControl.contains(at: point) {
            self.point = point
        }
    }

    @objc private func gesture(_ gesture: UIGestureRecognizer) {
        var indicatorColor: UIColor?
        switch gesture.state {
        case .began:
            touchType = .touch
        case .changed:
            touchType = .touch
            indicatorColor = color
        case .ended, .failed, .cancelled:
            touchType = .normal
        default: break
        }

        let point = gesture.location(in: self)
        let touchPointData = paletteControl.touchPointData(at: point)
        updatePoint(touchPointData.point)
        updateIndicatorRadius(color: indicatorColor)
        delegate?.colorPaletteView(self, color: color)
    }
}

extension ColorPaletteView {
    enum IndicatorTouchType {
        case normal
        case touch
    }
}
