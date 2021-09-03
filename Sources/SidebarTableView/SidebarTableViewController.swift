//
//  SidebarTableViewController.swift
//  
//  Created by Adam Kopeć on 28/06/2021.
//

import UIKit

/// A subclass of `UITableViewController` which makes the TableView look and feel like the iPadOS 14 Sidebar.
@available(iOS 13.0, *)
open class SidebarTableViewController: UITableViewController, UIPointerInteractionDelegate {
    // Helper variable
    private var didChange = false
    
    /// Value on which we decide if we're currently in split view presentation
    private var isInSplitViewPresentation: Bool {
        return !(splitViewController?.isCollapsed ?? true)
    }
    
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
        if isInSplitViewPresentation && tableView.indexPathForSelectedRow == nil {
            tableView?.selectRow(at: lastSelectedRow, animated: false, scrollPosition: .none)
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
    
    open override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // Configure for regular selection
        tableView.cellForRow(at: indexPath)?.configureSelection()
        return indexPath
    }
}
