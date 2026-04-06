import Foundation
import HealthKit

enum WorkoutTypeMapping {
    static func name(for type: HKWorkoutActivityType) -> String {
        switch type {
        case .americanFootball: "Football américain"
        case .archery: "Tir à l'arc"
        case .australianFootball: "Football australien"
        case .badminton: "Badminton"
        case .baseball: "Baseball"
        case .basketball: "Basketball"
        case .bowling: "Bowling"
        case .boxing: "Boxe"
        case .climbing: "Escalade"
        case .cricket: "Cricket"
        case .crossTraining: "Cross-training"
        case .curling: "Curling"
        case .cycling: "Vélo"
        case .dance: "Danse"
        case .elliptical: "Elliptique"
        case .equestrianSports: "Équitation"
        case .fencing: "Escrime"
        case .fishing: "Pêche"
        case .functionalStrengthTraining: "Renforcement fonctionnel"
        case .golf: "Golf"
        case .gymnastics: "Gymnastique"
        case .handball: "Handball"
        case .hiking: "Randonnée"
        case .hockey: "Hockey"
        case .hunting: "Chasse"
        case .lacrosse: "Lacrosse"
        case .martialArts: "Arts martiaux"
        case .mindAndBody: "Corps et esprit"
        case .mixedCardio: "Cardio mixte"
        case .paddleSports: "Pagaie"
        case .play: "Jeu"
        case .preparationAndRecovery: "Préparation et récupération"
        case .racquetball: "Racquetball"
        case .rowing: "Aviron"
        case .rugby: "Rugby"
        case .running: "Course à pied"
        case .sailing: "Voile"
        case .skatingSports: "Patinage"
        case .snowSports: "Sports de neige"
        case .soccer: "Football"
        case .softball: "Softball"
        case .squash: "Squash"
        case .stairClimbing: "Montée d'escaliers"
        case .surfingSports: "Surf"
        case .swimming: "Natation"
        case .tableTennis: "Tennis de table"
        case .tennis: "Tennis"
        case .trackAndField: "Athlétisme"
        case .traditionalStrengthTraining: "Musculation"
        case .volleyball: "Volleyball"
        case .walking: "Marche"
        case .waterFitness: "Aquagym"
        case .waterPolo: "Water-polo"
        case .waterSports: "Sports nautiques"
        case .wrestling: "Lutte"
        case .yoga: "Yoga"
        case .barre: "Barre"
        case .coreTraining: "Gainage"
        case .crossCountrySkiing: "Ski de fond"
        case .downhillSkiing: "Ski alpin"
        case .flexibility: "Souplesse"
        case .highIntensityIntervalTraining: "HIIT"
        case .jumpRope: "Corde à sauter"
        case .kickboxing: "Kickboxing"
        case .pilates: "Pilates"
        case .snowboarding: "Snowboard"
        case .stairs: "Escaliers"
        case .stepTraining: "Step"
        case .wheelchairWalkPace: "Fauteuil roulant (marche)"
        case .wheelchairRunPace: "Fauteuil roulant (course)"
        case .taiChi: "Tai chi"
        case .mixedMetabolicCardioTraining: "Cardio métabolique"
        case .pickleball: "Pickleball"
        case .cooldown: "Récupération"
        case .swimBikeRun: "Triathlon"
        case .transition: "Transition"
        case .underwaterDiving: "Plongée"
        case .other: "Autre"
        @unknown default: "Inconnu"
        }
    }

    static func sfSymbol(for type: HKWorkoutActivityType) -> String {
        switch type {
        case .running: "figure.run"
        case .cycling: "figure.outdoor.cycle"
        case .swimming: "figure.pool.swim"
        case .walking: "figure.walk"
        case .hiking: "figure.hiking"
        case .yoga: "figure.yoga"
        case .dance: "figure.dance"
        case .functionalStrengthTraining, .traditionalStrengthTraining: "figure.strengthtraining.traditional"
        case .highIntensityIntervalTraining: "figure.highintensity.intervaltraining"
        case .coreTraining: "figure.core.training"
        case .climbing: "figure.climbing"
        case .rowing: "figure.rowing"
        case .elliptical: "figure.elliptical"
        case .stairClimbing, .stairs: "figure.stair.stepper"
        case .pilates: "figure.pilates"
        case .crossTraining, .mixedCardio: "figure.cross.training"
        case .soccer: "sportscourt"
        case .basketball: "basketball"
        case .tennis, .tableTennis: "tennis.racket"
        case .badminton: "figure.badminton"
        case .baseball, .softball: "baseball"
        case .golf: "figure.golf"
        case .crossCountrySkiing, .downhillSkiing: "figure.skiing.downhill"
        case .snowboarding: "figure.snowboarding"
        case .surfingSports: "figure.surfing"
        case .skatingSports: "figure.skating"
        case .jumpRope: "figure.jumprope"
        case .boxing, .kickboxing, .martialArts: "figure.boxing"
        case .rugby, .americanFootball, .australianFootball: "football"
        case .handball: "figure.handball"
        case .volleyball: "volleyball"
        case .hockey: "hockey.puck"
        case .sailing: "sailboat"
        case .paddleSports: "canoe"
        case .waterFitness, .waterSports: "drop"
        case .mindAndBody, .flexibility, .taiChi: "figure.mind.and.body"
        case .preparationAndRecovery, .cooldown: "heart.circle"
        case .swimBikeRun: "figure.run.treadmill"
        case .underwaterDiving: "water.waves"
        case .wheelchairWalkPace, .wheelchairRunPace: "figure.roll"
        default: "figure.mixed.cardio"
        }
    }

    static func tcxSport(for type: HKWorkoutActivityType) -> String {
        switch type {
        case .running, .walking, .hiking: "Running"
        case .cycling: "Biking"
        default: "Other"
        }
    }

    static func fitSport(for type: HKWorkoutActivityType) -> (sport: UInt8, subSport: UInt8) {
        switch type {
        case .running: (1, 0)        // Running / Generic
        case .cycling: (2, 0)        // Cycling / Generic
        case .swimming: (5, 0)       // Swimming / Generic
        case .walking: (11, 0)       // Walking / Generic
        case .hiking: (17, 0)        // Hiking / Generic
        case .rowing: (15, 0)        // Rowing / Generic
        case .yoga: (43, 0)          // Yoga / Generic
        case .crossTraining, .highIntensityIntervalTraining: (10, 0) // Training / Generic
        case .traditionalStrengthTraining, .functionalStrengthTraining: (10, 0)
        case .elliptical: (4, 0)     // Fitness Equipment / Generic
        case .downhillSkiing: (13, 0)  // Alpine Skiing
        case .crossCountrySkiing: (12, 0) // Cross Country Skiing
        case .snowboarding: (14, 0)  // Snowboarding
        case .surfingSports: (38, 0) // Surfing
        case .golf: (25, 0)          // Golf
        case .soccer: (7, 0)         // Soccer
        case .tennis: (8, 0)         // Tennis
        case .basketball: (6, 0)     // Basketball
        default: (0, 0)              // Generic
        }
    }
}
