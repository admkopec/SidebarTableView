//
//  AdaptableSplitViewController.swift
//
//  Created by Adam Kopeć on 01/09/2021.
//

import UIKit

@IBDesignable
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
        let controller = (self.viewControllers.last as? UINavigationController)?.topViewController ?? self.viewControllers.last
        controller?.navigationItem.leftBarButtonItem = self.displayModeButtonItem
    }
    // TODO: Collapse onto UITabBarController when compact size
    public func primaryViewController(forCollapsing splitViewController: UISplitViewController) -> UIViewController? {
        if #available(iOS 14.0, *) {
            return splitViewController.viewController(for: .compact)
        } else {
            // Fallback on earlier versions
            // TODO: Return a compact view controller
            primaryViewController = splitViewController.viewControllers.first
            secondaryViewController = splitViewController.viewControllers.dropFirst().first
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
            // TODO: Return a secondary view controller
            return self.secondaryViewController
        }
    }
}
