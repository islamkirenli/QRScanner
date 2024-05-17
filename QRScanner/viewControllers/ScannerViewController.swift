/*
import UIKit
import AVFoundation

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var isReadingQRCode = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // QR kod tarama işlemleri
        captureSession = AVCaptureSession()

        // AVCaptureDevice oluştur (kamera)
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        // AVCaptureMetadataOutput oluştur
        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        // Kamera önizleme ekranı oluştur
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        // Taramayı başlat
        captureSession.startRunning()
    }

    func failed() {
        let ac = UIAlertController(title: "Hata", message: "QR kod okuyucu başlatılamadı", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        DispatchQueue.global(qos: .userInitiated).async {
            if (self.captureSession?.isRunning == false) {
                self.captureSession.startRunning()
            }
        }
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // QR kodu tespit edildiğinde burası çalışır
        if !isReadingQRCode {
            isReadingQRCode = true
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                
                // QR kodun içeriğini kontrol edip bir URL olup olmadığını kontrol ediyoruz
                if let url = URL(string: stringValue), UIApplication.shared.canOpenURL(url) {
                    // QR kodu bir URL içeriyorsa, kullanıcıya açıp açmayacağını soralım
                    let alertController = UIAlertController(title: "QR Kod Bulundu", message: "QR kodu tespit edildi. Açmak istiyor musunuz?", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "İptal", style: .cancel) { _ in
                        self.isReadingQRCode = false
                    }
                    let openAction = UIAlertAction(title: "Aç", style: .default) { _ in
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                    alertController.addAction(cancelAction)
                    alertController.addAction(openAction)
                    present(alertController, animated: true, completion: nil)
                } else {
                    print("Tarayıcıda açılamayan bir QR kodu tespit edildi.")
                }
            }
        }
    }
}
*/


import UIKit
import AVFoundation

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var isReadingQRCode = false
    var flashIcon: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // QR kod tarama işlemleri
        captureSession = AVCaptureSession()

        // AVCaptureDevice oluştur (kamera)
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        // AVCaptureMetadataOutput oluştur
        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        // Kamera önizleme ekranı oluştur
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        // Taramayı başlat
        captureSession.startRunning()

        // İkonu oluştur ve ekle
        flashIcon = UIImageView(image: UIImage(systemName: "flashlight.off.fill")) // Başlangıçta flaş kapalı ikonu
        flashIcon.tintColor = .white
        flashIcon.isUserInteractionEnabled = true
        flashIcon.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(flashIcon)

        // İkonun autolayout kısıtlamalarını ayarla
        NSLayoutConstraint.activate([
            flashIcon.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            flashIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            flashIcon.widthAnchor.constraint(equalToConstant: 50),
            flashIcon.heightAnchor.constraint(equalToConstant: 50)
        ])

        // İkona tıklama hareketi ekle
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(iconTapped))
        flashIcon.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func iconTapped() {
        toggleFlash()
    }

    func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }

        do {
            try device.lockForConfiguration()

            if device.torchMode == .on {
                device.torchMode = .off
                flashIcon.image = UIImage(systemName: "flashlight.off.fill") // Flaş kapalı ikonu
            } else {
                try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
                flashIcon.image = UIImage(systemName: "flashlight.on.fill") // Flaş açık ikonu
            }

            device.unlockForConfiguration()
        } catch {
            print("Flaş değiştirilemedi: \(error)")
        }
    }

    func failed() {
        let ac = UIAlertController(title: "Hata", message: "QR kod okuyucu başlatılamadı", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        DispatchQueue.global(qos: .userInitiated).async {
            if (self.captureSession?.isRunning == false) {
                self.captureSession.startRunning()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // QR kodu tespit edildiğinde burası çalışır
        if !isReadingQRCode {
            isReadingQRCode = true
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                
                // QR kodun içeriğini kontrol edip bir URL olup olmadığını kontrol ediyoruz
                if let url = URL(string: stringValue), UIApplication.shared.canOpenURL(url) {
                    // QR kodu bir URL içeriyorsa, kullanıcıya açıp açmayacağını soralım
                    let alertController = UIAlertController(title: "QR Kod Bulundu", message: "QR kodu tespit edildi. Açmak istiyor musunuz?", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "İptal", style: .cancel) { _ in
                        self.isReadingQRCode = false
                    }
                    let openAction = UIAlertAction(title: "Aç", style: .default) { _ in
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                    alertController.addAction(cancelAction)
                    alertController.addAction(openAction)
                    present(alertController, animated: true, completion: nil)
                } else {
                    print("Tarayıcıda açılamayan bir QR kodu tespit edildi.")
                }
            }
        }
    }
}

