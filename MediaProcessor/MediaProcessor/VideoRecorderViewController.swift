//
//  VideoRecorderViewController.swift
//  MediaProcessor
//
//  Created by Girish Rathod on 23/03/22.
//

import UIKit
import AVFoundation

class CameraController {
    var captureSession: AVCaptureSession?
    
    var frontCamera: AVCaptureDevice?
    var rearCamera: AVCaptureDevice?
    
    var currentCameraPosition: CameraPosition?
    var frontCameraInput: AVCaptureDeviceInput?
    var rearCameraInput: AVCaptureDeviceInput?
    
    public enum CameraPosition {
        case front
        case rear
    }
    enum CameraControllerError: Swift.Error {
           case captureSessionAlreadyRunning
           case captureSessionIsMissing
           case inputsAreInvalid
           case invalidOperation
           case noCamerasAvailable
           case unknown
       }

    var previewLayer: AVCaptureVideoPreviewLayer?
    
    func displayPreview(on view: UIView) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }

        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait

        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.frame
    }
    
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        func createCaptureSession() {
            self.captureSession = AVCaptureSession()
        }
        func configureCaptureDevices() throws {
            //1
            let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera, .builtInTelephotoCamera], mediaType: AVMediaType.video, position: .unspecified)
            guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
               fatalError()
            }

            let myCameras: [AVCaptureDevice]? = nil
            let cameras = (session.devices.compactMap{$0})
//            if (cameras == nil){ throw CameraControllerError.noCamerasAvailable }
            
//            guard let cameras = myCameras, !cameras.isEmpty else { throw CameraControllerError.noCamerasAvailable }
             
            //2
            for camera in cameras {
                if camera.position == .front {
                    self.frontCamera = camera
                }
             
                if camera.position == .back {
                    self.rearCamera = camera
             
                    try camera.lockForConfiguration()
                    camera.focusMode = .continuousAutoFocus
                    camera.unlockForConfiguration()
                }
            }
        }
        func configureDeviceInputs() throws {
        //3
           guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
        
           //4
           if let rearCamera = self.rearCamera {
               self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
        
               if captureSession.canAddInput(self.rearCameraInput!) { captureSession.addInput(self.rearCameraInput!) }
        
               self.currentCameraPosition = .rear
           }
        
           else if let frontCamera = self.frontCamera {
               self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
        
               if captureSession.canAddInput(self.frontCameraInput!) { captureSession.addInput(self.frontCameraInput!) }
               else { throw CameraControllerError.inputsAreInvalid }
        
               self.currentCameraPosition = .front
           }
        
           else { throw CameraControllerError.noCamerasAvailable }
        }
        func configurePhotoOutput() throws {
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            
               self.photoOutput = AVCapturePhotoOutput()
               self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecJPEG])], completionHandler: nil)
            
               if captureSession.canAddOutput(self.photoOutput) { captureSession.addOutput(self.photoOutput) }
            
               captureSession.startRunning()
        }

        DispatchQueue(label: "prepare").async {
           do {
               createCaptureSession()
               try configureCaptureDevices()
               try configureDeviceInputs()
               try configurePhotoOutput()
           }
               
           catch {
               DispatchQueue.main.async {
                   completionHandler(error)
               }
               
               return
           }
           
           DispatchQueue.main.async {
               completionHandler(nil)
           }
        }
    }
    
}

class VideoRecorderViewController: UIViewController {

    let cameraController = CameraController()
    
    override var prefersStatusBarHidden: Bool { return true }
    
    ///Displays a preview of the video output generated by the device's cameras.
    @IBOutlet fileprivate var capturePreviewView: UIView!
    
    @IBOutlet fileprivate var captureButton: UIButton!

    ///Allows the user to put the camera in video mode.
    @IBOutlet fileprivate var videoModeButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCameraController()
        styleCaptureButton()
        // Do any additional setup after loading the view.
    }
    
    func configureCameraController() {
        cameraController.prepare {(error) in
            if let error = error {
                print(error)
            }
     
            try? self.cameraController.displayPreview(on: self.capturePreviewView)
        }
    }
    
    func styleCaptureButton() {
        captureButton.layer.borderColor = UIColor.black.cgColor
        captureButton.layer.borderWidth = 2

        captureButton.layer.cornerRadius = min(captureButton.frame.width, captureButton.frame.height) / 2
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

//func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection)
