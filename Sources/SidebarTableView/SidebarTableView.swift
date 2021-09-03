//
//  SidebarTableViewController.swift
//
//  Created by Adam Kopeć on 28/06/2021.
//
import UIKit

/// A subclass of `UITableView` which makes the TableView look and feel like the iPadOS 14 Sidebar.
@IBDesignable
@available(iOS 13.0, *)
open class SidebarTableView: UITableView {
    /// The sidebar selection style
    private var sidebarSelectionStyle: SidebarStyle = .default
    
    /// The sidebar selection style, which should be used upon selecting a row.
    @IBInspectable
    public var sidebarStyle: SidebarStyle {
        get {
            sidebarSelectionStyle
        } set {
            sidebarSelectionStyle = newValue
        }
    }
    
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
        cell?.configureForSidebar(self)
        return cell
    }
}

/// Specifies the sidebar selection style
@available(iOS 13.0, *) @objc
public enum SidebarStyle: Int {
    /// The sidebar will choose the default style based on iOS version
    case `default`
    /// The sidebar will use application's tint color to highlight selection. This is the default sidebar style on iPadOS 14
    case prominent
    /// The sidebar will use a light gray color to highlight selection. This is the default sidebar style on iPadOS 15
    case minimal
}

@available(iOS 13.0, *)
public extension UITableViewCell {
    /**
     The function configures the provided cell for correct iPadOS 14 Sidebar-like look. Call this function for each cell you initialise to achieve the desired, rounded, look.
     
     - parameter tableView: The ``UITableView`` for which the cell should be configured.
     - parameter systemName: The symbol name, which should be used as the image in cell's ``UITableViewCell.imageView``
     - important: This function has to be called for each cell you initialize!
     
     ```swift
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         if indexPath.section == 0 {
            // Set up the first cell, only one per section!
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = "Favourites"
     
            // Configure the cell for Sidebar style
            cell.configureForSidebar(tableView, withSymbolNamed: "heart.fill")
     
            return cell
        } else if indexPath.section == 1 {
            // Set up the next cell
            let cell_1 = tableView.dequeueReusableCell(withIdentifier: "cell_1", for: indexPath)
            cell_1.textLabel?.text = "Text Only"

            // Configure the cell for Sidebar style
            cell_1.configureForSidebar(tableView)

            return cell_1
        }
        ...
     }
     ```
     */
    func configureForSidebar(_ tableView: UITableView, withSymbolNamed systemName: String? = nil) {
        // Get sidebarStyle from SidebarTableView
        let sidebarStyle = (tableView as? SidebarTableView)?.sidebarStyle ?? .default
        // Set the symbol image
        if let systemName = systemName {
            self.imageView?.image = UIImage(systemName: systemName)
            // Set proper highlight image based on sidebarStyle
            switch sidebarStyle {
            case .prominent:
                self.imageView?.highlightedImage = UIImage(systemName: systemName)?.withTintColor(.white, renderingMode: .alwaysOriginal)
            case .minimal:
                self.imageView?.highlightedImage = UIImage(systemName: systemName)
            case .default:
                if #available(iOS 15.0, *) {
                    self.imageView?.highlightedImage = UIImage(systemName: systemName)
                } else {
                    self.imageView?.highlightedImage = UIImage(systemName: systemName)?.withTintColor(.white, renderingMode: .alwaysOriginal)
                }
            }
        }
        // Add pointer interactions
        if #available(iOS 13.4, *), let delegate = tableView.delegate as? UIPointerInteractionDelegate {
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
        
        self.backgroundView?.layer.masksToBounds = true
        self.backgroundView?.layer.cornerRadius = 10.0
        self.backgroundView?.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        
        self.multipleSelectionBackgroundView?.layer.masksToBounds = true
        self.multipleSelectionBackgroundView?.layer.cornerRadius = 10.0
        self.multipleSelectionBackgroundView?.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        
        // Set Sidebar style
        let bgView = UIView()
        
        switch sidebarStyle {
        case .prominent:
            bgView.backgroundColor = self.tintColor
            self.textLabel?.highlightedTextColor = UIColor.white
        case .minimal:
            bgView.backgroundColor = UIColor.lightGray
            self.textLabel?.highlightedTextColor = UIColor.label
        case .default:
            if #available(iOS 15.0, *) {
                bgView.backgroundColor = UIColor.systemFill
                self.textLabel?.highlightedTextColor = UIColor.label
            } else {
                bgView.backgroundColor = self.tintColor
                self.textLabel?.highlightedTextColor = UIColor.white
            }
        }
        
        bgView.layer.masksToBounds = true
        bgView.layer.cornerRadius = 10.0
        bgView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        
        self.selectedBackgroundView = bgView
    }
    
    internal func configureSelection() {
        // Get sidebarStyle from SidebarTableView
        let sidebarStyle = (self.tableView as? SidebarTableView)?.sidebarStyle ?? .default
        // Set Sidebar style
        let bgView = UIView()
        
        switch sidebarStyle {
        case .prominent:
            bgView.backgroundColor = self.tintColor
            self.textLabel?.highlightedTextColor = UIColor.white
            self.imageView?.highlightedImage = self.imageView?.image?.withTintColor(.white, renderingMode: .alwaysOriginal)
        case .minimal:
            bgView.backgroundColor = UIColor.lightGray
            self.textLabel?.highlightedTextColor = UIColor.label
            self.imageView?.highlightedImage = self.imageView?.image
        case .default:
            if #available(iOS 15.0, *) {
                bgView.backgroundColor = UIColor.systemFill
                self.textLabel?.highlightedTextColor = UIColor.label
                self.imageView?.highlightedImage = self.imageView?.image
            } else {
                bgView.backgroundColor = self.tintColor
                self.textLabel?.highlightedTextColor = UIColor.white
                self.imageView?.highlightedImage = self.imageView?.image?.withTintColor(.white, renderingMode: .alwaysOriginal)
            }
        }
        
        bgView.layer.masksToBounds = true
        bgView.layer.cornerRadius = 10.0
        bgView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        
        self.selectedBackgroundView = bgView
    }
    
    internal func configureHighlight() {
        // Set Sidebar style
        self.selectedBackgroundView = nil
        self.textLabel?.highlightedTextColor = .systemGray2
        self.imageView?.highlightedImage = self.imageView?.image?.withTintColor(.systemGray2, renderingMode: .alwaysOriginal)
    }
    
    private var tableView: UITableView? {
        var superview = self.superview
        while let view = superview, (view is UITableView) == false {
            superview = view.superview
        }
        return superview as? UITableView
    }
}
