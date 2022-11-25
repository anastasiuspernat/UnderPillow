![](https://github.com/anastasiuspernat/DiffusionInfo/blob/main/UnderPillow/Assets.xcassets/AppIcon.appiconset/icon_256x256.png?raw=true)
# UnderPillow
A macOS Finder right-click menu extension that displays diffusion metadata (usually created by Python's Pillow)

# Features
- Right-click on a .png (or any other image) displays metadata info in macOS Finder
- Click on the metadata to copy it to Clipboard
- Displays **prompt, CFG scale, resolution** etc. added by common AI Art generators
- Supports information from **Webui from AUTOMATIC1111, InvokeUI** etc 

![](https://github.com/anastasiuspernat/UnderPillow/blob/main/Screenshot.jpg?raw=true)

# Installation
- Needs Python & Pillow installed on your macOS (will remove this dependancy)
- **Download** from releases 
- Move from **Downloads to Applications**
- Run app and **choose folders** you keep your images in
- Go to  System Preferences -> Extensions -> Finder Extensions and enable **UnderPillow Finder**
- You can now use new Finder's UnderPillow toolbar item to add folders to UnderPillow

# TODO
- Make "Launch UnderPillow" item work
- Don't display errors on the menu
- Support more PNG data formats
- Drop python requirement
