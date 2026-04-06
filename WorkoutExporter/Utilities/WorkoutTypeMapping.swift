import Foundation
import HealthKit

enum WorkoutTypeMapping {
    static func name(for type: HKWorkoutActivityType) -> String {
        switch type {
        case .americanFootball: String(localized: "workout.americanFootball")
        case .archery: String(localized: "workout.archery")
        case .australianFootball: String(localized: "workout.australianFootball")
        case .badminton: String(localized: "workout.badminton")
        case .baseball: String(localized: "workout.baseball")
        case .basketball: String(localized: "workout.basketball")
        case .bowling: String(localized: "workout.bowling")
        case .boxing: String(localized: "workout.boxing")
        case .climbing: String(localized: "workout.climbing")
        case .cricket: String(localized: "workout.cricket")
        case .crossTraining: String(localized: "workout.crossTraining")
        case .curling: String(localized: "workout.curling")
        case .cycling: String(localized: "workout.cycling")
        case .dance: String(localized: "workout.dance")
        case .elliptical: String(localized: "workout.elliptical")
        case .equestrianSports: String(localized: "workout.equestrianSports")
        case .fencing: String(localized: "workout.fencing")
        case .fishing: String(localized: "workout.fishing")
        case .functionalStrengthTraining: String(localized: "workout.functionalStrengthTraining")
        case .golf: String(localized: "workout.golf")
        case .gymnastics: String(localized: "workout.gymnastics")
        case .handball: String(localized: "workout.handball")
        case .hiking: String(localized: "workout.hiking")
        case .hockey: String(localized: "workout.hockey")
        case .hunting: String(localized: "workout.hunting")
        case .lacrosse: String(localized: "workout.lacrosse")
        case .martialArts: String(localized: "workout.martialArts")
        case .mindAndBody: String(localized: "workout.mindAndBody")
        case .mixedCardio: String(localized: "workout.mixedCardio")
        case .paddleSports: String(localized: "workout.paddleSports")
        case .play: String(localized: "workout.play")
        case .preparationAndRecovery: String(localized: "workout.preparationAndRecovery")
        case .racquetball: String(localized: "workout.racquetball")
        case .rowing: String(localized: "workout.rowing")
        case .rugby: String(localized: "workout.rugby")
        case .running: String(localized: "workout.running")
        case .sailing: String(localized: "workout.sailing")
        case .skatingSports: String(localized: "workout.skatingSports")
        case .snowSports: String(localized: "workout.snowSports")
        case .soccer: String(localized: "workout.soccer")
        case .softball: String(localized: "workout.softball")
        case .squash: String(localized: "workout.squash")
        case .stairClimbing: String(localized: "workout.stairClimbing")
        case .surfingSports: String(localized: "workout.surfingSports")
        case .swimming: String(localized: "workout.swimming")
        case .tableTennis: String(localized: "workout.tableTennis")
        case .tennis: String(localized: "workout.tennis")
        case .trackAndField: String(localized: "workout.trackAndField")
        case .traditionalStrengthTraining: String(localized: "workout.traditionalStrengthTraining")
        case .volleyball: String(localized: "workout.volleyball")
        case .walking: String(localized: "workout.walking")
        case .waterFitness: String(localized: "workout.waterFitness")
        case .waterPolo: String(localized: "workout.waterPolo")
        case .waterSports: String(localized: "workout.waterSports")
        case .wrestling: String(localized: "workout.wrestling")
        case .yoga: String(localized: "workout.yoga")
        case .barre: String(localized: "workout.barre")
        case .coreTraining: String(localized: "workout.coreTraining")
        case .crossCountrySkiing: String(localized: "workout.crossCountrySkiing")
        case .downhillSkiing: String(localized: "workout.downhillSkiing")
        case .flexibility: String(localized: "workout.flexibility")
        case .highIntensityIntervalTraining: String(localized: "workout.hiit")
        case .jumpRope: String(localized: "workout.jumpRope")
        case .kickboxing: String(localized: "workout.kickboxing")
        case .pilates: String(localized: "workout.pilates")
        case .snowboarding: String(localized: "workout.snowboarding")
        case .stairs: String(localized: "workout.stairs")
        case .stepTraining: String(localized: "workout.stepTraining")
        case .wheelchairWalkPace: String(localized: "workout.wheelchairWalkPace")
        case .wheelchairRunPace: String(localized: "workout.wheelchairRunPace")
        case .taiChi: String(localized: "workout.taiChi")
        case .mixedMetabolicCardioTraining: String(localized: "workout.mixedMetabolicCardio")
        case .pickleball: String(localized: "workout.pickleball")
        case .cooldown: String(localized: "workout.cooldown")
        case .swimBikeRun: String(localized: "workout.swimBikeRun")
        case .transition: String(localized: "workout.transition")
        case .underwaterDiving: String(localized: "workout.underwaterDiving")
        case .other: String(localized: "workout.other")
        @unknown default: String(localized: "workout.unknown")
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
        case .running: (1, 0)
        case .cycling: (2, 0)
        case .swimming: (5, 0)
        case .walking: (11, 0)
        case .hiking: (17, 0)
        case .rowing: (15, 0)
        case .yoga: (43, 0)
        case .crossTraining, .highIntensityIntervalTraining: (10, 0)
        case .traditionalStrengthTraining, .functionalStrengthTraining: (10, 0)
        case .elliptical: (4, 0)
        case .downhillSkiing: (13, 0)
        case .crossCountrySkiing: (12, 0)
        case .snowboarding: (14, 0)
        case .surfingSports: (38, 0)
        case .golf: (25, 0)
        case .soccer: (7, 0)
        case .tennis: (8, 0)
        case .basketball: (6, 0)
        default: (0, 0)
        }
    }
}
