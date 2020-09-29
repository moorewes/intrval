//
//  CounterListTableViewController.swift
//  Interval
//
//  Created by Wesley Moore on 8/1/17.
//  Copyright © 2017 Wes Moore. All rights reserved.
//

import UIKit
import CoreData

extension Notification.Name {
    static let counterCellShouldUpdateTimeIntervalLabel = Notification.Name("counterCellShouldUpdateTimeIntervalLabel")
}

class CounterListTableViewController: UITableViewController {
    
    // MARK: - Types
    
    private struct SegueID {
        static let EditCounter = "editCounter"
    }
    
    // MARK: - Properties
    
    private var fetchedResultsController: NSFetchedResultsController<Counter>!
    
    var startupSyncComplete = false
    
    var refreshTimeIntervalTimer: Timer?
    
    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var helpBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var newIntervalButton: UIButton!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        newIntervalButton.layer.cornerRadius = newIntervalButton.frame.height/2
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        setupFetchedResultsController()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if !startupSyncComplete {
            LegacyDataController.main.transferDataToWatch()
            startupSyncComplete = true
        }
        
        refreshTimeIntervalTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            NotificationCenter.default.post(name: .counterCellShouldUpdateTimeIntervalLabel, object: nil)
        })
        
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        refreshTimeIntervalTimer?.invalidate()
        
        if let vc = segue.destination as? CounterDetailTableViewController {
                                    
            if let indexPath = tableView.indexPathForSelectedRow {
                
                vc.counter = fetchedResultsController.object(at: indexPath)
                
            } else {
                
                let newCounter = Counter(context: fetchedResultsController.managedObjectContext)
                newCounter.title = ""
                newCounter.date = Date()
                newCounter.includeTime = false
                
                vc.counter = newCounter
                
            }
            
        }
        
    }
    
    // MARK: - Convenience
    
    private func setupFetchedResultsController() {
        
        let context = DataController.main.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<Counter> = Counter.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let controller = NSFetchedResultsController (
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        controller.delegate = self
        
        do {
            try controller.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
        
        fetchedResultsController = controller
    }
    
    private func saveChanges() {
        
        do {
            try fetchedResultsController.managedObjectContext.save()
        } catch {
            fatalError("Failed to save changes, \(error)")
        }
        
    }
    
}

extension CounterListTableViewController {
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return fetchedResultsController.sections?.count ?? 0
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let section = fetchedResultsController.sections?.first else {
            return 0
        }
        
        return section.numberOfObjects
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CounterTableViewCell.id, for: indexPath) as! CounterTableViewCell
        
        cell.counter = fetchedResultsController.object(at: indexPath)
        cell.startUpdatingIntervalLabel()

        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: SegueID.EditCounter, sender: nil)
        
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
        
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let object = fetchedResultsController.object(at: indexPath)
            fetchedResultsController.managedObjectContext.delete(object)
            
            saveChanges()
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        NotificationCenter.default.removeObserver(cell)
    }
}

extension CounterListTableViewController: NSFetchedResultsControllerDelegate {
    
    // MARK: - NSFetchedResultsController Delegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
                
        switch type {
        
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            
        case .move:
            //let cell = tableView.cellForRow(at: indexPath!) as! CounterTableViewCell
            //cell.counter = anObject as? Counter
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
            
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
            //let cell = tableView.cellForRow(at: indexPath!) as! CounterTableViewCell
            //cell.counter = anObject as? Counter
            
        default: break
            
        }
    }
    
}
