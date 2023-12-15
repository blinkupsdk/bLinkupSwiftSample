//
//  VenueMapShareVC.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 25.10.2023.
//

import bLinkup
import SwiftUI
import UIKit

struct VenueMapShareView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var point: BlinkPoint
    
    func makeUIViewController(context: Context) -> VenueMapShareVC {
        return VenueMapShareVC.instantiate(point)
    }

    func updateUIViewController(_ vc: VenueMapShareVC, context: Context) {}
}

class VenueMapShareVC: UIViewController {
    
    var point: BlinkPoint!
    
    @IBOutlet var container: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var inviteLabel: UILabel!

    static func instantiate(_ point: BlinkPoint) -> VenueMapShareVC {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: VenueMapShareVC.self))
        let vc = storyboard.instantiateViewController(withIdentifier: "VenueMapShareVC") as! VenueMapShareVC
        vc.point = point
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        container.layer.masksToBounds = true
        container.layer.cornerRadius = 10
        
        inviteLabel.text = inviteMessage()
        
        if let link = point.promoURL,
           let url = URL(string: link)
        {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data)
                {
                    DispatchQueue.main.async { [weak self] in
                        self?.imageView.image = image
                    }
                }
            }
        }
    }
    
    @IBAction func didTapCancel(_ sender: Any?) {
        dismiss(animated: true)
    }

    @IBAction func didTapInvite(_ sender: Any?) {
        share(point)
    }
    
    func inviteMessage() -> String {
        "Hey, I see you're here too! Want to get together at the \(point.name) meetup spot?"
    }
    
    func share(_ point: BlinkPoint) {
        var items: [Any] = [inviteMessage()]
//        if let link = point.promoURL, let url = URL(string: link) {
//            items.insert(url, at: 0)
//        }

        let controller = UIActivityViewController(activityItems:items, applicationActivities: nil)
        controller.popoverPresentationController?.sourceView = self.view
        present(controller, animated: true, completion: nil)
    }
}
