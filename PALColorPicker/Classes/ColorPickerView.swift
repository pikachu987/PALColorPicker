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

public protocol ColorPickerViewDelegate: class {
    func colorPickerView(_ color: UIColor)
}

open class ColorPickerView: UIView {
    public weak var delegate: ColorPickerViewDelegate?
    
    private(set) var color: UIColor = .white
    
    public let colorPickerWheelView: ColorPickerWheelView = {
        let colorPickerWheelView = ColorPickerWheelView(frame: .zero)
        colorPickerWheelView.translatesAutoresizingMaskIntoConstraints = false
        return colorPickerWheelView
    }()
    
    public let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .gray)
        activityIndicatorView.color = UIColor(light: .black, dark: .white)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }()

    public let colorPickerBrightnessView: ColorPickerBrightnessView = {
        let colorPickerBrightnessView = ColorPickerBrightnessView(frame: .zero)
        colorPickerBrightnessView.translatesAutoresizingMaskIntoConstraints = false
        colorPickerBrightnessView.alpha = 0
        return colorPickerBrightnessView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        self.colorPickerWheelView.delegate = self
        self.colorPickerBrightnessView.delegate = self
        
        self.addSubview(self.colorPickerWheelView)
        self.addSubview(self.activityIndicatorView)
        self.addSubview(self.colorPickerBrightnessView)
        
        self.addConstraints([
            NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: self.colorPickerWheelView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: self.colorPickerWheelView, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: self.colorPickerWheelView, attribute: .top, multiplier: 1, constant: 0)
            ])
        
        self.colorPickerWheelView.addConstraint(NSLayoutConstraint(item: self.colorPickerWheelView, attribute: .width, relatedBy: .equal, toItem: self.colorPickerWheelView, attribute: .height, multiplier: 1, constant: 0))
        
        self.addConstraints([
            NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: self.colorPickerBrightnessView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: self.colorPickerBrightnessView, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: self.colorPickerBrightnessView, attribute: .bottom, multiplier: 1, constant: 0)
            ])
        
        self.addConstraints([
            NSLayoutConstraint(item: self.colorPickerWheelView, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: self.colorPickerBrightnessView, attribute: .top, multiplier: 1, constant: 0).priority(950)
            ])
        
        self.colorPickerBrightnessView.addConstraint(NSLayoutConstraint(item: self.colorPickerBrightnessView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: ColorPickerBrightnessView.height))
        
        self.addConstraints([
            NSLayoutConstraint(item: self.colorPickerWheelView, attribute: .centerX, relatedBy: .equal, toItem: self.activityIndicatorView, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.colorPickerWheelView, attribute: .centerY, relatedBy: .equal, toItem: self.activityIndicatorView, attribute: .centerY, multiplier: 1, constant: 0)
            ])
        
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.isHidden = false
        
        DispatchQueue.main.async {
            self.colorPickerWheelView.update()
            self.colorPickerBrightnessView.update()
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open func updateColor(_ color: UIColor) {
        self.color = color
        self.colorPickerWheelView.update()
        self.colorPickerBrightnessView.update()
        self.delegate?.colorPickerView(self.color)
    }
}

// MARK: ColorPickerWheelViewDelegate
extension ColorPickerView: ColorPickerWheelViewDelegate {
    public var colorPickerWheelViewColor: UIColor {
        return self.color
    }
    
    public var colorPickerWheelViewTintColor: UIColor {
        return self.tintColor
    }
    
    public func colorPickerWheelViewUpdateColor(_ color: UIColor) {
        self.color = color
        self.colorPickerBrightnessView.update()
        self.delegate?.colorPickerView(self.color)
    }
    
    public func colorPickerWheelViewLoadFinished() {
        self.activityIndicatorView.stopAnimating()
        self.activityIndicatorView.isHidden = true
        UIView.animate(withDuration: 0.1) {
            self.colorPickerBrightnessView.alpha = 1
        }
    }
}

// MARK: ColorPickerBrightnessViewDelegate
extension ColorPickerView: ColorPickerBrightnessViewDelegate {
    public var colorPickerBrightnessViewColor: UIColor {
        return self.color
    }
    
    public var colorPickerBrightnessViewTintColor: UIColor {
        return self.tintColor
    }
    
    public func colorPickerBrightnessViewUpdateColor(_ color: UIColor) {
        self.color = color
        self.colorPickerWheelView.update()
        self.delegate?.colorPickerView(self.color)
    }
}
