//
//  ViewControllerSnapshots.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22.01.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation
import Cocoa

class ViewControllerSnapshots: NSViewController, SetDismisser, SetConfigurations {

    private var hiddenID: Int?
    private var config: Configuration?
    private var snapshotsloggdata: SnapshotsLoggData?
    private var delete: Bool = false

    @IBOutlet weak var snapshotstable: NSTableView!
    @IBOutlet weak var localCatalog: NSTextField!
    @IBOutlet weak var offsiteCatalog: NSTextField!
    @IBOutlet weak var offsiteUsername: NSTextField!
    @IBOutlet weak var offsiteServer: NSTextField!
    @IBOutlet weak var backupID: NSTextField!
    @IBOutlet weak var sshport: NSTextField!
    @IBOutlet weak var info: NSTextField!
    @IBOutlet weak var deletebutton: NSButton!
    @IBOutlet weak var deletenum: NSTextField!
    @IBOutlet weak var numberOflogfiles: NSTextField!
    @IBOutlet weak var progressdelete: NSProgressIndicator!

    // Source for CopyFiles and Ssh
    // self.presentViewControllerAsSheet(self.ViewControllerAbout)
    lazy var viewControllerSource: NSViewController = {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "CopyFilesID"))
            as? NSViewController)!
    }()

    private func info (num: Int) {
        switch num {
        case 1:
            self.info.stringValue = "Not a snapshot task..."
        default:
            self.info.stringValue = ""
        }
    }

    @IBAction func delete(_ sender: NSButton) {
        if let delete = Int(self.deletenum.stringValue) {
            guard delete < self.snapshotsloggdata?.expandedcatalogs?.count ?? 0 else { return }
            self.deletebutton.isEnabled = false
            self.initiateProgressbar()
            self.deletesnapshotcatalogs()
        } else {
            return
        }
        self.delete = true
    }

    @IBAction func getindex(_ sender: NSButton) {
        self.presentViewControllerAsSheet(self.viewControllerSource)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.snapshotstable.delegate = self
        self.snapshotstable.dataSource = self
        ViewControllerReference.shared.setvcref(viewcontroller: .vcsnapshot, nsviewcontroller: self)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.deletebutton.isEnabled = false
        self.delete = false
        globalMainQueue.async(execute: { () -> Void in
            self.snapshotstable.reloadData()
        })
    }

    private func deletesnapshotcatalogs() {

    }

    // Progress bar
    private func initiateProgressbar() {
        if let deletenum = Double(self.deletenum.stringValue) {
            self.progressdelete.maxValue = deletenum
        } else {
            return
        }
        self.progressdelete.minValue = 0
        self.progressdelete.doubleValue = 0
        self.progressdelete.startAnimation(self)
    }

    private func updateProgressbar(_ value: Double) {
        self.progressdelete.doubleValue = value
    }
}

extension ViewControllerSnapshots: DismissViewController {

    // Protocol DismissViewController
    func dismiss_view(viewcontroller: NSViewController) {
        self.dismissViewController(viewcontroller)
    }
}

extension ViewControllerSnapshots: GetSource {

    // Returning hiddenID as Index
    func getSource(index: Int) {
        self.hiddenID = index
        self.config = self.configurations!.getConfigurations()[self.configurations!.getIndex(hiddenID!)]
        self.snapshotsloggdata = SnapshotsLoggData(config: self.config!)
        self.localCatalog.stringValue = self.config!.localCatalog
        self.offsiteCatalog.stringValue = self.config!.offsiteCatalog
        self.offsiteUsername.stringValue = self.config!.offsiteUsername
        self.offsiteServer.stringValue = self.config!.offsiteServer
        self.backupID.stringValue = self.config!.backupID
        if config!.sshport != nil {
            self.sshport.stringValue = String(describing: self.config!.sshport!)
        }
        if self.config!.task == "snapshot" {
            self.info(num: 0)
        } else {
            self.info(num: 1)
        }
    }
}

extension ViewControllerSnapshots: UpdateProgress {
    func processTermination() {
        if delete {
            self.deletesnapshotcatalogs()
        } else {
            self.deletebutton.isEnabled = true
            self.snapshotsloggdata?.processTermination()
            globalMainQueue.async(execute: { () -> Void in
                self.snapshotstable.reloadData()
            })
        }
    }

    func fileHandler() {
        //
    }
}

extension ViewControllerSnapshots: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        guard self.snapshotsloggdata?.snapshotsloggdata != nil else {
            self.numberOflogfiles.stringValue = "Number of rows:"
            return 0
        }
        self.numberOflogfiles.stringValue = "Number of rows: " + String(self.snapshotsloggdata?.snapshotsloggdata!.count ?? 0)
        return (self.snapshotsloggdata?.snapshotsloggdata!.count ?? 0)
    }
}

extension ViewControllerSnapshots: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard row < self.snapshotsloggdata?.snapshotsloggdata!.count ?? 0 else { return nil }
        let object: NSDictionary = self.snapshotsloggdata!.snapshotsloggdata![row]
        return object[tableColumn!.identifier] as? String
    }
}

extension ViewControllerSnapshots: Reloadandrefresh {
    func reloadtabledata() {
        self.snapshotsloggdata = nil
        self.deletebutton.isEnabled = false
        globalMainQueue.async(execute: { () -> Void in
            self.localCatalog.stringValue = ""
            self.offsiteCatalog.stringValue = ""
            self.offsiteUsername.stringValue = ""
            self.offsiteServer.stringValue = ""
            self.backupID.stringValue = ""
            self.sshport.stringValue = ""
            self.snapshotstable.reloadData()
        })
    }
}
