This module aims to make the ColdBox Platform mimic FW/1 to allow people an easy way to transition from FW/1 ColdBox.  

# Installation

1. Uninstall the FW/1 CFC from your codebase
2. Install this module into your app with `install coldbox-modules/cbox-fw1-compat` in CommandBox
3. Install the ColdBox Platform with `install coldbox` in CommandBox
4. Switch over the bootstrap boilerplate in your root `Application.cfc` to load ColdBox instead.  
If your `Application.cfc` uses inheritance, switch the `extends` property on your component to point to `coldbox.system.Bootstrap`
5. Start your app up and test!

This module is a work in progress, so please report any errors you receive so we can fix them.  

# Items left to implement

* URL Routing
* DI/1 style injections
* App settings being read from `Application.cfc`
* Subsystems (This may not be implemented depending on demand and complexity) 
