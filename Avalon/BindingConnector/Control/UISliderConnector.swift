//
//  SliderControlConnector.swift
//  Avalon
//
//  Created by Colin Eberhardt on 10/11/2014.
//  Copyright (c) 2014 Colin Eberhardt. All rights reserved.
//

import Foundation
import UIKit

class UISliderConnector: UIControlBindingConnector {
  
  init?(source: NSObject, slider: UISlider, binding: Binding) {
    super.init(source: source, destination: slider, valueExtractor: { slider.value }, binding: binding)
    
    if binding.destinationProperty != "value" {
      ErrorSink.instance.logEvent("ERROR: view \(slider) does not support two-way binding, with binding \(binding)");
      return nil
    }
  }
}