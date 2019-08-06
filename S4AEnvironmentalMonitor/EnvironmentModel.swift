//
//  EnvironmentModel.swift
//  S4AEnvironmentalMonitor
//
//  Created by Carl Peto on 06/08/2019.
//  Copyright © 2019 Carl Peto. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class EnvironmentModel: NSObject, BindableObject {
    var willChange = PassthroughSubject<Void, Never>()
    
    var temperatureDescription: String {
        if let temperature = temperature {
            return "\(temperature)C"
        } else {
            return "--"
        }
    }
    
    var humidityDescription: String {
        if let humidityPct = humidityPct {
            return "\(humidityPct)%"
        } else {
            return "--"
        }
    }
    
    var temperature: Int? {
        willSet {
            willChange.send(())
        }
    }
    
    var humidityPct: Int? {
        willSet {
            willChange.send(())
        }
    }
    
    var serialPort: ORSSerialPort? {
        willSet {
            if let serialPort = serialPort, newValue == nil {
                serialPort.close()
            }
        }

        didSet {
            if let serialPort = serialPort {
                serialPort.delegate = self
                serialPort.baudRate = 9600
                serialPort.open()
            } else {
                temperature = nil
                humidityPct = nil
            }
        }
    }
    
    private func setSerialPortFromCandidates(ports: [ORSSerialPort]) {
        if let usbModemPort = ports.filter({$0.description.starts(with: "usbmodem")}).first {
            self.serialPort = usbModemPort
        }
    }
    
    var serialPortManager: ORSSerialPortManager? {
        didSet {
            if let serialPortManager = serialPortManager {
                setSerialPortFromCandidates(ports: serialPortManager.availablePorts)
            }
        }
    }

    var newPortsObserver: AnyObject?
    var serialPortString = ""

    private func parseTempHumidity(line: String) -> (temp: Int?, humidity: Int?) {
        // strings will be of this format
        // t(C): 28, h(%): 50
        // split by :, gives...
        // t(C)
        //  28, h(%)
        //  50
        // split part 2 by ,
        // then you have what you need
        let parts = line.split(separator: ":").dropFirst()
        guard let tempString = parts.first, let temp = tempString.split(separator: ",").first, let tempC = Int(temp) else {
            return (nil, nil)
        }

        guard let humidity = parts.last else {
            return (tempC, nil)
        }

        return (tempC, Int(humidity))
    }

    fileprivate func newSerialLine(line: String) {
        print("serial port data \(serialPortString)")
        let updatedEnvironment = parseTempHumidity(line: line)
        print("read as temp: \(updatedEnvironment.temp ?? -1), humidity: \(updatedEnvironment.humidity ?? -1)")
        temperature = updatedEnvironment.temp
        humidityPct = updatedEnvironment.humidity
    }

    fileprivate func newSerialPortData(data: String) {
        if let _ = serialPortString.lastIndex(of: "\n") {
            if let line = serialPortString.split(separator: "\n").first {
                newSerialLine(line: String(line))
            }
        }
    }
    
    var monitoring: Bool = false {
        didSet {
            if monitoring {
                newPortsObserver =
                    NotificationCenter.default.addObserver(
                        forName: NSNotification.Name.ORSSerialPortsWereConnected,
                        object: nil,
                        queue: nil) { [weak self] notification in

                            if let ports = notification.userInfo?[ORSConnectedSerialPortsKey] as? [ORSSerialPort] {
                                self?.setSerialPortFromCandidates(ports: ports)
                            }
                                
                }

                // instantiate it after registering notifications so we get all startup notifications
                serialPortManager = ORSSerialPortManager.shared()
            } else {
                serialPort = nil
                newPortsObserver = nil
                serialPortManager = nil
            }
        }
    }
}

extension EnvironmentModel: ORSSerialPortDelegate {
    func serialPortWasRemoved(fromSystem serialPort: ORSSerialPort) {
        if serialPort == self.serialPort {
            self.serialPort = nil
        }
    }
    
    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        if let serialPortString = String(data: data, encoding: .utf8) {
            newSerialPortData(data: serialPortString)
        }
    }
}
