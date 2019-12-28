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
import Alamofire
import SwiftyJSON
import SDWebImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var imagePicker = UIImagePickerController()
    let flowerURL = "https://en.wikipedia.org/w/api.php"
    
    override func viewDidLoad() {
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        
    }
   
    
    //MARK: - Networking
    func getFlowerData(flowerName : String) {
        
        let parameters : [String:String] = [
        "format" : "json",
        "action" : "query",
        "prop" : "extracts|pageimages",
        "exintro" : "",
        "explaintext" : "",
        "titles" : flowerName,
        "indexpageids" : "",
        "redirects" : "1",
        "pithumbsize" : "500"
        ]

        Alamofire.request(flowerURL, method: .get, parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess {
            print("Succes we got the flower data")
            let flowerJSON : JSON = JSON(response.result.value!)
            print(flowerJSON)
            
                let pageid = flowerJSON["query"]["pageids"][0].stringValue
                let flowerDescription = flowerJSON["query"]["pages"][pageid]["extract"].stringValue
                let flowerURL = flowerJSON["query"]["pages"][pageid]["thumbnail"]["source"].stringValue
                self.imageView.sd_setImage(with: URL(string: flowerURL))
                self.label.text = flowerDescription
                
                
                
                
        }
            else { print("Error \(String(describing: response.result.error))")}
    }
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
                self.getFlowerData(flowerName: firstResult.identifier)
                self.navigationItem.title = firstResult.identifier.capitalized
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

