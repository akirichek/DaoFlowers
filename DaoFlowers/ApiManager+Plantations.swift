//
//  ApiManager+Plantations.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/8/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Alamofire

extension ApiManager {
    
    static func fetchCountries(completion: (countries: [Country]?, error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.CountriesPath
        Alamofire.request(.GET, url).responseJSON { response in
            if response.result.isSuccess {
                var countries: [Country] = []
                if let json = response.result.value {
                    //print("JSON: \(json)")
                    for dictionary in json as! [[String: AnyObject]] {
                        let country = Country(dictionary: dictionary)
                        countries.append(country)
                    }
                }
                
                completion(countries: countries, error: nil)
            } else {
                print("Error: \(response.result.error)")
                completion(countries: nil, error: response.result.error)
            }
        }
    }
    
    static func fetchPlantationsByCountry(country: Country, completion: (plantations: [Plantation]?, error: NSError?) -> ()) {
        let parameters: [String: AnyObject] = [
            "country_id": country.id
        ]
        let url = K.Api.BaseUrl + K.Api.PlantationsPath
        Alamofire.request(.GET, url, parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                var plantations: [Plantation] = []
                if let json = response.result.value {
                   print("JSON: \(json)")
                    for dictionary in json as! [[String: AnyObject]] {
                        let plantation = Plantation(dictionary: dictionary)
                        plantations.append(plantation)
                    }
                }
                
                completion(plantations: plantations, error: nil)
            } else {
                print("Error: \(response.result.error)")
                completion(plantations: nil, error: response.result.error)
            }
        }
    }
    
    static func fetchPlantationsGrowersByVariety(variety: Variety, user: User, completion: (plantations: [Plantation]?, error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.PlantationsGrowersPath + "/\(variety.id)"
        Alamofire.request(.GET, url, headers:["Authorization": user.token]).responseJSON { response in
            if response.result.isSuccess {
                var plantations: [Plantation] = []
                if let json = response.result.value {
                    //print("JSON: \(json)")
                    for dictionary in json as! [[String: AnyObject]] {
                        let plantation = Plantation(dictionary: dictionary)
                        plantations.append(plantation)
                    }
                }
                completion(plantations: plantations, error: nil)
            } else {
                print("Error: \(response.result.error)")
                completion(plantations: nil, error: response.result.error)
            }
        }
    }
    
    static func fetchPlantationsSearchParameters(completion: (searchParams: ([Country], [Flower])?, error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.PlantationsSearchParametersPath
        Alamofire.request(.GET, url).responseJSON { response in
            if response.result.isSuccess {
                var contries: [Country] = []
                var flowers: [Flower] = []
                if let json = response.result.value {
                    //print("JSON: \(json)")
                    for countryDictionary in json["countries"] as! [[String: AnyObject]] {
                        contries.append(Country(dictionary: countryDictionary))
                    }
                    for flowerDictionary in json["flowerTypes"] as! [[String: AnyObject]] {
                        flowers.append(Flower(dictionary: flowerDictionary))
                    }
                }
                completion(searchParams: (contries, flowers), error: nil)
            } else {
                print("Error: \(response.result.error)")
                completion(searchParams: nil, error: response.result.error)
            }
        }
    }
    
    static func searchPlantationsByTerm(term: String, countries: [Country]?, flowers: [Flower]?, completion: (plantations: [Plantation]?, error: NSError?) -> ()) {
        var parameters: [String: AnyObject] = [
            "name": term
        ]
        
        if let countries = countries {
            if countries.count > 0 {
                var countryIds: [String] = []
                for country in countries {
                    countryIds.append(String(country.id))
                }
                parameters["country_ids"] = countryIds.joinWithSeparator(",")
            }
        }
        
        if let flowers = flowers {
            if flowers.count > 0 {
                var flowerIds: [String] = []
                for flower in flowers {
                    flowerIds.append(String(flower.id))
                }
                parameters["flower_type_ids"] = flowerIds.joinWithSeparator(",")
            }
        }
              
        let url = K.Api.BaseUrl + K.Api.SearchPlantationsPath
        Alamofire.request(.GET, url, parameters: parameters).responseJSON { response in
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
                completion(plantations: plantations, error: nil)
            } else {
                print("Error: \(response.result.error)")
                completion(plantations: nil, error: response.result.error)
            }
        }
    }
}