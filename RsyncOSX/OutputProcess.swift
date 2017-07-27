//
//  outputProcess.swift
//
//  Created by Thomas Evensen on 11/01/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable syntactic_sugar

import Foundation

protocol RsyncError: class {
    func rsyncerror()
}

final class OutputProcess {

    // calculated number of files
    // output Array to keep output from rsync in
    private var output: Array<String>?
    // output Array temporary indexes
    private var startIndex: Int?
    private var endIndex: Int?
    // Maxnumber
    private var maxNumber: Int = 0

    // Error delegate
    weak var errorDelegate: ViewControllertabMain?
    // Last record of rsync 
    weak var lastrecordDelegate: ViewControllertabMain?

    func getMaxcount() -> Int {
        return self.maxNumber
    }

    func getOutputCount () -> Int {
        guard self.output != nil else {
            return 0
        }
        return self.output!.count
    }

    func getOutput () -> Array<String> {
        guard self.output != nil else {
            return [""]
        }
        return self.output!
    }

    // Add line to output
    func addLine (_ str: String) {
        let sentence = str

        if self.startIndex == nil {
            self.startIndex = 0
        } else {
            self.startIndex = self.getOutputCount()+1
        }
        sentence.enumerateLines { (line, _) in
            if line.characters.last != "/" {
                self.output!.append(line)
            }
        }
        self.endIndex = self.output!.count
        // Set maxnumber so far
        self.maxNumber = self.endIndex!

        // rsync error
        let error = sentence.contains("rsync error:")
        // There is an error in transferring files
        // We only informs in main view if error
        if error {
            if let pvc = Configurations.shared.viewControllertabMain {
                self.errorDelegate = pvc as? ViewControllertabMain
                self.errorDelegate?.rsyncerror()
            }
        }
    }

    // Add line to output
    func addLine2 (_ str: String) {
        let sentence = str

        if self.startIndex == nil {
            self.startIndex = 0
        } else {
            self.startIndex = self.getOutputCount()+1
        }
        sentence.enumerateLines { (line, _) in
            self.output!.append(line)
        }

        self.endIndex = self.output!.count
        // Set maxnumber so far
        self.maxNumber = self.endIndex!

    }

    init () {
        self.output = Array<String>()
    }
 }