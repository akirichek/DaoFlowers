//
//  DataManager.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 5/1/17.
//  Copyright © 2017 Dao Flowers. All rights reserved.
//

import UIKit
import CoreData

class DataManager: NSObject {

    static func saveClaim(_ claim: Claim) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let entity = NSEntityDescription.entity(forEntityName: "LocalClaim", in: context)
        var object: NSManagedObject!
        if let objectID = claim.objectID {
            object = try! context.existingObject(with: objectID)
        } else {
            object = NSEntityDescription.insertNewObject(forEntityName: (entity?.name)!, into: context)
        }
        object.setValue(User.currentUser()!.id!, forKey: "userId")
        object.setValue(claim.comment, forKey: "comment")
        object.setValue(claim.client.id, forKey: "clientId")
        object.setValue(claim.client.name, forKey: "clientName")
        object.setValue(claim.invoiceId, forKey: "invoiceId")
        object.setValue(claim.invoiceHeadId, forKey: "invoiceHeadId")
        object.setValue(claim.subjectId!, forKey: "subjectId")
        object.setValue(claim.date, forKey: "date")
        object.setValue(photosDataFromClaim(claim), forKey: "photos")
        
        var claimInvoceRowEntities = Set<NSManagedObject>()
        for claimInvoiceRow in claim.invoiceRows {
            claimInvoceRowEntities.insert(claimInvoceRowEntity(claimInvoiceRow))
        }
        object.setValue(claimInvoceRowEntities, forKey: "claimInvoiceRows")
        object.setValue(plantationEntity(claim.plantation!), forKey: "plantation")
        
        appDelegate.saveContext()
    }
    
    static func fetchClaims() -> [Claim] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: "LocalClaim", in: context)
        request.entity = entity
        let predicate = NSPredicate(format: "userId CONTAINS[cd] %d", User.currentUser()!.id!)
        request.predicate = predicate
        let objects = try! context.fetch(request) as! [NSManagedObject]
        var claims: [Claim] = []
        for object in objects {
            let client = User(id: object.value(forKey: "clientId") as! Int,
                              name: object.value(forKey: "clientName") as! String)
            var claim = Claim(client: client,
                              date: object.value(forKey: "date") as! Date,
                              invoiceId: object.value(forKey: "invoiceId") as! Int,
                              invoiceHeadId: object.value(forKey: "invoiceHeadId") as! Int)
            claim.comment = object.value(forKey: "comment") as! String
            claim.subjectId = object.value(forKey: "subjectId") as? Int
            claim.invoiceRows = claimInvoiceRows(object.value(forKey: "claimInvoiceRows") as! Set<NSManagedObject>)
            claim.sum = claim.calculateSum()
            claim.stems = claim.stemsCount()
            claim.status = .LocalDraft
            claim.plantation = plantation(object.value(forKey: "plantation") as! NSManagedObject)
            claim.photos = photosFromObject(object)
            claim.objectID = object.objectID
            claims.append(claim)
        }
        
        return claims
    }
    
    static func removeClaim(_ claim: Claim) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        context.delete(try! context.existingObject(with: claim.objectID!))
        appDelegate.saveContext()
    }
    
    static func claimInvoceRowEntity(_ claimInvoceRow: Claim.InvoiceRow) -> NSManagedObject {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let entity = NSEntityDescription.entity(forEntityName: "ClaimInvoiceRow", in: context)
        let object = NSEntityDescription.insertNewObject(forEntityName: (entity?.name)!, into: context)
        object.setValue(claimInvoceRow.rowId, forKey: "rowId")
        object.setValue(claimInvoceRow.claimStems, forKey: "claimStems")
        object.setValue(claimInvoceRow.claimPerStemPrice, forKey: "claimPerStemPrice")
        return object
    }
    
    static func claimInvoiceRows(_ objects: Set<NSManagedObject>) -> [Claim.InvoiceRow] {
        var claimInvoiceRows: [Claim.InvoiceRow] = []
        for object in objects {
            let claimInvoiceRow = Claim.InvoiceRow(rowId: object.value(forKey: "rowId") as! Int,
                                                   claimPerStemPrice: object.value(forKey: "claimPerStemPrice") as? Double,
                                                   claimStems: object.value(forKey: "claimStems") as? Int)
            claimInvoiceRows.append(claimInvoiceRow)
        }
        
        return claimInvoiceRows
    }
    
    static func plantationEntity(_ plantation: Plantation) -> NSManagedObject {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let entity = NSEntityDescription.entity(forEntityName: "LocalPlantation", in: context)
        let object = NSEntityDescription.insertNewObject(forEntityName: (entity?.name)!, into: context)
        object.setValue(plantation.id, forKey: "id")
        object.setValue(plantation.brand, forKey: "brand")
        object.setValue(plantation.name, forKey: "name")
        return object
    }
    
    static func plantation(_ object: NSManagedObject) -> Plantation {
        let plantation = Plantation(id: object.value(forKey: "id") as! Int,
                                    brand: object.value(forKey: "brand") as! String,
                                    name: object.value(forKey: "name") as! String)
        return plantation
    }
    
    static func photosDataFromClaim(_ claim: Claim) -> Data {
        var photosData: [Data] = []
        for photo in claim.photos {
            let photoData = UIImagePNGRepresentation(photo.image!)!
            photosData.append(photoData)
        }
        return NSKeyedArchiver.archivedData(withRootObject: photosData)
    }
    
    static func photosFromObject(_ object: NSManagedObject) -> [Photo] {
        var photos: [Photo] = []
        let photosData = NSKeyedUnarchiver.unarchiveObject(with: object.value(forKey: "photos") as! Data) as! [Data]
        for photoData in photosData {
            let imageName = UUID().uuidString + ".jpg"
            let photo = Photo(image: UIImage(data: photoData)!, name: imageName)
            photos.append(photo)
        }
        return photos
    }
}
