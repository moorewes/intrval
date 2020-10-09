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
    
    var counters: [WatchCounter] = []
    
    var currentInterval: WatchCounter?
    
    
    // MARK: - IBOutlets
    
    @IBOutlet var counterSelectPicker: WKInterfacePicker!
    @IBOutlet var secondUnitToggle: WKInterfaceSwitch!
    
    // MARK: - IBActions
    
    @IBAction func didSelectCounterItem(_ value: Int) {
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Convenience
    
    private func updateUI() {
        refreshCounterPickerItems()
    }
    
    private func setupView() {
        let showSecondUnit = !UserSettings.showOnlyOneUnit
        secondUnitToggle.setOn(showSecondUnit)
        refreshCounterPickerItems()
    }
    
    private func setupDataUpdateObserver() {
        NotificationCenter.default.addObserver(forName: .counterDataDidUpdate,
                                               object: nil,
                                               queue: nil) { [unowned self] (notification) in
            self.updateUI()
        }
    }
    
    private func refreshCounterPickerItems() {
        let items = counterPickerItems()
        counterSelectPicker.setItems(items)
        
        if let index = selectedCounterPickerItemIndex() {
            counterSelectPicker.setSelectedItemIndex(index)
        }
        
    }
    
    private func counterPickerItems() -> [WKPickerItem] {
        counters = dataController.counters
        guard !counters.isEmpty else {
            let item = WKPickerItem()
            item.title = "add counter using iPhone"
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
        guard let complicationCounter = dataController.complicationCounter else {
            return nil
        }
        
        let counters = dataController.counters
        
        return counters.firstIndex(of: complicationCounter)
    }

    private func updateComplication() {
        if let delegate = WKExtension.shared().delegate as? ExtensionDelegate {
            delegate.updateComplication()
        }
    }

}

