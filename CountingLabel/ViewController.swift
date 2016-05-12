//
//  ViewController.swift
//  CountingLabel
//
//  Created by Shannon Wu on 5/8/16.
//  Copyright © 2016 LLS iOS Team. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    let countingLabel = CountingLabel(frame: CGRectMake(10, 10, 200, 40))
    countingLabel.formatBlock = { return "\(Int($0)) Hi" }
    countingLabel.countFrom(0, to: 99)
    view.addSubview(countingLabel)
  }
}
