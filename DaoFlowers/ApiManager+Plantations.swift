//
//  ApiManager+Plantations.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/8/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Alamofire

extension ApiManager {
    
    static func fetchCountries(_ completion: @escaping (_ countries: [Country]?, _ error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.CountriesPath
        Alamofire.request(url, method: .get).responseJSON { response in
            if response.result.isSuccess {
                var countries: [Country] = []
                if let json = response.result.value {
                    //print("JSON: \(json)")
                    for dictionary in json as! [[String: AnyObject]] {
                        let country = Country(dictionary: dictionary)
                        countries.append(country)
                    }
                }
                
                completion(countries, nil)
            } else {
                print("Error: \(response.result.error)")
                completion(nil, response.result.error as NSError?)
            }
        }
    }
    
    static func fetchPlantationsByCountry(_ country: Country, completion: @escaping (_ plantations: [Plantation]?, _ error: NSError?) -> ()) {
        let parameters: [String: AnyObject] = [
            "country_id": country.id as AnyObject
        ]
        let url = K.Api.BaseUrl + K.Api.PlantationsPath
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                var plantations: [Plantation] = []
                if let json = response.result.value {
                    print("\(#function) JSON: \(json)")
                    for dictionary in json as! [[String: AnyObject]] {
                        let plantation = Plantation(dictionary: dictionary)
                        plantations.append(plantation)
                    }
                }
                
                completion(plantations, nil)
            } else {
                print("Error: \(response.result.error)")
                completion(nil, response.result.error as NSError?)
            }
        }
    }
    
    static func fetchPlantationsGrowersByVariety(_ variety: Variety, user: User, completion: @escaping (_ plantations: [Plantation]?, _ error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.PlantationsGrowersPath + "/\(variety.id)"
        Alamofire.request(url, method: .get, headers:["Authorization": user.token]).responseJSON { response in
            if response.result.isSuccess {
                var plantations: [Plantation] = []
                if let json = response.result.value {
                    //print("JSON: \(json)")
                    for dictionary in json as! [[String: AnyObject]] {
                        let plantation = Plantation(dictionary: dictionary)
                        plantations.append(plantation)
                    }
                }
                completion(plantations, nil)
            } else {
                print("Error: \(response.result.error)")
                completion(nil, response.result.error as NSError?)
            }
        }
    }
    
    static func fetchPlantationsSearchParameters(_ completion: @escaping (_ searchParams: ([Country], [Flower])?, _ error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.PlantationsSearchParametersPath
        Alamofire.request(url, method: .get).responseJSON { response in
            if response.result.isSuccess {
                var contries: [Country] = []
                var flowers: [Flower] = []
                if let json = response.result.value as? [String: AnyObject] {
                    //print("JSON: \(json)")
                    for countryDictionary in json["countries"] as! [[String: AnyObject]] {
                        contries.append(Country(dictionary: countryDictionary))
                    }
                    for flowerDictionary in json["flowerTypes"] as! [[String: AnyObject]] {
                        flowers.append(Flower(dictionary: flowerDictionary))
                    }
                }
                completion((contries, flowers), nil)
            } else {
                print("Error: \(response.result.error)")
                completion(nil, response.result.error as NSError?)
            }
        }
    }
    
    static func searchPlantationsByTerm(_ term: String, countries: [Country]?, flowers: [Flower]?, completion: @escaping (_ plantations: [Plantation]?, _ error: NSError?) -> ()) {
        var parameters: [String: AnyObject] = [
            "name": term as AnyObject
        ]
        
        if let countries = countries {
            if countries.count > 0 {
                var countryIds: [String] = []
                for country in countries {
                    countryIds.append(String(country.id))
                }
                parameters["country_ids"] = countryIds.joined(separator: ",") as AnyObject?
            }
        }
        
        if let flowers = flowers {
            if flowers.count > 0 {
                var flowerIds: [String] = []
                for flower in flowers {
                    flowerIds.append(String(flower.id))
                }
                parameters["flower_type_ids"] = flowerIds.joined(separator: ",") as AnyObject?
            }
        }
              
        let url = K.Api.BaseUrl + K.Api.SearchPlantationsPath
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                var plantations: [Plantation] = []
                if let json = response.result.value {
                    //print("JSON: \(json)")
                    for dictionary in json as! [[String: AnyObject]] {
                        let plantation = Plantation(dictionary: dictionary)
                        plantations.append(plantation)
                    }
                }
                plantations = Utils.sortedPlantationsByActivePlantations(plantations)
                completion(plantations, nil)
            } else {
                print("Error: \(response.result.error)")
                completion(nil, response.result.error as NSError?)
            }
        }
    }
    
    static func fetchPlantationDetails(_ plantation: Plantation,
                                       user: User?,
                                       completion: @escaping (_ plantationDetails: Plantation?, _ error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.PlantationsPath + "/\(plantation.id)"
        var headers: [String: String] = [:]
        if let user = user {
           headers["Authorization"] = user.token
        }
        Alamofire.request(url, method: .get, headers:headers).responseJSON { response in
            if response.result.isSuccess {
                var plantationDetails = plantation
                if let json = response.result.value as? [String: AnyObject] {
                    print("JSON: \(json)")
                    plantationDetails.countryName = json["countryName"] as? String
                    var varieties: [Variety] = []
                    if let fsorts = json["fsorts"] as? [[String: AnyObject]] {
                        for dictionary in fsorts {
                            let variety = Variety(dictionary: dictionary)
                            varieties.append(variety)
                        }
                    }

                    plantationDetails.varieties = varieties
                }
                
                completion(plantationDetails, nil)
            } else {
                print("Error: \(response.result.error)")
                completion(nil, response.result.error as NSError?)
            }
        }
    }
}
