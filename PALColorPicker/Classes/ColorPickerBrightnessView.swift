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

public protocol ColorPickerBrightnessViewDelegate: class {
    var colorPickerBrightnessViewColor: UIColor { get }
    var colorPickerBrightnessViewTintColor: UIColor { get }
    func colorPickerBrightnessViewUpdateColor(_ color: UIColor)
}

public class ColorPickerBrightnessView: UIView {
    public static let height: CGFloat = 28
    
    public weak var delegate: ColorPickerBrightnessViewDelegate?
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.alpha = 1
        return view
    }()
    
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
    
    private var point: CGPoint?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        self.addSubview(self.containerView)
        
        self.containerView.layer.insertSublayer(self.colorLayer, below: self.layer)
        self.containerView.layer.addSublayer(self.indicatorLayer)
        
        self.addConstraints([
            NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: self.containerView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: self.containerView, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: self.containerView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: self.containerView, attribute: .bottom, multiplier: 1, constant: 0)
            ])
        
        self.containerView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.gesture(_:))))
        self.containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.gesture(_:))))
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.colorLayer.frame.width != self.containerView.bounds.width {
            self.colorLayer.frame = CGRect(x: 0, y: 3, width: self.containerView.bounds.width, height: ColorPickerBrightnessView.height - 6)
        }
    }
    
    public func update() {
        self.indicatorLayer.strokeColor = self.delegate?.colorPickerBrightnessViewTintColor.cgColor ?? UIColor.lightGray.cgColor
        self.indicatorLayer.fillColor = self.delegate?.colorPickerBrightnessViewTintColor.cgColor ?? UIColor.lightGray.cgColor
        
        guard let color = self.delegate?.colorPickerBrightnessViewColor else { return }
        let hsb = color.hsb
        self.colorLayer.colors = [
            UIColor(hue: hsb.hue, saturation: hsb.saturation, brightness: 1, alpha: 1).cgColor,
            UIColor.black.cgColor
        ]
        self.updatePoint(CGPoint(x: (1 - hsb.brightness) * self.containerView.frame.width, y: self.containerView.frame.height / 2))
        self.indicatorLayer.drawRoundRectIndicator(self.point)
    }
    
    @objc private func gesture(_ gesture: UIGestureRecognizer) {
        guard var color = self.delegate?.colorPickerBrightnessViewColor else { return }
        let hsb = color.hsb
        
        let gesturePoint = gesture.location(in: self.containerView)
        self.updatePoint(CGPoint(x: gesturePoint.x, y: self.frame.height/2))
        
        guard let point = self.point else { return }
        let brightness = 1 - (point.x / self.frame.width)
        
        color = UIColor(hue: hsb.hue, saturation: hsb.saturation, brightness: brightness, alpha: 1)
        self.indicatorLayer.drawRoundRectIndicator(self.point)
        self.delegate?.colorPickerBrightnessViewUpdateColor(color)
    }
    
    private func updatePoint(_ point: CGPoint?) {
        guard var point = point else { return }
        if (point.x < 1) {
            point.x = 1
        } else if (point.x > self.frame.size.width - 1 ) {
            point.x = self.frame.size.width - 1
        }
        self.point = point
    }
}
