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

public protocol ColorPickerWheelViewDelegate: class {
    var colorPickerWheelViewColor: UIColor { get }
    var colorPickerWheelViewTintColor: UIColor { get }
    func colorPickerWheelViewUpdateColor(_ color: UIColor)
    func colorPickerWheelViewLoadFinished()
}

public class ColorPickerWheelView: UIView {
    public weak var delegate: ColorPickerWheelViewDelegate?
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
    }()
    
    private var wheelLayer: CALayer = {
        let layer = CALayer()
        return layer
    }()
    
    private let brightnessLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()
    
    private let indicatorLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = 2
        layer.fillColor = nil
        return layer
    }()
    
    private var indicatorCircleRadius: CGFloat = 12.0
    private var point: CGPoint?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.containerView)
        
        self.containerView.layer.addSublayer(self.wheelLayer)
        self.containerView.layer.addSublayer(self.brightnessLayer)
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
        super.init(coder: aDecoder)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.wheelLayer.frame != self.containerView.bounds {
            self.wheelLayer.frame = self.containerView.bounds
            self.wheelLayer.makeContentsWheel {
                self.delegate?.colorPickerWheelViewLoadFinished()
                UIView.animate(withDuration: 0.1, animations: {
                    self.containerView.alpha = 1
                })
            }
            
            let path = UIBezierPath(
                roundedRect: CGRect(
                    x: 0,
                    y: 0,
                    width: self.containerView.bounds.width,
                    height: self.containerView.bounds.height),
                cornerRadius: self.containerView.bounds.height/2)
            self.brightnessLayer.path = path.cgPath
        }
    }
    
    public func update() {
        self.indicatorLayer.strokeColor = self.delegate?.colorPickerWheelViewTintColor.cgColor ?? UIColor.lightGray.cgColor
        
        guard let color = self.delegate?.colorPickerWheelViewColor else { return }
        let hsb = color.hsb
        self.updatePoint(self.wheelLayer.point(hue: hsb.hue, saturation: hsb.saturation))
        self.brightnessLayer.fillColor = UIColor(white: 0, alpha: 1.0 - hsb.brightness).cgColor
        self.indicatorLayer.drawCircleIndicator(self.point, color: color, radius: self.indicatorCircleRadius)
    }
    
    @objc private func gesture(_ gesture: UIGestureRecognizer) {
        guard var color = self.delegate?.colorPickerWheelViewColor else { return }
        let hsb = color.hsb
        
        let point = gesture.location(in: self.containerView)
        
        if gesture.state == .began {
            self.indicatorCircleRadius = 40
        } else if gesture.state == .ended || gesture.state == .failed || gesture.state == .cancelled {
            self.indicatorCircleRadius = 12
        }
        
        let indicator = self.wheelLayer.indicatorCoordinate(point)
        self.updatePoint(indicator.point)
        
        let hueSaturation: (hue: CGFloat, saturation: CGFloat) =
            indicator.isCenter ? (0, 0) :
                self.wheelLayer.hueSaturation(
                    position: CGPoint(
                        x: point.x*UIScreen.main.scale,
                        y: point.y*UIScreen.main.scale
                    )
        )
        
        color = UIColor(hue: hueSaturation.hue, saturation: hueSaturation.saturation, brightness: hsb.brightness, alpha: 1)
        self.indicatorLayer.drawCircleIndicator(self.point, color: color, radius: self.indicatorCircleRadius)
        self.delegate?.colorPickerWheelViewUpdateColor(color)
    }
    
    private func updatePoint(_ point: CGPoint?) {
        guard let point = point else { return }
        if (pow((point.x-self.containerView.frame.size.width/2), 2) + pow((point.y - self.containerView.frame.size.height/2), 2) < pow((self.containerView.frame.size.width/2), 2)) {
            self.point = point
        }
    }
}
