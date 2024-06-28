import GoogleMobileAds
import UIKit

class AdManager: NSObject, GADBannerViewDelegate {
    static let shared = AdManager()
    var bannerView: GADBannerView!
    var adTimer: Timer?
    var bannerContainerView: UIView!
    
    var interstitial: GADInterstitialAd?

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
    
    func loadInterstitialAd(adUnitID: String) {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: adUnitID, request: request, completionHandler: { [weak self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            self?.interstitial = ad
            self?.interstitial?.fullScreenContentDelegate = self as? any GADFullScreenContentDelegate
        })
    }

    func showInterstitialAd(from viewController: UIViewController) {
        if let interstitial = interstitial {
            interstitial.present(fromRootViewController: viewController)
        } else {
            print("Interstitial ad wasn't ready")
            loadInterstitialAd(adUnitID: Ads.interstitialAdUnitID)
        }
    }

    // GADFullScreenContentDelegate methods
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        loadInterstitialAd(adUnitID: Ads.interstitialAdUnitID)
    }
}


