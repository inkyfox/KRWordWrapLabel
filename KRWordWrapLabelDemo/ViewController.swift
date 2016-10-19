//
//  ViewController.swift
//  KRWordWrapLabelApp
//
//  Created by Yoo YongHa on 2016. 3. 5..
//  Copyright © 2016년 Gen X Hippies Company. All rights reserved.
//

import UIKit
import KRWordWrapLabel

class ViewController: UIViewController {
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var label: KRWordWrapLabel!
    
    @IBOutlet weak var alignmentSegment: UISegmentedControl!
    @IBOutlet weak var maxLinesStepper: UIStepper!
    @IBOutlet weak var fontSizeStepper: UIStepper!
    @IBOutlet weak var minFontScaleStepper: UIStepper!
    @IBOutlet weak var widthStepper: UIStepper!
    
    @IBOutlet weak var maxLinesLabel: UILabel!
    @IBOutlet weak var fontSizeLabel: UILabel!
    @IBOutlet weak var minFontScaleLabel: UILabel!
    @IBOutlet weak var widthLabel: UILabel!
    
    @IBOutlet weak var labelWidthConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        labelWidthConstraint.constant = min(CGFloat(widthStepper.maximumValue), (self.view.window?.frame.width ?? 320) - 48)
        widthStepper.value = Double(labelWidthConstraint.constant)
        widthLabel.text = "\(widthStepper.value)"
    }
    
    fileprivate func updateLabel() {
        let index = alignmentSegment.selectedSegmentIndex
        label.textAlignment = index == 1 ? .center : index == 2 ? .right: .left
        label.numberOfLines = Int(maxLinesStepper.value)
        label.font = label.font.withSize(CGFloat(fontSizeStepper.value))
        label.minimumScaleFactor = CGFloat(minFontScaleStepper.value)
        
        maxLinesLabel.text = "\(label.numberOfLines)"
        fontSizeLabel.text = "\(label.font.pointSize)"
        minFontScaleLabel.text = NSString(format: "%.01f", label.minimumScaleFactor) as String
        
    }
    
    @IBAction func updateLabel(_ sender: AnyObject) {
        updateLabel()
    }
    
    
    @IBAction func updateWidth(_ sender: AnyObject) {
        labelWidthConstraint.constant = CGFloat(widthStepper.value)
        widthLabel.text = "\(widthStepper.value)"
    }
    
}

