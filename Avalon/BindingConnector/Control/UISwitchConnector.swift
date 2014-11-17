//
//  UISwitchConnector.swift
//  Avalon
//
//  Created by Colin Eberhardt on 14/11/2014.
//  Copyright (c) 2014 Colin Eberhardt. All rights reserved.
//

import Foundation
import UIKit

class UISwitchConnector: UIControlBindingConnector {
  
  init?(source: NSObject, switchControl: UISwitch, binding: Binding) {
    super.init(source: source, destination: switchControl, valueExtractor: { switchControl.on }, binding: binding, events: UIControlEvents.ValueChanged)
    
    if binding.destinationProperty != "on" {
      ErrorSink.instance.logEvent("ERROR: view \(switchControl) does not support two-way binding, with binding \(binding)");
      return nil
    }
  }
}