//
//  UITableView+Avalon.swift
//  Avalon
//
//  Created by Colin Eberhardt on 17/11/2014.
//  Copyright (c) 2014 Colin Eberhardt. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
  
  public var items: [NSObject] {
    get {
      return tableViewSource.items
    }
    set(newValue) {
      tableViewSource.items = newValue
    }
  }
  
  public var selectionAction: DataAction? {
    get {
      return objc_getAssociatedObject(self, &AssociationKey.action) as DataAction?
    }
    set(newValue) {
      objc_setAssociatedObject(self, &AssociationKey.action, newValue, UInt(OBJC_ASSOCIATION_RETAIN))
    }
  }
}

extension UITableView {
  var tableViewSource: TableViewSource {
    return lazyAssociatedProperty(self, &AssociationKey.tableViewSource) {
      return TableViewSource(tableView: self)
    }
  }
  
  // a multiplexer that provides forwarding
  var delegateMultiplexer: TableViewDelegateMultiplex {
    return lazyAssociatedProperty(self, &AssociationKey.delegateProxy) {
      let multiplexer = TableViewDelegateMultiplex()
      self.override_setDelegate(multiplexer)
      return multiplexer
    }
  }
  
  // the swizzled delegate API methods
  func override_setDelegate(delegate: AnyObject) {
    delegateMultiplexer.delegate = delegate
  }
  func override_delegate() -> UITableViewDelegate? {
    // don't invoke delegateMultiplexer getter in order to check for nil, this
    // can cause a circular invocation
    if objc_getAssociatedObject(self, &AssociationKey.delegateProxy) == nil {
      return nil
    } else {
      return delegateMultiplexer.delegate as UITableViewDelegate?
    }
  }
}

// unfortunately because UITableViewDelegate 'inherits' from UIScrollViewDelegate, something
// fishy goes on with the generic delegate forwarding provided by AVDelegateMultiplexer. As a result
// it only forwards UIScrollView delegate methods. As a quick-fix, this class provides
// forwarding of UITableViewDelegate methods. Yuck!
class TableViewDelegateMultiplex: AVDelegateMultiplexer, UITableViewDelegate {
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    delegate?.tableView(tableView, didSelectRowAtIndexPath: indexPath)
    proxiedDelegate?.tableView(tableView, didSelectRowAtIndexPath: indexPath)
  }
}

// a datasource implementation that renders the data provided by the table view's items property
class TableViewSource: NSObject, UITableViewDataSource, UITableViewDelegate {
  
  var items: [NSObject] = [NSObject]() {
    didSet {
      tableView.reloadData()
    }
  }
  
  let tableView: UITableView
  
  init(tableView: UITableView) {
    self.tableView = tableView
    
    super.init()
    
    tableView.dataSource = self
    tableView.delegateMultiplexer.proxiedDelegate = self
  }
  
  // MARK: - UITableViewDataSource
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    // TODO: How do we inform the tableview of the cell name?
    let maybeCell: AnyObject? = tableView.dequeueReusableCellWithIdentifier("Cell")
    if let cell = maybeCell as? UITableViewCell {
      cell.bindingContext = items[indexPath.row]
      return cell
    }
    return UITableViewCell()
  }
  
  // MARK: - UITableViewDelegate
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let selectedItem: AnyObject = items[indexPath.row]
    if let action = tableView.selectionAction {
      action.execute(selectedItem)
    }
  }
}
