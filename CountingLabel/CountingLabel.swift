//
//  CountingLabel.swift
//  CountingLabel
//
//  Created by Shannon Wu on 5/8/16.
//  Copyright © 2016 LLS iOS Team. All rights reserved.
//

import UIKit

enum CountingLabelAnimationOption
{
  case Linear
  case EaseIn
  case EaseOut
  case EaseInOut
  
  func update(value: CGFloat) -> CGFloat
  {
    let counterRate: Float = 3.0
    switch self
    {
    case .Linear:
      return value
    case .EaseIn:
      return CGFloat(powf(Float(value), counterRate))
    case .EaseOut:
      return 1 - CGFloat(powf(1 - Float(value), counterRate))
    case .EaseInOut:
      let sign = (Int(counterRate) % 2 == 0) ? -1 : 1
      let val = value * 2
      if (val < 1)
      {
        return 0.5 * CGFloat(powf(Float(val), counterRate))
      }
      else
      {
        return CGFloat(sign) * 0.5 * (CGFloat(powf(Float(val) - 2, counterRate)) + CGFloat(sign) * 2)
      }
    }
  }
}

typealias CountingLabelCompletionBlock = Void -> Void
typealias CountingLabelFormatBlock = (value: CGFloat) -> String
typealias CountingLabelAttributedFormatBlock = (value: CGFloat) -> NSAttributedString

class CountingLabel: UILabel
{
  var animationOption: CountingLabelAnimationOption = .Linear
  var animationDuration: NSTimeInterval = 2.0
  
  var formatBlock: CountingLabelFormatBlock?
  var attributedFormatBlock: CountingLabelAttributedFormatBlock?
  
  var completionBlock: CountingLabelCompletionBlock?
  
  func countFrom(from: CGFloat, to: CGFloat)
  {
    if animationDuration <= 0
    {
      animationDuration = 2.0
    }
    countFrom(from, to: to, duration: animationDuration)
  }
  
  func countFrom(from: CGFloat, to: CGFloat, duration: NSTimeInterval)
  {
    startValue = from
    endValue = to
    
    timer = nil
    
    if duration == 0
    {
      setTextValue(endValue)
      runCompletionBlock()
      return
    }
    
    easingRate = 3.0
    progress = 0
    totalTime = duration
    lastUpdate = NSDate.timeIntervalSinceReferenceDate()
    
    timer = CADisplayLink(target: self, selector: #selector(updateValue))
    timer.frameInterval = 1
    timer.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
  }
  
  func countFromCurrentValueTo(to: CGFloat)
  {
    countFrom(currentValue, to: to)
  }
  
  func countFromCurrentValueTo(to: CGFloat, duration: NSTimeInterval)
  {
    countFrom(currentValue, to: to, duration: duration)
  }
  
  func countFromZeroTo(to: CGFloat)
  {
    countFrom(0, to: to)
  }
  
  func countFromZeroTo(to: CGFloat, duration: NSTimeInterval)
  {
    countFrom(0, to: to, duration: duration)
  }
  
  private var startValue: CGFloat!
  private var endValue: CGFloat!
  private var progress: NSTimeInterval!
  private var lastUpdate: NSTimeInterval!
  private var totalTime: NSTimeInterval!
  private var easingRate: CGFloat!
  
  private var timer: CADisplayLink! {
    didSet {
      oldValue?.invalidate()
    }
  }
  
  private var currentValue: CGFloat {
    if progress >= totalTime
    {
      return endValue
    }
    
    let percent = CGFloat(progress / totalTime)
    let updateVal = animationOption.update(percent)
    return startValue + (updateVal * (endValue - startValue))
  }
  
  private func setTextValue(value: CGFloat)
  {
    if let attributedFormatBlock = attributedFormatBlock
    {
      attributedText = attributedFormatBlock(value: value)
    }
    else if let formatBlock = formatBlock
    {
      text = formatBlock(value: value)
    }
    else
    {
      assertionFailure("No formatter setted, please set one of the format properties, `formatBlock`, `attributedFormatBlock`")
    }
  }
  
  @objc private func updateValue()
  {
    let now = NSDate.timeIntervalSinceReferenceDate()
    progress = progress + (now - lastUpdate)
    lastUpdate = now
    
    if progress >= totalTime
    {
      timer = nil
      progress = totalTime
    }
    
    setTextValue(currentValue)
    
    if progress == totalTime
    {
      runCompletionBlock()
    }
  }
  
  private func runCompletionBlock()
  {
    completionBlock?()
    completionBlock = nil
  }
}
