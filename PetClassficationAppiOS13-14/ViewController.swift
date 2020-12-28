//
//  ViewController.swift
//  PetClassficationAppiOS13-14
//
//  Created by Sonali Patel on 12/28/20.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var petImageView: UIImageView!
    
    let petImagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        petImagePicker.delegate = self
        petImagePicker.sourceType = .camera
        petImagePicker.allowsEditing = true
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let userPickedPetImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            fatalError("Failed at capturing the image from info dict")
        }
        
        DispatchQueue.main.async {
            self.petImageView.image = userPickedPetImage
        }
        
        guard let petCIImage = CIImage(image: userPickedPetImage) else {
            fatalError("Failed at converting UIImage to CIImage")
        }
        
        self.detect(petImage: petCIImage)
        self.petImagePicker.dismiss(animated: true, completion: nil)
    }

    func detect(petImage: CIImage) {
        let classfierModel = PetImageClassifier().model
        guard let petModel = try? VNCoreMLModel(for: classfierModel) else {
            fatalError("Failed at converting the classifier model to VNCoreMLModel")
        }
        
        let request = VNCoreMLRequest(model: petModel) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Failed at converting the results to VNClassificationObservation")
            }
            
            if let firstResult = results.first {
                print(firstResult.identifier)
                DispatchQueue.main.async {
                    self.navigationItem.title = firstResult.identifier.capitalized
                }
            }
            
        }
        
        let handler = VNImageRequestHandler(ciImage: petImage)
        
        do {
            try handler.perform([request])
        } catch {
            print("Error performing request on handler")
        }
        
    }
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(petImagePicker, animated: true, completion: nil)
    }
    
}

