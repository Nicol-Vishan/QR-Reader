//
//  ScannerViewController.swift
//  QR Reader
//
//  Created by Nicol Vishan on 05/10/2020.
//

import UIKit
import AVFoundation

class ScannerViewController: UIViewController {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageView: UIVisualEffectView!
    
    let captureMetadataOutput = AVCaptureMetadataOutput()
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        captureSession.startRunning()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.title = "Scaning..."
    }
    
    func setup() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: .video, position: .back)
        
        guard let captureDevice = deviceDiscoverySession.devices.first else{
            print("Failed to get the camera device")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            //Creating the seassion for capture the qr code and calling other related functions
            captureSession.addInput(input)
            captureSession.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
            setupVideoLayer()
            setupDetectingBox()
            
        }catch {
            print(error)
            return
        }
    }
    
    func setupDetectingBox() {
        //Creating the qr frame for capture the qr code
        qrCodeFrameView = UIView()

        if let qrCodeframeView = qrCodeFrameView {
            qrCodeFrameView?.layer.borderColor = UIColor.orange.cgColor
            qrCodeFrameView?.layer.borderWidth = 2
            view.addSubview(qrCodeframeView)
            view.bringSubviewToFront(qrCodeframeView)
            view.bringSubviewToFront(messageView)
            view.bringSubviewToFront(messageLabel)
        }
    }
    
    func setupVideoLayer() {
        //Setup the video capturing screen
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame =  view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
    }
    
}

extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        //When frame detect an qr code this function called
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No QR code detected"
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            
            let barCodeObject =  videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                messageLabel.text = metadataObj.stringValue
            }
        }
    }
}
