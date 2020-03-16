//
//  CountdownViewController.swift
//  Countdown
//
//  Created by Paul Solt on 5/8/19.
//  Copyright © 2019 Lambda, Inc. All rights reserved.
//

import UIKit

class CountdownViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var countdownPicker: UIPickerView!
    
    
    // MARK: - Properties
    
    private let countdown = Countdown()
    
    lazy private var countdownPickerData: [[String]] = {
        //[["1", "2", "3"]["min"]["1", "2", "3"]["sec"]]
        // Create string arrays using numbers wrapped in string values: ["0", "1", ... "60"]
        let minutes: [String] = Array(0...60).map { String($0) }
        let seconds: [String] = Array(0...59).map { String($0) }
        
        // "min" and "sec" are the unit labels
        let data: [[String]] = [minutes, ["min"], seconds, ["sec"]]
        return data
    }()
    
    private var duration: TimeInterval {
        //convert from minutes + seconds to total seconds
        let minutesString = countdownPicker.selectedRow(inComponent: 0)
        let secondString = countdownPicker.selectedRow(inComponent: 2)
        
        let minutes = Int(minutesString)
        let seconds = Int(secondString)
        
        let totalSeconds = TimeInterval(minutes * 60 + seconds)
        return totalSeconds
    }
    
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SS"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        countdownPicker.dataSource = self
        countdownPicker.delegate = self
        
        //set default duration of 1 min 30 sec on the picker view
        countdownPicker.selectRow(30, inComponent: 2, animated: true)
        countdownPicker.selectRow(1, inComponent: 0, animated: true)
        
        countdown.delegate = self
        countdown.duration = self.duration
        
        //use a fixed width font, so numbers don't pop
        timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeLabel.font.pointSize, weight: .medium)
        updateViews()
        
        startButton.layer.cornerRadius = 30
        resetButton.layer.cornerRadius = 30
    }
    
    // MARK: - Actions
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        countdown.start()
    }
    
    private func timerFinished(timer: Timer) {
        showAlert()
    }
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        countdown.reset()
        updateViews()
    }
    
    // MARK: - Private
    
    private func showAlert() {
        let alert = UIAlertController(title: "Timer Finished!", message: "Your countdown is over", preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    private func updateViews() {
        startButton.isEnabled = true
        
        switch countdown.state {
        case .started:
            timeLabel.text = string(from: countdown.timeRemaining)
            startButton.isEnabled = false
        case .finished:
            timeLabel.text = string(from: 0)
        case .reset:
            timeLabel.text = string(from: countdown.duration)
        }
    }
    
    private func string(from duration: TimeInterval) -> String {
        let date = Date(timeIntervalSinceReferenceDate: duration)
        return dateFormatter.string(from: date)
    }
}

extension CountdownViewController: CountdownDelegate {
    func countdownDidUpdate(timeRemaining: TimeInterval) {
        updateViews()
    }
    
    func countdownDidFinish() {
        showAlert()
        updateViews()
    }
}

extension CountdownViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return countdownPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countdownPickerData[component].count
    }
}

extension CountdownViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let timeValue = countdownPickerData[component][row]
        return String(timeValue)
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 50
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //update UI
        countdown.duration = duration
        updateViews()
    }
    
    
    
}
