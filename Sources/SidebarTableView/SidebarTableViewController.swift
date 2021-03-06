//
//  SidebarTableViewController.swift
//  
//  Created by Adam Kopeć on 28/06/2021.
//
//  Licensed under the MIT License
//

import UIKit

/// A subclass of `UITableViewController` which makes the TableView look and feel like the iPadOS 14 Sidebar.
@available(iOS 11.0, *)
open class SidebarTableViewController: UITableViewController, UIPointerInteractionDelegate {
    // Helper variable
    private var isLoadingTable = true
    private var didChange = true
    
    /// The value signifying the selected row, or the row which should be selected on nearest appearance
    /// You should only change section, as for Sidebar styled `UITableView` you can only have one row per section
    open lazy var lastSelectedRow = IndexPath(row: 0, section: 0)
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the navigationBar's title to use Large style
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.renewLastSelection), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        // Configure navigationBar on Pre-iOS 13 to match sidebar appearance
        if #available(iOS 13.0, *) { } else {
            self.navigationController?.navigationBar.shadowImage = UIImage()
        }
    }
    
    open override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()
        if didChange {
            // Fix navigationBar height
            navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 96.0)
            didChange.toggle()
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Animation
        if let selectedRow = tableView.indexPathForSelectedRow {
            if let coordinator = transitionCoordinator {
                coordinator.animate(alongsideTransition: { (context) in
                    self.tableView.deselectRow(at: selectedRow, animated: context.isAnimated)
                }, completion: { (context) in
                    if context.isCancelled {
                        self.tableView.selectRow(at: selectedRow, animated: false, scrollPosition: .none)
                    }
                })
            } else {
                tableView.deselectRow(at: selectedRow, animated: animated)
            }
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Renew Selection
        renewLastSelection()
        // Required for proper UINavigationBar Layout
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.setNeedsLayout()
    }
    
    // MARK: - Support Selection Preserving
    
    /// Function which selects the indexPath specified in ``lastSelectedRow``
    @objc private func renewLastSelection() {
        if tableView.indexPathForSelectedRow == nil {
            tableView?.selectRow(at: lastSelectedRow, animated: false, scrollPosition: .none)
        } else {
            tableView.cellForRow(at: tableView.indexPathForSelectedRow!)?.configureSelection()
        }
    }
    
    // MARK: - Pointer Interaction delegate
    
    @available(iOS 13.4, *)
    open func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
        var pointerStyle: UIPointerStyle? = nil
        if let interactionView = interaction.view {
            let targetedPreview = UITargetedPreview(view: interactionView)
            pointerStyle = UIPointerStyle(effect: .highlight(targetedPreview), shape: .roundedRect(interaction.view?.frame ?? .zero, radius: 10))
        }
        return pointerStyle
    }
    
    // MARK: - Table View Delegate
    
    /// Tells the delegate a row is selected.
    /// - parameter tableView: A table view informing the delegate about the new row selection.
    /// - parameter indexPath: An index path locating the new selected row in tableView.
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Set the selection
        lastSelectedRow = indexPath
    }
    
    open override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        // Required for correct symbol tinit on highlight
        tableView.cellForRow(at: indexPath)?.configureHighlight()
        return true
    }
    
    open override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        // Reconfigure the cell once more, to make sure we didn't lose any settings
        tableView.cellForRow(at: indexPath)?.configureHighlight()
    }
    
    open override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        // Drop the highlight
        let cell = tableView.cellForRow(at: indexPath)
        cell?.configureForSidebar(tableView, withImage: cell?.imageView?.image)
    }
    
    open override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // Configure for regular selection
        tableView.cellForRow(at: indexPath)?.configureSelection()
        return indexPath
    }
    
    open override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if #available(iOS 13.0, *) { } else if isLoadingTable && lastSelectedRow == indexPath {
            isLoadingTable = false
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(3)) {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
        }
    }
    
    // MARK: - Height Adjustments for iPadOS 14 Sidebar-like Layout on Pre-iOS 13
    
    open override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if #available(iOS 13.0, *) { return super.tableView(tableView, heightForHeaderInSection: section) }
        guard section == 0 else { return super.tableView(tableView, heightForHeaderInSection: section) }
        return 1.0
    }
    
    open override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if #available(iOS 13.0, *) { return super.tableView(tableView, viewForHeaderInSection: section) }
        guard section == 0 else { return super.tableView(tableView, viewForHeaderInSection: section) }
        return UIView(frame: .zero)
    }
    
    // MARK: - Scroll View Delegate for navigation bar adjustments on Pre-iOS 13
    
    open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if #available(iOS 13.0, *) { return }
        let navigationBar = self.navigationController!.navigationBar
        if scrollView.bounds.origin.y > -80 {
            navigationBar.barTintColor = nil
            navigationBar.shadowImage = nil
        } else {
            if #available(iOS 13.0, *) {
                navigationBar.barTintColor = .secondarySystemBackground
            } else {
                navigationBar.barTintColor = .groupTableViewBackground
            }
            navigationBar.shadowImage = UIImage()
        }
    }
    
    // MARK: - Segues
    
    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if #available(iOS 14.0, *) { return }
        let controller = (segue.destination as? UINavigationController)?.topViewController ?? segue.destination
        controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
    }
}
