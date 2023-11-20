//
//  VenueMapView2.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 15.11.2023.
//

import bLinkup
import SwiftUI
import UIKit
import Combine

private let icon = UIImage(named: "point") ?? UIImage()


@available(iOS 13.0, *)
public struct VenueMapView2: View {
    let place: Place?
    var aspectRatio: Binding<CGFloat>?
    
    @State var dragOffset: CGSize = CGSize.zero
    @State var selectedPoint: BlinkPoint?
    @State var scale: CGFloat = 1

    @ObservedObject var loader: ImageLoader
    
    @Environment(\.presentationMode) var presentationMode
    
    public init(place: Place?, aspectRatio: Binding<CGFloat>? = nil, disableCache: Bool? = nil, caption: Text? = nil, closeButtonTopRight: Bool? = false) {
        self.place = place
        self.aspectRatio = aspectRatio
        
        loader = ImageLoader(url: .constant(place?.mapURL ?? ""))
    }
    
    @ViewBuilder
    public var body: some View {
        let image: Image = loader.image == nil
        ? Image(systemName: "map")
        : Image(uiImage: loader.image!)
        ZStack {
            ZStack {
                image
                    .resizable()
                    .overlay(content: {
                        GeometryReader { geometry in
                            if let im = loader.image {
                                let imSize = im.size
                                
                                ForEach(place?.blinkpoints ?? [], id: \.id) { point in
                                    Image(uiImage: icon)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 18, height: 24)
                                        .position(x: calcX(point.x, 18, imSize.width, geometry.size.width),
                                                  y: calcY(point.y, 24, imSize.height, geometry.size.height, 0))
                                        .contentShape(.interaction, Rectangle())
                                        .onTapGesture {
                                            selectedPoint = point
                                        }
                                        .background(.yellow)
                                        .frame(width: 18, height: 25)
                                }
                            } else {
                                EmptyView()
                            }
                        }
                    })
                    .aspectRatio(self.aspectRatio?.wrappedValue, contentMode: .fit)
                    .offset(x: self.dragOffset.width, y: self.dragOffset.height)
                    .pinchToZoom(scale: $scale)
                    .gesture(DragGesture()
                        .onChanged { value in
                            self.dragOffset = value.translation
                        }
                        .onEnded({ _ in
                            if scale == 1 {
                                dragOffset = .zero
                            }
                        })
                    )
            }
            .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))

            if selectedPoint != nil {
                VenueMapShareView2(point: $selectedPoint)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(perform: {
            self.dragOffset = .zero
            loader.load()
        })
    }
    
    func calcX(_ x: CGFloat, _ icWidth: CGFloat, _ imWidth: CGFloat, _ width: CGFloat) -> CGFloat {
        (x - icWidth / 2) / imWidth * width
    }
    
    func calcY(_ y: CGFloat, _ icHeight: CGFloat, _ imHeight: CGFloat, _ height: CGFloat, _ yDif: CGFloat) -> CGFloat {
        (y - icHeight) / imHeight * height + yDif
    }
}

class PinchZoomView: UIView {
    
    weak var delegate: PinchZoomViewDelgate?
    
    private(set) var scale: CGFloat = 0 {
        didSet {
            delegate?.pinchZoomView(self, didChangeScale: scale)
        }
    }
    
    private(set) var offset: CGSize = .zero {
        didSet {
            delegate?.pinchZoomView(self, didChangeOffset: offset)
        }
    }
    
    private(set) var isPinching: Bool = false {
        didSet {
            delegate?.pinchZoomView(self, didChangePinching: isPinching)
        }
    }
    
    private var startLocation: CGPoint = .zero
    private var location: CGPoint = .zero
    private var numberOfTouches: Int = 0
    
    init() {
        super.init(frame: .zero)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch(gesture:)))
        pinchGesture.cancelsTouchesInView = false
        addGestureRecognizer(pinchGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc private func pinch(gesture: UIPinchGestureRecognizer) {
        
        switch gesture.state {
        case .began:
            isPinching = true
            startLocation = gesture.location(in: self)
            numberOfTouches = gesture.numberOfTouches
            
        case .changed:
            if gesture.numberOfTouches != numberOfTouches {
                // If the number of fingers being used changes, the start location needs to be adjusted to avoid jumping.
                let newLocation = gesture.location(in: self)
                let jumpDifference = CGSize(width: newLocation.x - location.x, height: newLocation.y - location.y)
                startLocation = CGPoint(x: startLocation.x + jumpDifference.width, y: startLocation.y + jumpDifference.height)
                
                numberOfTouches = gesture.numberOfTouches
            }
            
            scale = gesture.scale
            
            location = gesture.location(in: self)
            offset = CGSize(width: location.x - startLocation.x, height: location.y - startLocation.y)
            
        case .ended, .cancelled, .failed:
            withAnimation(.interactiveSpring()) {
                isPinching = false
                scale = max(1.0, min(2.0, scale))
            }
        default:
            break
        }
    }
    
}

protocol PinchZoomViewDelgate: AnyObject {
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangePinching isPinching: Bool)
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeScale scale: CGFloat)
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeOffset offset: CGSize)
}

struct PinchZoom: UIViewRepresentable {
    
    @Binding var scale: CGFloat
    @Binding var offset: CGSize
    @Binding var isPinching: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> PinchZoomView {
        let pinchZoomView = PinchZoomView()
        pinchZoomView.delegate = context.coordinator
        return pinchZoomView
    }
    
    func updateUIView(_ pageControl: PinchZoomView, context: Context) { }
    
    class Coordinator: NSObject, PinchZoomViewDelgate {
        var pinchZoom: PinchZoom
        
        init(_ pinchZoom: PinchZoom) {
            self.pinchZoom = pinchZoom
        }
        
        func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangePinching isPinching: Bool) {
            pinchZoom.isPinching = isPinching
        }
        
        func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeScale scale: CGFloat) {
            pinchZoom.scale = scale
        }
        
        func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeOffset offset: CGSize) {
            pinchZoom.offset = offset
        }
    }
}

struct PinchToZoom: ViewModifier {
    @Binding var scale: CGFloat
    @State var offset: CGSize = .zero
    @State var isPinching: Bool = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .offset(offset)
            .overlay(PinchZoom(scale: $scale, offset: $offset, isPinching: $isPinching))
    }
}

extension View {
    func pinchToZoom(scale: Binding<CGFloat>) -> some View {
        self.modifier(PinchToZoom(scale: scale))
    }
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private let url: Binding<String>
    private var cancellable: AnyCancellable?
    
    func getURLRequest(url: String) -> URLRequest {
        let url = URL(string: url) ?? URL(string: "https://via.placeholder.com/150.png")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return request;
    }
    
    init(url: Binding<String>) {
        self.url = url
        
        if(url.wrappedValue.count > 0) {
            load()
        }
    }
    
    deinit {
        cancellable?.cancel()
    }
    
    func load() {
        cancellable = URLSession.shared.dataTaskPublisher(for: getURLRequest(url: self.url.wrappedValue))
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: self)
    }
    
    func cancel() {
        cancellable?.cancel()
    }
}

#Preview {
                    VenueMapView2(place: Place(id: "1", name: "sd"))
}
