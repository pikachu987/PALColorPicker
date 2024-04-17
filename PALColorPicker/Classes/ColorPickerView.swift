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

public protocol ColorPickerViewDelegate: AnyObject {
    func colorPickerView(_ color: UIColor)
}

open class ColorPickerView: UIView {
    public weak var delegate: ColorPickerViewDelegate?
    
    public var color: UIColor {
        set {
            internalColor = newValue
            colorPaletteView.color = newValue
            colorBrightnessView.color = newValue
        }
        get {
            internalColor
        }
    }

    public var betweenPaletteAndBrightnessMargin: CGFloat = 10 {
        didSet {
            paletteAndBrightnessConstraint?.constant = -betweenPaletteAndBrightnessMargin
        }
    }

    public var brightnessHeight: CGFloat = 28 {
        didSet {
            brightnessHeightConstraint?.constant = -brightnessHeight
        }
    }

    public var paletteIndicatorNormalRadius: CGFloat {
        set { colorPaletteView.indicatorNormalRadius = newValue }
        get { colorPaletteView.indicatorNormalRadius }
    }

    public var paletteIndicatorTouchRadius: CGFloat {
        set { colorPaletteView.indicatorTouchRadius = newValue }
        get { colorPaletteView.indicatorTouchRadius }
    }

    public var paletteIndicatorColor: UIColor {
        set { colorPaletteView.indicatorColor = newValue }
        get { colorPaletteView.indicatorColor }
    }

    public var paletteBrightnessColor: UIColor {
        set { colorPaletteView.brightnessColor = newValue }
        get { colorPaletteView.brightnessColor }
    }

    public var paletteIndicatorLineWidth: CGFloat {
        set { colorPaletteView.indicatorLineWidth = newValue }
        get { colorPaletteView.indicatorLineWidth }
    }

    public var brightnessLayerVerticalMargin: CGFloat {
        set { colorBrightnessView.layerVerticalMargin = newValue }
        get { colorBrightnessView.layerVerticalMargin }
    }

    public var brightnessIndicatorWidth: CGFloat {
        set { colorBrightnessView.indicatorWidth = newValue }
        get { colorBrightnessView.indicatorWidth }
    }

    public var brightnessIndicatorRadius: CGFloat {
        set { colorBrightnessView.indicatorRadius = newValue }
        get { colorBrightnessView.indicatorRadius }
    }

    public var brightnessIndicatorStrokeColor: UIColor {
        set { colorBrightnessView.indicatorStrokeColor = newValue }
        get { colorBrightnessView.indicatorStrokeColor }
    }

    public var brightnessIndicatorFillColor: UIColor {
        set { colorBrightnessView.indicatorFillColor = newValue }
        get { colorBrightnessView.indicatorFillColor }
    }

    private var internalColor: UIColor = .white

    private lazy var colorPaletteView: ColorPaletteView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(ColorPaletteView(paletteType: paletteType))

    private let colorBrightnessView: ColorBrightnessView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(ColorBrightnessView())

    private var paletteAndBrightnessConstraint: NSLayoutConstraint?
    private var brightnessHeightConstraint: NSLayoutConstraint?

    private let paletteType: ColorPaletteType

    public init(paletteType: ColorPaletteType) {
        self.paletteType = paletteType
        super.init(frame: .zero)

        setupViews()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = .clear

        translatesAutoresizingMaskIntoConstraints = false

        addSubview(colorBrightnessView)
        addSubview(colorPaletteView)

        addConstraints([
            NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: colorPaletteView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: colorPaletteView, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: colorPaletteView, attribute: .top, multiplier: 1, constant: 0)
        ])

        colorPaletteView.addConstraints([
            NSLayoutConstraint(item: colorPaletteView, attribute: .width, relatedBy: .equal, toItem: colorPaletteView, attribute: .height, multiplier: 1, constant: 0)
        ])

        let paletteAndBrightnessConstraint = NSLayoutConstraint(item: colorPaletteView, attribute: .bottom, relatedBy: .equal, toItem: colorBrightnessView, attribute: .top, multiplier: 1, constant: -betweenPaletteAndBrightnessMargin)
        self.paletteAndBrightnessConstraint = paletteAndBrightnessConstraint
        addConstraints([
            paletteAndBrightnessConstraint
        ])

        addConstraints([
            NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: colorBrightnessView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: colorBrightnessView, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: colorBrightnessView, attribute: .bottom, multiplier: 1, constant: 0).priority(950)
        ])

        let brightnessHeightConstraint = NSLayoutConstraint(item: colorBrightnessView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: brightnessHeight)
        self.brightnessHeightConstraint = brightnessHeightConstraint
        colorBrightnessView.addConstraints([
            brightnessHeightConstraint
        ])

        colorPaletteView.delegate = self
        colorBrightnessView.delegate = self
    }
}

// MARK: ColorPaletteViewDelegate
extension ColorPickerView: ColorPaletteViewDelegate {
    public func colorPaletteView(_ sender: ColorPaletteView, color: UIColor) {
        internalColor = color
        colorBrightnessView.color = color
        delegate?.colorPickerView(internalColor)
    }
}

// MARK: ColorBrightnessViewDelegate
extension ColorPickerView: ColorBrightnessViewDelegate {
    public func colorBrightnessView(_ sender: ColorBrightnessView, color: UIColor) {
        colorPaletteView.brightnessColor = color
    }
}
