//
//  VenueMapVC.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 13.10.2023.
//

import bLinkup
import SwiftUI
import UIKit

struct VenueMapView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    let place: Place?
    
    func makeUIViewController(context: Context) -> VenueMapVC {
        return VenueMapVC.instantiate(place)
    }

    func updateUIViewController(_ vc: VenueMapVC, context: Context) {}
}

class VenueMapVC: UIViewController, UIScrollViewDelegate {
    var places: [Place]?
    var place: Place?
    
    @IBOutlet var scrollView: UIScrollView?
    @IBOutlet var imageView: UIImageView!
    var container: UIView!
    
    static func instantiate(_ place: Place?) -> VenueMapVC {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: VenueMapVC.self))
        let vc = storyboard.instantiateViewController(withIdentifier: "VenueMapVC") as! VenueMapVC
        vc.place = place
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView?.decelerationRate = .fast
        scrollView?.minimumZoomScale = 1
        scrollView?.maximumZoomScale = 5
        scrollView?.delegate = self
        scrollView?.scrollsToTop = false
        
        let c = UIView()
        c.frame = imageView.bounds
        imageView.addSubview(c)
        self.container = c
        
        if place != nil {
            loadMap()
        } else if places != nil {
            choosePlace()
        } else {
            loadPlaces()
        }
    }
    
    func loadPlaces() {
        bLinkup.getEvents(completion: { [weak self] in
            switch $0 {
            case .failure(let error):
                self?.showError(error)
            case .success(let list):
                self?.places = list
                self?.choosePlace()
            }
        })
    }
    
    func choosePlace() {
        let menu = UIAlertController()

        for p in places ?? [] {
            menu.addAction(.init(title: p.name, style: .default, handler: { _ in
                self.place = p
                self.loadMap()
            }))
        }

        menu.addAction(.init(title: "cancel", style: .cancel))
                       
        present(menu, animated: true)
    }
    
    func loadMap() {
        guard let link = place?.mapURL,
              let url = URL(string: link)
        else { return }
        
        let req = URLRequest(url: url)
        URLSession.shared.dataTask(with: req) { [weak self] data, response, error in
            guard let data,
                  let image = UIImage(data: data)
            else { return }
            
            DispatchQueue.main.async { [weak self] in
                self?.imageView?.image = image
                self?.updateBlinkPoints()
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                    self?.updateBlinkPoints()
                })
            }
        }.resume()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func updateBlinkPoints() {
        guard let container = self.container,
              let rect = imageView?.contentRect,
              let iSize = imageView?.image?.size
        else { return }
        
        container.subviews.forEach({ $0.removeFromSuperview() })
        imageView?.isUserInteractionEnabled = true
            
        let icon = UIImage(systemName: "mappin.and.ellipse")?
            .applyingSymbolConfiguration(.init(pointSize: 25)) ?? UIImage()

        print("++++")
        print("rect:", rect)
        print("image size:", iSize)
        print("icon size:", icon.size)

        place?.blinkpoints?.prefix(1).enumerated().forEach({
            let mark = UIImageView(image: icon)
            
            let x = ($0.element.x - icon.size.width / 2) / iSize.width * rect.width
            let y = ($0.element.y - icon.size.height) / iSize.height * rect.height + rect.origin.y
            mark.accessibilityIdentifier = "\($0.offset + 1000)"
            let tap = UITapGestureRecognizer(target: self, action: #selector(pinTap(_:)))
            mark.addGestureRecognizer(tap)
            mark.isUserInteractionEnabled = true
            
            container.addSubview(mark)
            mark.center = CGPoint(x: x, y: y)
            
            print("(\($0.element.x), \($0.element.y)) -> (\(x), \(y)")
        })
    }
    
    @IBAction func pinTap(_ sender: Any?) {
        guard let view = (sender as? UITapGestureRecognizer)?.view ?? (sender as? UIImageView),
              let id = view.accessibilityIdentifier,
              let i = Int(id)
        else { return }
        let index = i - 1000
        guard let point = place?.blinkpoints?[index] else { return }
        
        showSharingPopup(point)
    }
    
    func showSharingPopup(_ point: BlinkPoint) {
        let vc = VenueMapShareVC.instantiate(point)
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true)
    }
}

private extension UIImageView {
    var contentRect: CGRect {
        guard let image = image else { return bounds }
        guard contentMode == .scaleAspectFit else { return bounds }
        guard image.size.width > 0 && image.size.height > 0 else { return bounds }

        let scale: CGFloat
        if image.size.width > image.size.height {
            scale = bounds.width / image.size.width
        } else {
            scale = bounds.height / image.size.height
        }

        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let x = (bounds.width - size.width) / 2.0
        let y = (bounds.height - size.height) / 2.0

        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
}
