# SidebarTableView
![Platforms](https://img.shields.io/badge/platform-ios-lightgrey)
[![GitHub](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Swift Package Manager](https://img.shields.io/badge/package%20manager-compatible-brightgreen.svg?logo=data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPHN2ZyB3aWR0aD0iNjJweCIgaGVpZ2h0PSI0OXB4IiB2aWV3Qm94PSIwIDAgNjIgNDkiIHZlcnNpb249IjEuMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayI+CiAgICA8IS0tIEdlbmVyYXRvcjogU2tldGNoIDYzLjEgKDkyNDUyKSAtIGh0dHBzOi8vc2tldGNoLmNvbSAtLT4KICAgIDx0aXRsZT5Hcm91cDwvdGl0bGU+CiAgICA8ZGVzYz5DcmVhdGVkIHdpdGggU2tldGNoLjwvZGVzYz4KICAgIDxnIGlkPSJQYWdlLTEiIHN0cm9rZT0ibm9uZSIgc3Ryb2tlLXdpZHRoPSIxIiBmaWxsPSJub25lIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiPgogICAgICAgIDxnIGlkPSJHcm91cCIgZmlsbC1ydWxlPSJub256ZXJvIj4KICAgICAgICAgICAgPHBvbHlnb24gaWQ9IlBhdGgiIGZpbGw9IiNEQkI1NTEiIHBvaW50cz0iNTEuMzEwMzQ0OCAwIDEwLjY4OTY1NTIgMCAwIDEzLjUxNzI0MTQgMCA0OSA2MiA0OSA2MiAxMy41MTcyNDE0Ij48L3BvbHlnb24+CiAgICAgICAgICAgIDxwb2x5Z29uIGlkPSJQYXRoIiBmaWxsPSIjRjdFM0FGIiBwb2ludHM9IjI3IDI1IDMxIDI1IDM1IDI1IDM3IDI1IDM3IDE0IDI1IDE0IDI1IDI1Ij48L3BvbHlnb24+CiAgICAgICAgICAgIDxwb2x5Z29uIGlkPSJQYXRoIiBmaWxsPSIjRUZDNzVFIiBwb2ludHM9IjEwLjY4OTY1NTIgMCAwIDE0IDYyIDE0IDUxLjMxMDM0NDggMCI+PC9wb2x5Z29uPgogICAgICAgICAgICA8cG9seWdvbiBpZD0iUmVjdGFuZ2xlIiBmaWxsPSIjRjdFM0FGIiBwb2ludHM9IjI3IDAgMzUgMCAzNyAxNCAyNSAxNCI+PC9wb2x5Z29uPgogICAgICAgIDwvZz4KICAgIDwvZz4KPC9zdmc+)](https://github.com/apple/swift-package-manager)

This framework is an _UITableView_ implementation of the __iPadOS 14 Sidebar__. It works on older iOS versions and provides easy fallbacks for the compact view controller on iOS versions before iOS 14, which added the __compact view controller__ option to the _UISplitViewController_. This framework can also automatically adjust the style of the sidebar to match iOS 14 and iOS 15 look.

<img width="1379" alt="Screenshot 2021-06-28 at 20 53 26" src="https://user-images.githubusercontent.com/14315425/123688903-e53f9780-d852-11eb-821e-21f9724c699d.png">

## 💻 Requirements
This framework works on iPhones and iPads with the minimum system requirements:
  * 📱 iOS 11.0+
  
## ⚙️ Supports:
  * __Dark mode__
  * __SF Symbols__
  * __iOS 11.0+__
  * Row Highlighting
  * Multiple Table Sections
  * Compact View Controller fallback on iOS 11 through iOS 13
  
## 🏗 TO-DO:
  - [ ] Fix Navigation Bar's background color on iOS 13 before segue selection
  - [ ] Fix inner cell layout margins after rotation on iOS 11-12
  - [ ] Fix cell image highlight tint when selected on minimal styling
  
## 📖 Usage
To use this framework you can either setup the master detail project in Xcode using the storyboard or by creating each view manually. Remember however to inherit not from _UITableViewController_ but from _SidebarTableViewController_ which is provided by this framework. If you wish to use the compact view controller fallback on iOS versions prior to iOS 14, you should also replace the default _UISplitViewController_ with our custom _AdaptableSplitViewController_ in the storyboard.

## ⚖️ License
SidebarTableView is distributed under the [MIT license](LICENSE).
