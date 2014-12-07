//
//  ValueConverter.swift
//  MvvmSwift
//
//  Created by Colin Eberhardt on 05/11/2014.
//  Copyright (c) 2014 Colin Eberhardt. All rights reserved.
//

import Foundation



/// Provides a mechanism for transforming values that are applied via bindings.
@objc public class ValueConverter: NSObject {
  // subclasses NSObject and annotated @objc so that we can generate the
  // class instances from strings

  // TODO: This needs a simpler signature
  // TODO: Handle two-way value conversion
  public func convert(sourceValue: AnyObject?, binding: Binding, viewModel: AnyObject) -> AnyObject? {
    return nil
  }
}