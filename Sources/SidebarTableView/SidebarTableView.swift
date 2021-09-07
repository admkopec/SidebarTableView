//
//  SidebarTableViewController.swift
//
//  Created by Adam Kopeć on 28/06/2021.
//
//  Licensed under the MIT License
//

import UIKit

/// A subclass of `UITableView` which makes the TableView look and feel like the iPadOS 14 Sidebar.
@IBDesignable
@available(iOS 11.0, *)
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
        if #available(iOS 13.0, *) {
            self.init(frame: .zero, style: .insetGrouped)
        } else {
            self.init(frame: .zero, style: .grouped)
        }
    }
    
    convenience init(frame: CGRect) {
        if #available(iOS 13.0, *) {
            self.init(frame: frame, style: .insetGrouped)
        } else {
            self.init(frame: frame, style: .grouped)
        }
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        if #available(iOS 13.0, *) {
            super.init(frame: frame, style: .insetGrouped)
        } else {
            super.init(frame: frame, style: .grouped)
        }
        commonInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        if self.style == .plain {
            fatalError("SidebarTableView: Make sure the table view style is set to \"Inset Grouped\" in Interface Builder")
        }
        commonInit()
    }
    /// Perform common initialisation operations
    private func commonInit() {
        if #available(iOS 13.0, *) {
            self.backgroundColor = .secondarySystemBackground
        } else {
            self.backgroundColor = .groupTableViewBackground
        }
        self.separatorColor = .clear
        self.separatorStyle = .none
    }
    /// Pre-Configure cell before returning
    open override func dequeueReusableCell(withIdentifier identifier: String) -> UITableViewCell? {
        let cell = super.dequeueReusableCell(withIdentifier: identifier)
        cell?.configureForSidebar(self)
        return cell
    }
    /// Configure after adding to view
    open override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        guard let cell = subview as? UITableViewCell else { return }
        cell.configureForSidebar(self)
    }
    /// Add margins if not inset grouped
    open override func layoutSubviews() {
        super.layoutSubviews()
        subviews.compactMap({ $0 as? UITableViewCell }).forEach { cell in
            // TODO: Fix improper margins of inner cell content when layout changes (eg. after rotation)
            if self.style == .grouped {
                self.performInsetLayout(for: cell)
            }
        }
    }
    /// Configure cell for Inset-Groupping on regulary grouped table view
    private func performInsetLayout(for view: UIView) {
        var frame = view.frame;
        let margins = self.layoutMargins;
        let safeAreaInsets = self.safeAreaInsets;
        
        // Calculate the left margin.
        // If the margin on its own isn't larger than
        // the safe area inset, combine the two.
        var leftInset = margins.left;
        if (leftInset - safeAreaInsets.left < 0) {
            leftInset += safeAreaInsets.left;
        }
        
        // Calculate the right margin with the same logic.
        var rightInset = margins.right;
        if (rightInset - safeAreaInsets.right < 0) {
            rightInset += safeAreaInsets.right;
        }
        
        // Calculate offset and width off the insets
        frame.origin.x = leftInset;
        frame.size.width = self.frame.width - (leftInset + rightInset);
        
        view.layer.frame = frame
    }
}

/// Specifies the sidebar selection style
@available(iOS 11.0, *) @objc
public enum SidebarStyle: Int {
    /// The sidebar will choose the default style based on iOS version
    case `default`
    /// The sidebar will use application's tint color to highlight selection. This is the default sidebar style on iPadOS 14
    case prominent
    /// The sidebar will use a light gray color to highlight selection. This is the default sidebar style on iPadOS 15
    case minimal
    /// The sidebar style which should be used (resolving default style)
    internal var resolvedStyle: SidebarStyle {
        if self == .default {
            if #available(iOS 15.0, *) {
                return .minimal
            } else {
                return .prominent
            }
        }
        return self
    }
}

@available(iOS 11.0, *)
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
    @available(iOS 13.0, *)
    func configureForSidebar(_ tableView: UITableView, withSymbolNamed systemName: String) {
        // Set the symbol image
        self.configureForSidebar(tableView, withImage: UIImage(systemName: systemName))
    }
    /**
     The function configures the provided cell for correct iPadOS 14 Sidebar-like look. Call this function for each cell you initialise to achieve the desired, rounded, look.
     
     - parameter tableView: The ``UITableView`` for which the cell should be configured.
     - parameter image: The ``UIImage``, which should be used as the image in cell's ``UITableViewCell.imageView``. This has to be a template image.
     - important: This function has to be called for each cell you initialize!
     
     ```swift
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         if indexPath.section == 0 {
            // Set up the first cell, only one per section!
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = "Favourites"
     
            // Configure the cell for Sidebar style
            cell.configureForSidebar(tableView, withImage: UIImage(systemName: "heart.fill"))
     
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
    func configureForSidebar(_ tableView: UITableView, withImage image: UIImage? = nil) {
        // Get sidebarStyle from SidebarTableView
        let sidebarStyle = (tableView as? SidebarTableView)?.sidebarStyle ?? .default
        // Set the symbol image
        if let image = image {
            self.imageView?.image = image
            // Set proper highlight image based on sidebarStyle
            switch sidebarStyle.resolvedStyle {
            case .prominent:
                if #available(iOS 13.0, *) {
                    self.imageView?.highlightedImage = image.withTintColor(.white, renderingMode: .alwaysOriginal)
                } else {
                    let size = self.imageView?.bounds.size ?? CGSize(width: 64, height: 64)
                    self.imageView?.highlightedImage = image.withTintColor(.white, width: size.width, height: size.height)
                }
            case .minimal:
                self.imageView?.highlightedImage = image
            case .default:
                fatalError("Resolved style can't return default")
            }
        }
        // Add pointer interactions
        if #available(iOS 13.4, *), let delegate = tableView.delegate as? UIPointerInteractionDelegate {
            let pointerInteraction = UIPointerInteraction(delegate: delegate)
            self.addInteraction(pointerInteraction)
        }
        // Set the cell background color
        if #available(iOS 13.0, *) {
            self.backgroundColor = .secondarySystemBackground
        } else {
            // Fallback on earlier versions
            self.backgroundColor = .groupTableViewBackground
        }
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
        
        switch sidebarStyle.resolvedStyle {
        case .prominent:
            bgView.backgroundColor = self.tintColor
            self.textLabel?.highlightedTextColor = UIColor.white
        case .minimal:
            if #available(iOS 13.0, *) {
                bgView.backgroundColor = UIColor.systemFill
                self.textLabel?.highlightedTextColor = UIColor.label
            } else {
                let systemFill =  UIColor(red: 120.0, green: 120.0, blue: 128.0, alpha: 0.2)
                bgView.backgroundColor = systemFill
                self.textLabel?.highlightedTextColor = UIColor.black
            }
        case .default:
            fatalError("Resolved style can't return default")
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
        
        switch sidebarStyle.resolvedStyle {
        case .prominent:
            bgView.backgroundColor = self.tintColor
            self.textLabel?.highlightedTextColor = UIColor.white
            if #available(iOS 13.0, *) {
                self.imageView?.highlightedImage = self.imageView?.image?.withTintColor(.white, renderingMode: .alwaysOriginal)
            } else {
                let size = self.imageView?.bounds.size ?? CGSize(width: 64, height: 64)
                self.imageView?.highlightedImage = self.imageView?.image?.withTintColor(.white, width: size.width, height: size.height)
            }
        case .minimal:
            if #available(iOS 13.0, *) {
                bgView.backgroundColor = UIColor.systemFill
                self.textLabel?.highlightedTextColor = UIColor.label
            } else {
                let systemFill =  UIColor(red: 120.0, green: 120.0, blue: 128.0, alpha: 0.2)
                bgView.backgroundColor = systemFill
                self.textLabel?.highlightedTextColor = UIColor.black
            }
            self.imageView?.highlightedImage = self.imageView?.image
        case .default:
            fatalError("Resolved style can't return default")
        }
        
        bgView.layer.masksToBounds = true
        bgView.layer.cornerRadius = 10.0
        bgView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        
        self.selectedBackgroundView = bgView
    }
    
    internal func configureHighlight() {
        // Set Sidebar style
        if self.isSelected {
            let sidebarStyle = (self.tableView as? SidebarTableView)?.sidebarStyle ?? .default
            switch sidebarStyle.resolvedStyle {
            case .prominent:
                self.selectedBackgroundView?.backgroundColor = self.selectedBackgroundView?.backgroundColor?.withAlphaComponent(0.5)
                return
            case .minimal :
                self.selectedBackgroundView?.backgroundColor = self.selectedBackgroundView?.backgroundColor?.withAlphaComponent(0.1)
                // TODO: Make sure `self.imageView?.highlightedImage` has proper `systemGray2` tint
            case .default:
                fatalError("Resolved style can't return default")
            }
        } else {
            self.selectedBackgroundView = nil
        }
        if #available(iOS 13.0, *) {
            self.textLabel?.highlightedTextColor = .systemGray2
            self.imageView?.highlightedImage = self.imageView?.image?.withTintColor(.systemGray2, renderingMode: .alwaysOriginal)
        } else {
            let systemGray2 = UIColor(red: 174.0, green: 174.0, blue: 178.0, alpha: 1.0)
            self.textLabel?.highlightedTextColor = systemGray2
            if #available(iOS 13.0, *) {
                self.imageView?.highlightedImage = self.imageView?.image?.withTintColor(systemGray2, renderingMode: .alwaysOriginal)
            } else {
                let size = self.imageView?.bounds.size ?? CGSize(width: 64, height: 64)
                self.imageView?.highlightedImage = self.imageView?.image?.withTintColor(systemGray2, width: size.width, height: size.height)
            }
        }
    }
    
    private var tableView: UITableView? {
        var superview = self.superview
        while let view = superview, (view is UITableView) == false {
            superview = view.superview
        }
        return superview as? UITableView
    }
}

extension UITableViewCell {
    open override func tintColorDidChange() {
        super.tintColorDidChange()
        // Get sidebarStyle from SidebarTableView
        let sidebarStyle = (self.tableView as? SidebarTableView)?.sidebarStyle ?? .default
        if sidebarStyle.resolvedStyle == .prominent {
            // Update selected background with new tint color
            self.selectedBackgroundView?.backgroundColor = self.tintColor
        }
    }
}

fileprivate extension UIImage {
    // For iOS 11 - iOS 12
    func withTintColor(_ color: UIColor, width: CGFloat, height: CGFloat) -> UIImage? {
        let drawRect = CGRect(x: 0, y: 0, width: width, height: height)
        let imageView = UIImageView(frame: drawRect)
        imageView.image = self.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = color

        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, imageView.isOpaque, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage
    }
}
