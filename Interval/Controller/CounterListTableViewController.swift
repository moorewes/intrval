//
//  CounterListTableViewController.swift
//  Interval
//
//  Created by Wesley Moore on 8/1/17.
//  Copyright © 2017 Wes Moore. All rights reserved.
//

import UIKit
import CoreData

class CounterListTableViewController: UITableViewController {
    
    // MARK: - Types
        
    private enum SegueID {
        
        static let EditCounter = "editCounter"
        
    }
    
    // MARK: - Properties
    
    private var dataController = DataController.main
    private var fetchedResultsController: NSFetchedResultsController<Counter>!
    private var refreshCellsTimer: Timer?
    
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
        
        startAutoUpdatingCellCounters()
    }
        
    deinit {
        stopAutoUpdatingCellCounters()
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        stopAutoUpdatingCellCounters()
        
        if let vc = segue.destination as? CounterDetailTableViewController {
            let childMOC = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            childMOC.parent = fetchedResultsController.managedObjectContext
            vc.moc = childMOC
            vc.delegate = self
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let id = fetchedResultsController.object(at: indexPath).objectID
                vc.counter = childMOC.object(with: id) as? Counter
            } else {
                vc.counter = dataController.newCounter(in: childMOC)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func setupFetchedResultsController() {
        let moc = DataController.main.viewContext
        
        let fetchRequest: NSFetchRequest<Counter> = Counter.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let controller = NSFetchedResultsController (
            fetchRequest: fetchRequest,
            managedObjectContext: moc,
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
    
    private func startAutoUpdatingCellCounters() {
        refreshCellsTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.refreshCells()
        })
    }
    
    private func stopAutoUpdatingCellCounters() {
        refreshCellsTimer?.invalidate()
    }
    
    private func refreshCells() {
        for cell in tableView.visibleCells {
            guard let counterCell = cell as? CounterTableViewCell else { continue }
            counterCell.refreshIntervalLabel()
        }
    }
    
    private func saveData() {
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
        guard let section = fetchedResultsController.sections?.first else { return 0 }
        return section.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CounterTableViewCell.cellID,
                                                 for: indexPath) as! CounterTableViewCell
        cell.counter = fetchedResultsController.object(at: indexPath)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: SegueID.EditCounter, sender: nil)
        tableView.deselectRow(at: indexPath, animated: false)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let object = fetchedResultsController.object(at: indexPath)
            fetchedResultsController.managedObjectContext.delete(object)
            saveData()
        }
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
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        default: break
        }
        print(controller.managedObjectContext.hasChanges)
    }
    
}

// MARK: - Counter Detail Delegate

extension CounterListTableViewController: CounterDetailDelegate {
    
    func didFinish(viewController: CounterDetailTableViewController, didSave: Bool) {
        guard didSave,
              let moc = viewController.moc,
              moc.hasChanges else {
            dismiss(animated: true)
            return
        }
        
        moc.perform {
            do {
                try moc.save()
            } catch {
                fatalError(error.localizedDescription)
            }
            
            self.dataController.saveCounters()
        }
        
        dismiss(animated: true)
        
        startAutoUpdatingCellCounters()
    }
    
}
