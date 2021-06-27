import UIKit

open class SidebarTableView: UITableViewController, UIPointerInteractionDelegate {
    // Helper variable
    private var didChange = false
    
    /// Value on which we decide if we're currently in split view presentation
    private var isInSplitViewPresentation: Bool {
        return !(splitViewController?.isCollapsed ?? true)
    }
    
    /// The value signifying the selected row, or the row which should be selected on nearest appearance
    /// You should only change section, as for Sidebar styled UITableView you can only have one row per section
    open lazy var lastSelectedRow = IndexPath(row: 0, section: 0)
    
    /// Initializer which sets the correct `UITableView` style – `UITableView.Style.insetGrouped`
    public override init(style: UITableView.Style) {
        super.init(style: .insetGrouped)
    }
    
    /// Required initializer
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // Preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.renewLastSelection), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        tableView.backgroundColor = .secondarySystemBackground
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
    
    /// Function which selects the indexPath specified in `lastSelectedRow`
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
            pointerStyle = UIPointerStyle(effect: UIPointerEffect.hover(targetedPreview, preferredTintMode: .overlay, prefersShadow: true, prefersScaledContent: true))
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
    
    /// Tells the delegate the table view is about to draw a cell for a particular row.
    ///
    /// - parameter tableView: The table view informing the delegate of this impending event.
    /// - parameter cell: A cell that tableView is going to use when drawing the row.
    /// - parameter indexPath: An index path locating the row in tableView.
    open override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if isLoadingTable && tableView.indexPathsForVisibleRows?.last?.row == indexPath.row && isInSplitViewPresentation {
//            isLoadingTable = false
//            tableView.selectRow(at: lastSelectedRow, animated: false, scrollPosition: .none)
//        }
        
        if isInSplitViewPresentation {
            // Remove any accessory
            cell.accessoryType = .none

            // Set Sidebar style
            let bgView = UIView()
            bgView.backgroundColor = cell.tintColor
            
            cell.selectedBackgroundView = bgView
            cell.textLabel?.highlightedTextColor = UIColor.white
        } else {
            // Make the cell regular tableView style, as we're not in SplitView anymore
            cell.selectedBackgroundView = nil
            cell.selectionStyle = .default
            cell.textLabel?.highlightedTextColor = .label
        }
    }
    
    /**
     The function configures the provided cell for correct iPadOS 14 Sidebar-like look. Call this function for each cell you initialize, creating only one cell per table view section to achieve the desired, rounded, look.
     
     - parameter cell: The `UITableViewCell` which should be configured.
     - parameter systemName: The symbol name, which should be used as the image in cell's `imageView`
     - warning: This function has to be called for each cell you initialize!
     
     ```swift
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         if indexPath.section == 0 {
            // Set up the first cell, only one per section!
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = "Favourites"
     
            // Configure the cell for Sidebar style
            self.configure(cell: cell, withSymbolName: "heart.fill")
     
            return cell
        } else if indexPath.section == 1 {
            // Set up the next cell
            let cell_1 = tableView.dequeueReusableCell(withIdentifier: "cell_1", for: indexPath)
            cell_1.textLabel?.text = "Text Only"

            // Configure the cell for Sidebar style
            self.configure(cell: cell_1)

            return cell_1
        }
        ...
     }
     ```
     # Notes: #
     Remember that for the Sidebar style `UITableView` you can only have one cell (row) per section.
     */
    public func configure(cell: UITableViewCell, withSymbolNamed systemName: String? = nil) {
        // Set the symbol image
        if let systemName = systemName {
            cell.imageView?.image = UIImage(systemName: systemName)
            cell.imageView?.highlightedImage = UIImage(systemName: systemName)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        }
        // Add pointer interactions
        if #available(iOS 13.4, *) {
            let pointerInteraction = UIPointerInteraction(delegate: self)
            cell.addInteraction(pointerInteraction)
        }
        // Set the cell background color
        cell.backgroundColor = .secondarySystemBackground
    }

    // MARK: - Header strings for Section
    
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    // MARK: - Height Adjustments for iPadOS 14 Sidebar-like Layout
    
    public override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section > 0 else { return super.tableView(tableView, heightForHeaderInSection: section) }
        return 1.0
    }
    
    public override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard section > 0 else { return super.tableView(tableView, heightForFooterInSection: section) }
        return 1.0
    }
    
    public override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section > 0 else { return super.tableView(tableView, viewForHeaderInSection: section) }
        return UIView(frame: .zero)
    }
    
    public override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section > 0 else { return super.tableView(tableView, viewForFooterInSection: section) }
        return UIView(frame: .zero)
    }

}
