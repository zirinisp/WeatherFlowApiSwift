//
//  PazMapView.swift
//  PazHelperSwift
//
//  Created by Pantelis Zirinis on 18/05/2015.
//  Copyright (c) 2015 paz-labs. All rights reserved.
//

import Foundation
import MapKit

public extension MKMapView {
    public var southWestCoordinates : CLLocationCoordinate2D {
        if !self.frame.isEmpty {
            let mapCoordinate = self.convert(CGPoint(x: 0.0, y: self.frame.height), toCoordinateFrom: self)
            return mapCoordinate
        }
        return kCLLocationCoordinate2DInvalid
    }
    
    public var northEastCoordinates : CLLocationCoordinate2D {
        if !self.frame.isEmpty {
            let mapCoordinate = self.convert(CGPoint(x: self.frame.width, y: 0.0), toCoordinateFrom: self)
            return mapCoordinate
        }
        return kCLLocationCoordinate2DInvalid
    }
    public static func RectForCoordinateRegion(region: MKCoordinateRegion) -> MKMapRect {
        let a = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
            region.center.latitude + region.span.latitudeDelta / 2,
            region.center.longitude - region.span.longitudeDelta / 2));
        let b = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
            region.center.latitude - region.span.latitudeDelta / 2,
            region.center.longitude + region.span.longitudeDelta / 2));
        return MKMapRectMake(MIN(a.x, b.x), MIN(a.y, b.y), abs(a.x-b.x), abs(a.y-b.y));
    }
}

