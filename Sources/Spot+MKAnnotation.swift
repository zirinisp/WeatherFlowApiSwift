//
//  Spot+MKAnnotation.swift
//  WeatherFlowApiSwift
//
//  Created by Pantelis Zirinis on 03/04/2017.
//  Copyright © 2017 Pantelis Zirinis. All rights reserved.
//

import Foundation
import MapKit

public class SpotMKAnnotation: NSObject, MKAnnotation {
    
    var spot: Spot
    
    init(spot: Spot) {
        self.spot = spot
    }
    
    lazy var annotationView: MKAnnotationView = {
        let view: MKAnnotationView = MKAnnotationView(annotation: self, reuseIdentifier: "SpotAnnotation")
        var windImage: UIImage?
        var windText: String? = nil
        if let avg = self.spot.avg {
            if avg == 0.0 {
                windImage = UIImage(named: "mapnowind.png")
            } else {
                let live: Bool = (self.spot.type == 1)
                let color: UIColor = live ? UIColor.gray : UIColor.lightGray
                windImage = WeatherFlowApiSwift.windArrowWithSize(100.0, degrees: Float(self.spot.dir ?? 0), fillColor: color, strokeColor: color, text: "")
                windText = String(format: "%0.0f", avg)
            }
        } else {
            windImage = UIImage(named: "mapnowindinfo.png")
        }
        
        let windImageView: UIImageView = UIImageView(image: windImage)
        windImageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        view.addSubview(windImageView)
        var rect: CGRect = view.frame
        rect.size = windImageView.frame.size
        if let text = windText {
            let label: UILabel = UILabel()
            label.text = text
            label.textColor = UIColor.gray
            label.backgroundColor = UIColor.clear
            label.sizeToFit()
            var labelFrame: CGRect = label.frame
            labelFrame.origin.x = 30
            label.frame = labelFrame
            rect.size.width += labelFrame.size.width
            view.addSubview(label)
        }
        view.frame = rect
        //        view.image = windImage;
        view.canShowCallout = true
        let infoButton: UIButton = UIButton(type: .detailDisclosure)
        view.rightCalloutAccessoryView = infoButton
        return view
    }()
    
    // MARK: MKAnnotation
    public var coordinate: CLLocationCoordinate2D {
        return self.spot.coordinate
    }

}

