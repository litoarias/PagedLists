//
//  PagedTableView.swift
//  PagedLists
//
//  Created by German Lopez on 3/22/16.
//  Copyright © 2020 Rootstrap Inc. All rights reserved.
//
import Foundation

#if canImport(UIKit)
import UIKit

public protocol PagedTableViewDelegate: class {
	func tableView(_ tableView: PagedTableView, needsDataForPage page: Int, completion: @escaping (_ elementsAdded: Int, _ error: NSError?) -> Void)
	func tableView(_ tableView: PagedTableView, didSelectRowAt indexPath: IndexPath)
}

public enum PagingDirectionType {
	case atBottom
	case atTop
}

open class PagedTableView: UITableView {
	
	public private(set) var currentPage = 1
	public private(set) var isLoading = false
	public var hasMore = true
	public var elementsPerPage = 10
	public weak var updateDelegate: PagedTableViewDelegate!
	public var direction: PagingDirectionType = .atBottom
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	public override init(frame: CGRect, style: UITableView.Style) {
		super.init(frame: frame, style: style)
		commonInit()
	}
	
	private func commonInit() {
		delegate = self
	}
	
	public func loadContentIfNeeded() {
		guard hasMore && !isLoading else {
			return
		}
		isLoading = true
		updateDelegate.tableView(
			self,
			needsDataForPage: currentPage,
			completion: { (newElements, error) in
				self.isLoading = false
				guard error == nil else {
					return
				}
				self.currentPage += 1
				self.hasMore = newElements == self.elementsPerPage
			})
	}
	
	public func reset() {
		currentPage = 1
		hasMore = true
		isLoading = false
	}
	
	func didScrollBeyondTop() -> Bool {
		return contentOffset.y < 0
	}
	
	func didScrollBeyondBottom() -> Bool {
		return contentOffset.y >= (contentSize.height - bounds.size.height)
	}
}

extension PagedTableView: UITableViewDelegate, UIScrollViewDelegate {
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		updateDelegate.tableView(self, didSelectRowAt: indexPath)
	}
	
	
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if direction == .atBottom {
			if didScrollBeyondTop() {
				return
			} else if didScrollBeyondBottom() {
				loadContentIfNeeded()
			}
		} else {
			if didScrollBeyondTop() {
				loadContentIfNeeded()
			}
		}
	}
}

#endif
