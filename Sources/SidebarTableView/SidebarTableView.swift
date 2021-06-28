//
//  SidebarTableViewController.swift
//
//  Created by Adam Kopeć on 28/06/2021.
//
import UIKit

/// A subclass of `UITableView` which makes the TableView look and feel like the iPadOS 14 Sidebar.
open class SidebarTableView: UITableView {
    
    convenience init() {
        self.init(frame: .zero, style: .insetGrouped)
    }
    
    convenience init(frame: CGRect) {
        self.init(frame: frame, style: .insetGrouped)
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: .insetGrouped)
        commonInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        if self.style != .insetGrouped {
            fatalError("SidebarTableView: Make sure the table view style is set to \"Inset Grouped\" in Interface Builder")
        }
        commonInit()
    }
    /// Perform common initialisation operations
    private func commonInit() {
        self.backgroundColor = .secondarySystemBackground
        self.separatorColor = .clear
        self.separatorStyle = .none
    }
    /// Pre-Configure cell before returning
    open override func dequeueReusableCell(withIdentifier identifier: String) -> UITableViewCell? {
        let cell = super.dequeueReusableCell(withIdentifier: identifier)
        cell?.configureForSidebar()
        return cell
    }
}

public extension UITableViewCell {
    /**
     The function configures the provided cell for correct iPadOS 14 Sidebar-like look. Call this function for each cell you initialise to achieve the desired, rounded, look.
     
     - parameter cell: The ``UITableViewCell`` which should be configured.
     - parameter systemName: The symbol name, which should be used as the image in cell's ``UITableViewCell.imageView``
     - important: This function has to be called for each cell you initialize!
     
     ```swift
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         if indexPath.section == 0 {
            // Set up the first cell, only one per section!
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = "Favourites"
     
            // Configure the cell for Sidebar style
            cell.configureForSidebar(withSymbolName: "heart.fill")
     
            return cell
        } else if indexPath.section == 1 {
            // Set up the next cell
            let cell_1 = tableView.dequeueReusableCell(withIdentifier: "cell_1", for: indexPath)
            cell_1.textLabel?.text = "Text Only"

            // Configure the cell for Sidebar style
            cell_1.configureForSidebar()

            return cell_1
        }
        ...
     }
     ```
     */
    func configureForSidebar(withSymbolNamed systemName: String? = nil) {
        // Set the symbol image
        if let systemName = systemName {
            self.imageView?.image = UIImage(systemName: systemName)
            self.imageView?.highlightedImage = UIImage(systemName: systemName)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        }
        // Add pointer interactions
        if #available(iOS 13.4, *), let delegate = (self.superview as? UITableView)?.delegate as? UIPointerInteractionDelegate {
            let pointerInteraction = UIPointerInteraction(delegate: delegate)
            self.addInteraction(pointerInteraction)
        }
        // Set the cell background color
        self.backgroundColor = .secondarySystemBackground
        //
        self.layer.masksToBounds = true
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        self.layer.cornerRadius = 10.0
        self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        
        // Remove any accessory
        self.accessoryType = .none

        self.backgroundView?.layer.cornerRadius = 10.0
        self.backgroundView?.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
                
        self.backgroundView?.layer.masksToBounds = true
        self.backgroundView?.layer.cornerRadius = 10.0
        self.backgroundView?.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        
        self.multipleSelectionBackgroundView?.layer.masksToBounds = true
        self.multipleSelectionBackgroundView?.layer.cornerRadius = 10.0
        self.multipleSelectionBackgroundView?.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        
        // Set Sidebar style
        let bgView = UIView()
        bgView.backgroundColor = self.tintColor
        bgView.layer.masksToBounds = true
        bgView.layer.cornerRadius = 10.0
        bgView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        
        self.selectedBackgroundView = bgView
        self.textLabel?.highlightedTextColor = UIColor.white
    }
    
    internal func configureSelection() {
        // Set Sidebar style
        let bgView = UIView()
        bgView.backgroundColor = self.tintColor
        bgView.layer.masksToBounds = true
        bgView.layer.cornerRadius = 10.0
        bgView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        
        self.selectedBackgroundView = bgView
        self.textLabel?.highlightedTextColor = UIColor.white
        self.imageView?.highlightedImage = self.imageView?.image?.withTintColor(.white, renderingMode: .alwaysOriginal)
    }
    
    internal func configureHighlight() {
        // Set Sidebar style
        self.selectedBackgroundView = nil
        self.textLabel?.highlightedTextColor = .gray
        self.imageView?.highlightedImage = self.imageView?.image?.withTintColor(.gray, renderingMode: .alwaysOriginal)
    }
}
