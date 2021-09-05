//
//  AdaptableSplitViewController.swift
//
//  Created by Adam Kopeć on 01/09/2021.
//
//  Licensed under the MIT License
//

import UIKit

@IBDesignable
@available(iOS 11.0, *)
open class AdaptableSplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    /// The storyboard restoration identifier of a compact view controller
    @IBInspectable
    public var compactViewControllerIdentifier: String?
    private lazy var compactViewController: UIViewController? = {
        guard let compactViewControllerIdentifier = compactViewControllerIdentifier else {
            return nil
        }
        return storyboard?.instantiateViewController(withIdentifier: compactViewControllerIdentifier)
    }()
    private var primaryViewController: UIViewController?
    private var secondaryViewController: UIViewController?
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        let controller = (viewControllers.last as? UINavigationController)?.topViewController ?? viewControllers.last
        controller?.navigationItem.leftBarButtonItem = self.displayModeButtonItem
    }
    // Collapse onto compactViewController when compact size
    public func primaryViewController(forCollapsing splitViewController: UISplitViewController) -> UIViewController? {
        if #available(iOS 14.0, *) {
            return splitViewController.viewController(for: .compact)
        } else {
            // Fallback on earlier versions
            // Set primary and secondary view controllers
            primaryViewController = splitViewController.viewControllers.first
            secondaryViewController = splitViewController.viewControllers.dropFirst().first
            // Return a compact view controller
            return compactViewController
        }
    }
    public func primaryViewController(forExpanding splitViewController: UISplitViewController) -> UIViewController? {
        if #available(iOS 14.0, *) {
            return splitViewController.viewController(for: .primary)
        } else {
            // Fallback on earlier versions
            return self.primaryViewController
        }
    }
    public func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {        secondaryViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        return true
    }
    public func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        if #available(iOS 14.0, *) {
            return splitViewController.viewController(for: .secondary)
        } else {
            // Fallback on earlier versions
            // Return a secondary view controller
            return self.secondaryViewController
        }
    }
}
