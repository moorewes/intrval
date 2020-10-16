//
//  InterfaceController.swift
//  Interval WatchKit Extension
//
//  Created by Wesley Moore on 3/31/16.
//  Copyright © 2016 Wes Moore. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {

    // MARK: - Properties
    
    private var dataController = DataController.main
    
    var counters: [WatchCounter]?
    
    var currentInterval: WatchCounter?
    
    // MARK: - IBOutlets
    
    @IBOutlet var counterSelectPicker: WKInterfacePicker!
    @IBOutlet var secondUnitToggle: WKInterfaceSwitch!
    
    // MARK: - IBActions
    
    @IBAction func didSelectCounterItem(_ value: Int) {
        guard let counters = counters else { return }
        
        let counter = counters[value]
        currentInterval = counter
        dataController.complicationCounter = counter
        
        updateComplication()
    }
    
    @IBAction func didToggleSecondUnit(_ value: Bool) {
        UserSettings.showOnlyOneUnit = !value
        updateComplication()
    }
    
    // MARK: - Life Cycle
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        setupView()
        
        updateUI()
        
        setupDataUpdateObserver()
    }
    
    override func willActivate() {
        super.willActivate()
        updateUI()
    }

    // MARK: - Convenience
    
    private func updateUI() {
        counters = dataController.allCounters()
        refreshCounterPickerItems()
    }
    
    @objc private func dataDidUpdate() {
        updateUI()
    }
    
    private func setupView() {
        let showSecondUnit = !UserSettings.showOnlyOneUnit
        secondUnitToggle.setOn(showSecondUnit)
        refreshCounterPickerItems()
    }
    
    private func setupDataUpdateObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(dataDidUpdate),
                                               name: .counterDataDidUpdate,
                                               object: nil)
    }
    
    private func refreshCounterPickerItems() {
        let items = counterPickerItems()
        counterSelectPicker.setItems(items)
        
        if let index = selectedCounterPickerItemIndex() {
            counterSelectPicker.setSelectedItemIndex(index)
        }
        
    }
    
    private func counterPickerItems() -> [WKPickerItem] {
        guard let counters = counters else {
            let item = WKPickerItem()
            item.title = "add on iPhone"
            return [item]
        }
        
        var items = [WKPickerItem]()
        for counter in counters {
            let item = WKPickerItem()
            item.title = counter.title
            items.append(item)
        }
        
        return items
    }
    
    private func selectedCounterPickerItemIndex() -> Int? {
        guard let counters = counters,
              let complicationCounter = dataController.complicationCounter else {
            return nil
        }
        
        return counters.firstIndex(of: complicationCounter)
    }

    private func updateComplication() {
        if let delegate = WKExtension.shared().delegate as? ExtensionDelegate {
            delegate.updateComplication()
        }
    }

}
