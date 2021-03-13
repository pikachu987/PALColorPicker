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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let view = ColorPickerView(frame: CGRect(x: 20, y: 100, width: UIScreen.main.bounds.width - 40, height: 400))
        view.tintColor = .green
        self.view.addSubview(view)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
