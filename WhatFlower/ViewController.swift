//
//  ViewController.swift
//  WhatFlower
//
//  Created by Glad Poenaru on 2019-12-26.
//  Copyright © 2019 Glad Poenaru. All rights reserved.
//
// Best Project Flower
import UIKit
import Vision
import CoreML


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageView.image = userPickedImage
            guard let ciflowerImage = CIImage(image:userPickedImage) else { fatalError("Can not convert image to CIImage")}
        detectFlower(flowerImage: ciflowerImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detectFlower(flowerImage: CIImage) {
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else {fatalError("Loading CoreML model failer")}
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {fatalError("Model failed to process results")}
            print(results)
            if let firstResult = results.first {
                self.navigationItem.title = firstResult.identifier
            } else { self.navigationItem.title = "I dont know what flower it is"}
            
       
        }
        let handler = VNImageRequestHandler(ciImage: flowerImage)
        do {
            try handler.perform([request])
        } catch
        { print("Error with the handler, \(error)")}
        
        
    }
    

    @IBAction func cameraTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}

