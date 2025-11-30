# Test technique Flutter / React Native – AZEOO

Ce repository contient :

- Un **SDK Flutter** (`flutter_user_sdk`) permettant d’afficher le profil d’un utilisateur à partir d’un `userId`.
- Une **application de démonstration React Native** (`rn_app`) qui consomme ce SDK via une intégration Android native.

L’objectif est de démontrer :
- la capacité à concevoir un SDK Flutter modulaire et intégrable,
- la gestion d’un profil utilisateur via API (chargement, erreurs, cache minimal, rafraîchissement),
- l’intégration du SDK dans une app React Native, avec affichage du profil dans un écran Flutter lancé depuis React Native.

---

## 1. Architecture globale du projet

```text
TestTechniqueFlutter/
├── flutter_user_sdk/        # SDK Flutter (module AAR)
│   ├── lib/
│   │   ├── main.dart
│   │   ├── src/
│   │   │   ├── models/user.dart
│   │   │   ├── services/user_service.dart
│   │   │   ├── state/...
│   │   │   └── screens/user_profile_screen.dart
│   ├── pubspec.yaml
│   └── build/host/outputs/repo/  # AAR & Maven repo générés par `flutter build aar`
│
└── rn_app/                  # Application React Native d’intégration
    ├── App.tsx
    ├── index.js
    ├── package.json
    ├── android/
    │   ├── app/
    │   │   ├── build.gradle
    │   │   └── src/main/java/com/rn_app/...
    │   ├── build.gradle
    │   └── settings.gradle
    └── src/
        ├── screens/
        │   ├── HomeScreen.tsx
        │   └── FlutterUserProfileScreen.tsx
        └── native/
            └── FlutterUserSdk.ts

---

## 2. SDK Flutter (`flutter_user_sdk`)

### 2.1. Objectif

Le SDK fournit :
- un **écran de profil utilisateur** affichant :
  - prénom
  - nom
  - avatar
- une **API d’intégration** côté Android (via AAR) permettant :
  - de lancer l’UI Flutter depuis un host (RN / Android natif),
  - de passer un `userId` vers Flutter,
  - de rafraîchir l’affichage lorsque l’`userId` change.

### 2.2. Architecture interne (Flutter)

Le SDK est structuré en couches clairement séparées :

- **Navigation**  
  `lib/src/navigation/app_router.dart` expose un `GoRouter` minimaliste. L’utilisation d’`auto_route` ou `go_router` faisait partie des exigences : nous avons retenu `go_router` pour sa compatibilité avec Riverpod et sa simplicité lorsqu’il faut embarquer Flutter dans d’autres hôtes.

- **State management**  
  Toute la logique d’état est centralisée via **Riverpod** :
  - `user_selection_notifier.dart` stocke l’`userId` courant et évite l’usage direct de `setState`.
  - `profile_controller.dart` expose un `StateNotifier` responsable du cycle de vie des appels API (`loading` / `error` / `success`) et de l’invalidation manuelle (pull-to-refresh, demandes du host via `MethodChannel`).

- **Presentation**
  - `FlutterUserProfileApp` injecte un `ProviderScope`, configure le router et se connecte au `MethodChannel flutter_user_sdk/user`.
  - `ProfileHostScreen` affiche soit un state vide (aucun `userId` fourni), soit l’écran `UserProfileScreen`.
  - `UserProfileScreen` consomme `userProfileControllerProvider` pour afficher le profil, une progress bar, une vue d’erreur avec bouton retry et un `RefreshIndicator`.

- **Data**
  - `UserService` encapsule l’appel REST vers `https://api.azeoo.dev/v1/users/me` avec les en-têtes imposés.  
    Un cache mémoire (`Map<int, User>`) évite les requêtes inutiles et sert de “minimum cache” demandé.

### 2.3. Navigation (Flutter)

- Au démarrage, nous analysons `WidgetsBinding.instance.platformDispatcher.defaultRouteName` pour déterminer un `userId` initial (utile lorsque Flutter est lancé avec une route dédiée).
- L’application repose sur `GoRouter` pour orchestrer les écrans. Même si un seul écran est disponible aujourd’hui, l’approche est scalable : ajouter d’autres flows dans le SDK revient à déclarer de nouvelles routes.
- Pendant la vie de l’app, le host communique via le `MethodChannel` `flutter_user_sdk/user` :
  - `showUserProfile` → met à jour l’`userId` Riverpod (ce qui trigger un rebuild / refresh).
  - `refreshUserProfile` → force l’invalidation du cache et relance la requête.

### 2.4. Gestion des erreurs, chargement, cache

Dans `UserProfileScreen` :

- **Chargement** : `AsyncValue.loading` → `CircularProgressIndicator`.
- **Erreur** : `AsyncValue.error` → écran dédié avec bouton `Réessayer` (force `forceRefresh: true`).
- **Succès** : affichage du profil, bouton “Rafraîchir” et `RefreshIndicator` natif.

**Cache minimal** :

- `UserService` conserve en mémoire le dernier profil pour chaque `userId`.
- Le cache est utilisé automatiquement lors d’un nouvel affichage mais peut être invalidé (pull-to-refresh ou appel `refreshUserProfile`).

---

## 3. Intégration Android / React Native (`rn_app`)

### 3.1. Stack technique

- **React Native** : 0.71.12
- **TypeScript** pour les écrans RN.
- **Android** :
  - Gradle plugin Android : 8.1.0
  - Kotlin : 1.8.22
  - SDK 34

### 3.2. Intégration du module Flutter (AAR)

Côté Android (`rn_app/android`), l’intégration suit le schéma classique Flutter AAR :

- Dans `android/build.gradle` :

```gradle
buildscript {
    ext {
        buildToolsVersion = "34.0.0"
        minSdkVersion = 21
        compileSdkVersion = 34
        targetSdkVersion = 34
        ndkVersion = "25.1.8937393"
        kotlinVersion = "1.8.22"
    }
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.1.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.8.22")
        classpath("com.facebook.react:react-native-gradle-plugin")
    }
}

apply plugin: "com.facebook.react.rootproject"










Dans android/settings.gradle :

rootProject.name = 'rn_app'
apply from: file("../node_modules/@react-native-community/cli-platform-android/native_modules.gradle")
applyNativeModulesSettingsGradle(settings)
include ':app'





Dans android/app/build.gradle (extraits importants) :

android {
    compileSdkVersion rootProject.ext.compileSdkVersion

    defaultConfig {
        applicationId "com.rn_app"
        minSdkVersion rootProject.ext.minSdkVersion
        targetSdkVersion rootProject.ext.targetSdkVersion
        versionCode 1
        versionName "1.0"
    }

    buildTypes {
        debug { }
        release { }
        profile { initWith debug }
    }
}

repositories {
    maven { url '../../flutter_user_sdk/build/host/outputs/repo' }
    maven { url "https://storage.googleapis.com/download.flutter.io" }
    maven { url "$rootDir/local-maven" }
    google()
    mavenCentral()
}

dependencies {
    implementation("com.facebook.react:react-android")
    implementation("com.facebook.react:flipper-integration")
    implementation("androidx.swiperefreshlayout:swiperefreshlayout:1.0.0")

    debugImplementation 'com.example.flutter_user_sdk:flutter_debug:1.0'
    profileImplementation 'com.example.flutter_user_sdk:flutter_profile:1.0'
    releaseImplementation 'com.example.flutter_user_sdk:flutter_release:1.0'
}


Ces blocs permettent à l’app RN de consommer le SDK Flutter comme un module AAR Maven.

3.3. Bridge natif côté Android

Côté rn_app/android/app/src/main/java/com/rn_app/ :

MainApplication.java :

- pré-chauffe un `FlutterEngine` (DartEntrypoint exécuté dès le démarrage de l’app RN),
- enregistre automatiquement les plugins Flutter (`GeneratedPluginRegistrant`),
- stocke l’engine dans le `FlutterEngineCache` pour réutilisation.

FlutterHostActivity.kt :

- récupère le `userId` reçu via `Intent`,
- récupère l’engine mis en cache via `provideFlutterEngine`,
- envoie `showUserProfile` (ou `refresh`) via `MethodChannel` sur l’engine déjà en cours d’exécution,
- affiche immédiatement la vue Flutter (aucune recréation d’engine).

FlutterUserSdkModule.kt + FlutterUserSdkPackage.kt :

Module React Native natif exposé vers JS :

méthode JS openUserProfile(userId: number) qui démarre FlutterHostActivity.

3.4. Côté React Native (JS/TS)

- `App.tsx`  
  Utilise `NavigationContainer` + `createBottomTabNavigator` (2 onglets). Le provider `UserIdProvider` (basé sur `AsyncStorage`) injecte l’`userId` partout dans l’application.

- `HomeScreen.tsx`  
  Onglet 1 : saisie d’un userId → validation → persistance dans `AsyncStorage`. A chaque sauvegarde, le contexte est mis à jour, ce qui déclenche un refresh du SDK Flutter.

- `FlutterUserProfileScreen.tsx`  
  Onglet 2 : écoute le contexte `useUserId` et, à chaque focus du tab, appelle automatiquement `openFlutterUserProfile(userId)` pour afficher / rafraîchir la vue Flutter. Bouton secondaire “Relancer / rafraîchir” pour forcer l’actualisation.

- `src/state/UserIdContext.tsx`  
  Centralise la persistance de l’`userId` (chargement initial + hook `useUserId`).

- `src/native/FlutterUserSdk.ts`  
  Wrapper TypeScript sécurisé qui s’appuie sur le NativeModule (Android + iOS) et expose une API `Promise` (gestion d’erreurs côté JS).

3.5. Bridge natif côté iOS

- `AppDelegate` démarre un `FlutterEngine` partagé (`flutter_user_engine`) et enregistre les plugins générés.
- `FlutterUserSdkModule.m` implémente `RCTBridgeModule`, présente un `FlutterViewController` associé à l’engine et communique via le `MethodChannel flutter_user_sdk/user`.
- La promesse retournée au layer JS permet de savoir quand la vue Flutter est affichée (utile pour tracer les rafraîchissements).

4. Installation & exécution
4.1. Prérequis

Flutter : version compatible (>= 3.5.0)

Dart : >= 3.5.0

Node.js : recommandé >= 18

Java JDK : 17

Android SDK avec API 34

Android Studio (ou équivalent) pour les outils de build

4.2. Build du SDK Flutter
```bash
cd flutter_user_sdk
flutter pub get
flutter build aar
flutter build ios-framework --cocoapods --output=build/ios-framework
```

Cela génère :

- les AAR dans `flutter_user_sdk/build/host/outputs/repo` (consommés côté Android via le repository Maven local),
- les frameworks iOS dans `flutter_user_sdk/build/ios-framework`. Ce build crée également `.ios/Flutter/podhelper.rb` utilisé par le Podfile RN.

4.3. Installation des dépendances React Native
```bash
cd rn_app
npm install
cd ios && pod install
```

4.4. Build Android
cd rn_app/android
./gradlew assembleDebug


L’APK debug générée se trouvera dans :

rn_app/android/app/build/outputs/apk/debug/

5. Choix techniques et justification
5.1. State management

- Riverpod (`StateNotifierProvider`) gouverne l’`userId` courant ainsi que l’état réseau (`AsyncValue<User>`).
- Aucune logique ne repose sur `setState`. Toutes les mutations proviennent soit du `MethodChannel`, soit d’actions utilisateur (pull-to-refresh, bouton “Rafraîchir”).
- Les dépendances sont injectées via `ProviderScope`, ce qui facilite les tests unitaires (mock du `UserService`).

5.2. Architecture modulaire

- UI : `ProfileHostScreen`, `UserProfileScreen`, composants de feedback.
- Navigation : `GoRouter` isolé dans `src/navigation`.
- State : notifiers et providers dans `src/state`.
- Data : `UserService` + cache mémoire.
- Bridge : `MethodChannel` unique `flutter_user_sdk/user`.

5.3. Navigation

- Utilisation de `go_router` (exigence “navigation avancée”).
- Ajout d’une route host qui pourra facilement évoluer (ex : ajouter une sous-navigation Flutter pour gérer la tabbar côté SDK si nécessaire).
- Synchronisation host ↔ Flutter via route initiale ET via `MethodChannel`.

5.4. Intégration API

Utilisation du package http pour :

requête GET vers /v1/users/me,

ajout des headers : Accept-Language, Authorization, X-User-Id,

parsing JSON → modèle User.

5.5. Cache minimal

- `UserService` stocke les profils par `userId` dans `_memoryCache`.
- `ProfileController` commence par servir le cache (UX instantanée) puis peut forcer un refresh (pull-to-refresh, bouton, commande host).

6. Améliorations possibles

Ajouter des tests unitaires sur :

le UserService,

la gestion d’erreurs HTTP,

le parsing JSON.

Ajouter un cache persistant (SharedPreferences / local DB) pour gérer le offline.

Ajouter des écrans supplémentaires dans le SDK Flutter (ex : activity feed, préférences).

Outiller davantage la partie iOS (fermeture programmatique de la `FlutterViewController`, gestures custom, etc.).

7. Vidéo de présentation (optionnel)

Une vidéo de quelques minutes peut être ajoutée pour :

Montrer le flow complet :

saisie de l’userId dans l’onglet React Native,

ouverture de l’écran Flutter affichant le profil correspondant.

Expliquer :

les choix d’architecture,

la logique d’intégration AAR,

la gestion de l’état et des erreurs.

8. Auteurs

Développement & intégration : Brice Georgy Fandio

Contact : [https://www.linkedin.com/in/brice-georgy-fandio-80ab27171/
bricegeorgyfandio@yahoo.fr]


---
