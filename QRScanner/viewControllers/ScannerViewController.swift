import UIKit
import AVFoundation
import Contacts
import NetworkExtension
import GoogleMobileAds

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var bannerView: GADBannerView!

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

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        // AVCaptureMetadataOutput oluştur
        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
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
        
        let viewWidth = view.frame.inset(by: view.safeAreaInsets).width

        // Here the current interface orientation is used. Use
        // GADLandscapeAnchoredAdaptiveBannerAdSizeWithWidth or
        // GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth if you prefer to load an ad of a
        // particular orientation,
        let adaptiveSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        bannerView = GADBannerView(adSize: adaptiveSize)
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)

        bannerView.adUnitID = Ads.bannerAdUnitID
        bannerView.rootViewController = self

        bannerView.load(GADRequest())
        
        Ads.addBannerViewToView(bannerView, viewController: self)
    }

    func failed() {
        let ac = UIAlertController(title: "Hata", message: "QR kod okuyucu başlatılamadı", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if captureSession?.isRunning == false {
            captureSession.startRunning()
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
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                        
            // QR kodun içeriğini kontrol edip uygun işlemi gerçekleştirelim
            handleQRCodeContent(stringValue)
        }
    }

    func handleQRCodeContent(_ content: String) {
        // QR kod içeriğini analiz edip uygun işlemi gerçekleştir
        if let url = URL(string: content), UIApplication.shared.canOpenURL(url) {
            // İçerik bir URL ise, bu URL'yi aç
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else if content.starts(with: "BEGIN:VCARD") {
            // İçerik bir vCard ise, kullanıcıya kişiler uygulamasında yeni kişi oluşturma seçeneği sun
            saveVCardAndPresentOptions(vCardString: content)
        } else if content.starts(with: "WIFI:"){
            let components = content.components(separatedBy: ";")
            var ssid = ""
            var password = ""
            for component in components {
                if component.hasPrefix("S:") {
                    ssid = String(component.dropFirst(2))
                } else if component.hasPrefix("P:") {
                    password = String(component.dropFirst(2))
                }
            }
            
            showWiFiConnectionPrompt(ssid: ssid, password: password)
        } else {
            // İçerik metin ise, metni TextViewController ile tam ekran göster
            presentTextContent(content: content)
        }
    }

    func presentTextContent(content: String) {
        let textViewController = TextViewController()
        textViewController.text = content
        let navigationController = UINavigationController(rootViewController: textViewController)
        present(navigationController, animated: true, completion: nil)
    }

    func saveVCardAndPresentOptions(vCardString: String) {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("contact.vcf")
        do {
            try vCardString.write(to: tempURL, atomically: true, encoding: .utf8)
            
            let activityViewController = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            activityViewController.excludedActivityTypes = [.addToReadingList, .assignToContact, .saveToCameraRoll]
            present(activityViewController, animated: true, completion: nil)
        } catch {
            let ac = UIAlertController(title: "Hata", message: "vCard kaydedilemedi.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Tamam", style: .default))
            present(ac, animated: true)
        }
    }
    
    func showWiFiConnectionPrompt(ssid: String, password: String) {
        let alertController = UIAlertController(title: "Wi-Fi Bağlantısı", message: "Ağa bağlanmak istiyor musunuz?", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Evet", style: .default) { _ in
            // Wi-Fi ağına bağlanma işlemini gerçekleştir
            self.connectToWiFi(ssid, password: password)
        })
        
        alertController.addAction(UIAlertAction(title: "Hayır", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }

    func connectToWiFi(_ ssid: String, password: String) {
        let hotspotConfig = NEHotspotConfiguration(ssid: ssid, passphrase: password, isWEP: false)
        hotspotConfig.joinOnce = true

        NEHotspotConfigurationManager.shared.apply(hotspotConfig) { error in
            if let error = error {
                print("Wi-Fi bağlanma hatası: \(error.localizedDescription)")
                Alerts.showAlert(title: "Bağlantı Hatası", message: "Wi-Fi ağına bağlanırken hata oluştu: \(error.localizedDescription)", viewController: self)
            } else {
                print("Wi-Fi başarıyla bağlandı: \(ssid)")
                Alerts.showAlert(title: "Bağlantı Başarılı", message: "Wi-Fi ağına başarıyla bağlanıldı: \(ssid)", viewController: self)
            }
        }
    }
}

