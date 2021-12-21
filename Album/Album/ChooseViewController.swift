//
//  ChooseViewController.swift
//  Album
//
//  Created by nju on 2021/12/21.
//

import UIKit
import Vision

protocol AddPhotoDelegate {
    func addPhoto(type: String, photo: UIImage)
}

class ChooseViewController: UIViewController {
    
    @IBOutlet weak var PhotoLibraryButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var contentPhoto: UIImageView!
    
    var addPhotoDelegate: AddPhotoDelegate?
    
    let semphore = DispatchSemaphore(value: ChooseViewController.maxInflightBuffer)
    var inflightBuffer = 0
    static let maxInflightBuffer = 2
    
    lazy var ImgClassificationRequest: VNCoreMLRequest = {
        do {
            let classifier = try snacks(configuration: MLModelConfiguration())
            let model = try VNCoreMLModel(for: classifier.model)
            let request = VNCoreMLRequest(model: model, completionHandler: {
                [weak self] request, error in
                self?.processImgObservations(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        }
        catch {
            fatalError("Failed to create image classification request")
        }
    }()
    
    func processImgObservations(for request: VNRequest, error: Error?) {
        if let results = request.results as? [VNClassificationObservation] {
            if !results.isEmpty {
                var objectType = "others"
                if results[0].confidence > 0.9 {
                    objectType = results[0].identifier
                }
                self.addPhotoDelegate?.addPhoto(type: objectType, photo: contentPhoto.image!)
            }
        }
        else if let error = error {
            print("an error is encountered: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    @IBAction func takePicture() {
      presentPhotoPicker(sourceType: .camera)
    }

    @IBAction func choosePhoto() {
      presentPhotoPicker(sourceType: .photoLibrary)
    }
    
    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
      let picker = UIImagePickerController()
      picker.delegate = self
      picker.sourceType = sourceType
      present(picker, animated: true)
    }

    func classify(image: UIImage) {
      let cgImage = image.cgImage!
      DispatchQueue.main.async {
          let handler = VNImageRequestHandler(cgImage: cgImage)
          do {
              try handler.perform([self.ImgClassificationRequest])
          } catch {
              print("Failed to perform classification: \(error)")
          }
          self.semphore.signal()
      }
  }
    
    func classify(sampleBuffer: CMSampleBuffer) {
            if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                semphore.wait()
                inflightBuffer += 1
                if inflightBuffer >= ChooseViewController.maxInflightBuffer {
                    inflightBuffer = 0
                }
                DispatchQueue.main.async {
                    let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
                    do {
                        try handler.perform([self.ImgClassificationRequest])
                    } catch {
                        print("Failed to perform classification: \(error)")
                    }
                    self.semphore.signal()
                }
                
            } else {
                print("Create pixel buffer failed")
            }
        }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ChooseViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true)

    let image = info[.originalImage] as! UIImage
    contentPhoto.image = image

    classify(image: image)
  }
}

extension ChooseViewController: VideoCaptureDelegate {
    func videoCapture(capture: VideoCapture, didCaptureVideoFrame sampleBuffer: CMSampleBuffer) {
        self.classify(sampleBuffer: sampleBuffer)
    }
}
