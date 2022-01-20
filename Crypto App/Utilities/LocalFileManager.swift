//
//  LocalFileManager.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-01-20.
//

import Foundation
import SwiftUI

class LocalFileManager {
    static let instance = LocalFileManager()
    
    private init() {
        
    }
    
    func saveImage(image: UIImage, imageName: String, folderName: String) {
        
        createFolderIfNeeded(folderName: folderName)
        
        guard
            let data = image.pngData(),
            let url = getURLForImage(imageName: imageName, folderName: folderName)
        else { return }
        
        do {
            try data.write(to: url)
        } catch {
            print("❌ Error saving image \(imageName): \(error)")
        }
    }
    
    func getImage(imageName: String, folderName: String) -> UIImage? {
        guard
            let url = getURLForImage(imageName: imageName, folderName: folderName),
            FileManager.default.fileExists(atPath: url.path) else {
                return nil
            }
        
        return UIImage(contentsOfFile: url.path)
    }
    
    private func createFolderIfNeeded(folderName: String) {
        guard
            let url = getURLForFolder(name: folderName)
        else { return }
        
        if FileManager.default.fileExists(atPath: url.path) {
           return
        }
        
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("❌ Error creating directory \(folderName): \(error)")
        }
    }
    
    private func getURLForFolder(name: String) -> URL? {
        guard
            let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        else { return nil}
        
        return url.appendingPathComponent(name)
    }
    
    private func getURLForImage(imageName: String, folderName: String) -> URL? {
        guard
            let folderUrl = getURLForFolder(name: folderName)
        else { return nil }
        
        return folderUrl.appendingPathComponent(imageName + ".png")
    }
}
