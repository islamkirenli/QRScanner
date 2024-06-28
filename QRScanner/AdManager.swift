import GoogleMobileAds
import UIKit

class AdManager: NSObject, GADBannerViewDelegate {
    static let shared = AdManager()
    var bannerView: GADBannerView!
    var adTimer: Timer?
    var bannerContainerView: UIView!

    func setupBannerAd(viewController: UIViewController, adUnitID: String) {
        bannerContainerView = UIView()
        bannerContainerView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(bannerContainerView)
        
        NSLayoutConstraint.activate([
            bannerContainerView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            bannerContainerView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            bannerContainerView.bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor),
            bannerContainerView.heightAnchor.constraint(equalToConstant: 50) // Varsayılan bir yükseklik, banner reklamın yüksekliğine göre ayarlayabilirsiniz
        ])
        
        let viewWidth = viewController.view.frame.inset(by: viewController.view.safeAreaInsets).width
        let adaptiveSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        bannerView = GADBannerView(adSize: adaptiveSize)
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = viewController
        bannerView.delegate = self
        bannerView.load(GADRequest())
        
        bannerContainerView.addSubview(bannerView)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bannerView.leadingAnchor.constraint(equalTo: bannerContainerView.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: bannerContainerView.trailingAnchor),
            bannerView.topAnchor.constraint(equalTo: bannerContainerView.topAnchor),
            bannerView.bottomAnchor.constraint(equalTo: bannerContainerView.bottomAnchor)
        ])
        
        adTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(loadNewAd), userInfo: nil, repeats: true)
    }

    @objc func loadNewAd() {
        bannerView.load(GADRequest())
        print("yeni reklam atıldı.")
    }

    func invalidateTimer() {
        adTimer?.invalidate()
        adTimer = nil
    }
}


