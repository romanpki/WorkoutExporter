# App Store Connect — Contenu pour la publication

> Copie-colle chaque section dans le champ correspondant d'App Store Connect.

---

## Informations de l'app

**Nom de l'app :**
```
WorkoutExporter
```

**Sous-titre (30 caractères max) :**
```
Export Health Workouts
```

**Catégorie principale :**
```
Santé et forme
```

**Catégorie secondaire :**
```
Utilitaires
```

---

## Version — Informations localisables

### Français

**Texte promotionnel (170 caractères max) :**
> Ce texte peut être modifié à tout moment sans soumettre une nouvelle version.

```
Exportez vos séances sportives Apple Health en GPX, TCX, FIT, CSV, JSON et XML. Gratuit, sans compte, sans tracking. Vos données, votre choix.
```

**Description :**
```
WorkoutExporter vous permet d'exporter n'importe quelle séance d'entraînement enregistrée dans Apple Health dans le format standard de votre choix.

FORMATS D'EXPORT
• GPX — Tracé GPS avec fréquence cardiaque et cadence. Compatible Strava, Garmin Connect, Komoot.
• TCX — Format Training Center XML avec données physiologiques détaillées (FC, cadence, puissance, vitesse).
• FIT — Format binaire Garmin, le plus complet. Compatible Garmin Connect, TrainingPeaks.
• CSV — Tableau exploitable dans Excel ou Google Sheets avec toutes les données chronologiques.
• JSON — Export brut complet de toutes les données HealthKit de la séance.
• XML — Format identique à l'export natif d'Apple Health, limité à une seule séance.

DONNÉES EXTRAITES
• Tracé GPS complet (latitude, longitude, altitude)
• Fréquence cardiaque
• Cadence (course et vélo)
• Puissance (course et vélo)
• Vitesse
• Dénivelé
• Splits et segments
• Mouvements de nage

TOUS LES SPORTS
Course à pied, vélo, natation, randonnée, yoga, HIIT, musculation, triathlon et 60+ types d'activités — tous les workouts enregistrés dans Apple Health sont supportés, quelle que soit l'app qui les a enregistrés.

VISUALISATION
• Carte du parcours avec MapKit
• Graphique de fréquence cardiaque avec Swift Charts
• Statistiques détaillées (durée, distance, calories, FC moyenne/max)

PARTAGE FLEXIBLE
• Share Sheet iOS : AirDrop, Mail, Messages, Strava, Garmin Connect...
• Sauvegarde directe dans l'app Fichiers (iCloud Drive ou stockage local)

RESPECT DE LA VIE PRIVÉE
WorkoutExporter ne collecte aucune donnée. Pas de serveur, pas d'analytics, pas de compte utilisateur. Toutes vos données restent sur votre appareil.

100% NATIF
Développé en Swift et SwiftUI avec uniquement des frameworks Apple (HealthKit, MapKit, Swift Charts, CoreLocation). Aucune dépendance tierce.

L'app est gratuite. Un pourboire optionnel est disponible pour soutenir le développement.
```

**Mots-clés (100 caractères max, séparés par des virgules) :**
```
workout,export,gpx,tcx,fit,health,santé,fitness,running,cycling
```

**URL de l'assistance :**
```
https://romanpki.github.io/WorkoutExporter
```

**URL de la politique de confidentialité :**
```
https://romanpki.github.io/WorkoutExporter/privacy.html
```

---

### English

**Promotional Text (170 chars max):**
```
Export your Apple Health workouts to GPX, TCX, FIT, CSV, JSON and XML. Free, no account, no tracking. Your data, your way.
```

**Description:**
```
WorkoutExporter lets you export any workout recorded in Apple Health to the standard format of your choice.

EXPORT FORMATS
• GPX — GPS trace with heart rate and cadence. Compatible with Strava, Garmin Connect, Komoot.
• TCX — Training Center XML with detailed physiological data (HR, cadence, power, speed).
• FIT — Garmin binary format, the most complete. Compatible with Garmin Connect, TrainingPeaks.
• CSV — Spreadsheet-ready with all time-series data merged by timestamp.
• JSON — Complete raw data dump of all HealthKit fields.
• XML — Same format as Apple's native Health Export, scoped to a single workout.

EXTRACTED DATA
• Full GPS route (latitude, longitude, altitude)
• Heart rate
• Cadence (running and cycling)
• Power (running and cycling)
• Speed
• Elevation gain/loss
• Splits and segments
• Swimming stroke count

ALL SPORTS
Running, cycling, swimming, hiking, yoga, HIIT, strength training, triathlon and 60+ activity types — every workout in Apple Health is supported, regardless of which app recorded it.

VISUALIZATION
• Route map with MapKit
• Heart rate chart with Swift Charts
• Detailed stats (duration, distance, calories, avg/max HR)

FLEXIBLE SHARING
• iOS Share Sheet: AirDrop, Mail, Messages, Strava, Garmin Connect...
• Save directly to the Files app (iCloud Drive or local storage)

PRIVACY FIRST
WorkoutExporter collects zero data. No server, no analytics, no user account. All your data stays on your device.

100% NATIVE
Built with Swift and SwiftUI using only Apple frameworks (HealthKit, MapKit, Swift Charts, CoreLocation). Zero third-party dependencies.

The app is free. An optional tip is available to support development.
```

**Keywords (100 chars max, comma-separated):**
```
workout,export,gpx,tcx,fit,health,fitness,running,cycling,swim
```

**Support URL:**
```
https://romanpki.github.io/WorkoutExporter
```

**Privacy Policy URL:**
```
https://romanpki.github.io/WorkoutExporter/privacy.html
```

---

## Informations sur la version

**Nouveautés de cette version :**
```
Première version de WorkoutExporter !

• Export de séances Apple Health en 6 formats : GPX, TCX, FIT, CSV, JSON, XML
• Visualisation du parcours et de la fréquence cardiaque
• Partage via Share Sheet et sauvegarde dans Fichiers
• Support de 60+ types d'activités sportives
```

---

## Informations de review Apple

**Notes pour le reviewer :**
```
WorkoutExporter is a read-only HealthKit app that exports workout data to standard fitness file formats (GPX, TCX, FIT, CSV, JSON, XML).

To test:
1. Launch the app and authorize HealthKit access
2. The app displays all workouts from Apple Health
3. Tap any workout to see details (route map, heart rate chart)
4. Tap the share button to select an export format and share/save the file

The app requires HealthKit authorization to function. It only reads data — it never writes to HealthKit. The NSHealthUpdateUsageDescription is included because Apple requires it when the HealthKit entitlement is present, but no write operations are performed.

No login required. No server communication. The app works entirely offline.
```

**Identifiant du demo account :**
```
(aucun — pas de système de compte)
```

---

## App Privacy (section Confidentialité)

Dans App Store Connect > App Privacy, sélectionner :

**Collecte de données :** `Non, nous ne collectons aucune donnée`

> C'est tout. Puisque l'app ne collecte, ne transmet et ne partage aucune donnée, la fiche App Privacy sera affichée comme "Aucune donnée collectée".

---

## Achats intégrés (Tip Jar)

> À configurer dans App Store Connect > In-App Purchases si tu souhaites ajouter le pourboire.

| ID produit | Type | Prix | Nom affiché (FR) | Nom affiché (EN) |
|-----------|------|------|-------------------|-------------------|
| `com.roman.WorkoutExporter.tip.small` | Consommable | 1,99 € | Petit pourboire | Small Tip |
| `com.roman.WorkoutExporter.tip.medium` | Consommable | 4,99 € | Pourboire généreux | Generous Tip |
| `com.roman.WorkoutExporter.tip.large` | Consommable | 9,99 € | Super pourboire | Super Tip |

**Description de review (pour chaque IAP) :**
```
This is a voluntary tip to support the developer. It does not unlock any feature — the app is fully functional without it.
```

---

## Checklist avant soumission

- [ ] Icône d'app 1024x1024 uploadée
- [ ] Au moins 3 screenshots iPhone (6.7" et 6.1") uploadés
- [ ] Au moins 3 screenshots iPad (si support iPad) uploadés
- [ ] Politique de confidentialité publiée sur romanpki.github.io/WorkoutExporter/privacy.html
- [ ] Catégorie "Santé et forme" sélectionnée
- [ ] App Privacy rempli ("Aucune donnée collectée")
- [ ] Rating configuré (probablement 4+, pas de contenu sensible)
- [ ] Pays de distribution sélectionnés
- [ ] Prix : Gratuit
- [ ] In-App Purchases configurés (si Tip Jar)
- [ ] Build uploadé via Xcode (Archive > Distribute > App Store Connect)
- [ ] Build sélectionné dans la version App Store Connect
