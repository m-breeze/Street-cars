//
//  Log.swift
//  StreetCars
//
//  Created by Marina Khort on 24.05.2021.
//

import Foundation

class Logger {
	var logFile: URL?
	
	init() {
		self.logFile = createLogFile()
	}
	
	func createLogFile() -> URL {
		let path = "khort/Documents/University/6-semestr/rsoi"
		let fileName = "carLogfile.txt"
		let userDir = try! FileManager.default.url(for: .userDirectory, in: .localDomainMask, appropriateFor: nil, create: false)
		let logPath = userDir.appendingPathComponent(path).appendingPathComponent(fileName)
		let filePath = logPath.path
		
		if(!FileManager.default.fileExists(atPath: filePath)) {
			FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
		} else {
			print("File is already created")
		}
		return logPath
	}
	
	func writeLog(text: String) {
		let today = Date()
		let formatter = DateFormatter()
		formatter.dateFormat = "HH:mm:ss:SSSS, dd.MM.y"
		let datetime = formatter.string(from: today)
	
		if let fileUpdater = try? FileHandle(forUpdating: logFile!) {
			fileUpdater.seekToEndOfFile()
			fileUpdater.write("\(datetime) \(text)\n".data(using: .utf8)!)
			fileUpdater.closeFile()
		} else {
			try? text.data(using: .utf8)?.write(to: logFile!)
		}
	}
	
	func deleteTextInFile() {
		let logFile = createLogFile()
		try? FileManager.default.removeItem(at: logFile)
	}
}
