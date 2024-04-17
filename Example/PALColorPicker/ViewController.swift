//
//  ViewController.swift
//  PALColorPicker
//
//  Created by pikachu987 on 03/13/2021.
//  Copyright (c) 2021 pikachu987. All rights reserved.
//

import UIKit
import PALColorPicker

class ViewController: UIViewController {
//    let pickerView = ColorPickerView(paletteType: .circle)
//    let pickerView = ColorPickerView(paletteType: .rectangle(hueHorizontal: true))
    let pickerView = ColorPickerView(paletteType: .rectangle(hueHorizontal: false))
    let colorView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        colorView.translatesAutoresizingMaskIntoConstraints = false
        colorView.layer.borderColor = UIColor.black.cgColor
        colorView.layer.borderWidth = 1

        view.addSubview(pickerView)
        view.addSubview(colorView)

        view.addConstraints([
            NSLayoutConstraint(item: view!, attribute: .top, relatedBy: .equal, toItem: pickerView, attribute: .top, multiplier: 1, constant: -100),
            NSLayoutConstraint(item: view!, attribute: .leading, relatedBy: .equal, toItem: pickerView, attribute: .leading, multiplier: 1, constant: -20),
            NSLayoutConstraint(item: view!, attribute: .trailing, relatedBy: .equal, toItem: pickerView, attribute: .trailing, multiplier: 1, constant: 20)
        ])

        view.addConstraints([
            NSLayoutConstraint(item: pickerView, attribute: .bottom, relatedBy: .equal, toItem: colorView, attribute: .top, multiplier: 1, constant: -20),
            NSLayoutConstraint(item: view!, attribute: .leading, relatedBy: .equal, toItem: colorView, attribute: .leading, multiplier: 1, constant: -20)
        ])

        colorView.addConstraints([
            NSLayoutConstraint(item: colorView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 100),
            NSLayoutConstraint(item: colorView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 100),
        ])

//        pickerView.color = .green
        pickerView.betweenPaletteAndBrightnessMargin = 10
        pickerView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: ColorPickerViewDelegate {
    func colorPickerView(_ color: UIColor) {
        print(color)
        colorView.backgroundColor = color
    }
}
