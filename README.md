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

Le SDK est structuré en couches :

- **Presentation**
  - `lib/main.dart`  
    Configure l’application Flutter côté SDK et écoute les commandes venant du host (React Native / Android) via un `MethodChannel`.
  - `lib/src/screens/user_profile_screen.dart`  
    Écran d’affichage du profil utilisateur à partir d’un `userId`.

- **Domain / État**
  - Un **state management basé sur un `ValueNotifier<int?>`** (`_userIdNotifier`) pour publier l’`userId` courant dans l’app.
  - Le widget racine `FlutterUserProfileApp` écoute ce notifier et bascule entre :
    - un écran d’attente lorsque aucun `userId` n’est disponible,
    - un `UserProfileScreen` lorsqu’un `userId` valide est reçu.

  Ce pattern permet d’avoir un **state centralisé** et réactif, sans utiliser directement `setState` dans les écrans de haut niveau. L’écran consomme un modèle déjà résolu (User) via un `FutureBuilder`.

- **Data**
  - `lib/src/models/user.dart`  
    Modèle immuable représentant l’utilisateur (id, prénom, nom, avatar, etc.).
  - `lib/src/services/user_service.dart`  
    Service HTTP qui :
    - appelle l’API AZEOO :
      ```http
      GET https://api.azeoo.dev/v1/users/me
      Headers :
        Accept-Language: fr-FR
        X-User-Id: <userId>
        Authorization: Bearer <TOKEN fournie>
      ```
    - mappe la réponse JSON => `User`.

### 2.3. Navigation (Flutter)

La logique suivante est utilisée :

- Au démarrage :
  - `WidgetsBinding.instance.platformDispatcher.defaultRouteName` est analysé.
  - Si la route ressemble à `/profile?userId=<id>`, l’`userId` est extrait.
- Pendant la vie de l’app :
  - Un `MethodChannel` nommé `flutter_user_sdk/user` écoute les appels du host :
    - méthode : `showUserProfile`
    - arguments : `{ "userId": <int> }`
  - Lorsqu’un appel est reçu, l’`userId` est mis à jour dans `_userIdNotifier`.

Au lieu d’empiler des routes avec `Navigator.push`, on **reconstruit simplement l’écran de profil depuis l’état courant**, ce qui reste simple à intégrer côté host.

### 2.4. Gestion des erreurs, chargement, cache

Dans `UserProfileScreen` :

- **Chargement** : affichage d’un `CircularProgressIndicator` pendant la récupération des données.
- **Erreur** : message d’erreur générique si la requête échoue (statut HTTP ≠ 200, timeouts, parsing…).
- **Succès** : affichage des infos utilisateur.

**Cache minimal** :

- Le service `UserService` peut conserver en mémoire le dernier profil récupéré, par `userId`.  
  Ce cache permet :
  - de réafficher instantanément un profil déjà chargé pendant la session,
  - de limiter les appels API si on repasse sur le même `userId`.

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

initialisation d’un FlutterEngine global,

enregistrement du MethodChannel (flutter_user_sdk/user),

mise en cache de l’engine si nécessaire.

FlutterHostActivity.kt :

Activité Kotlin qui :

récupère le userId passé via Intent depuis RN,

utilise le FlutterEngine existant,

appelle le MethodChannel showUserProfile avec { userId: <int> },

affiche le contenu Flutter (profil utilisateur).

FlutterUserSdkModule.kt + FlutterUserSdkPackage.kt :

Module React Native natif exposé vers JS :

méthode JS openUserProfile(userId: number) qui démarre FlutterHostActivity.

3.4. Côté React Native (JS/TS)

App.tsx :

Configure la navigation avec @react-navigation/native + @react-navigation/native-stack.

Déclare deux écrans :

Home : saisie de l’userId,

FlutterProfile : déclenche l’ouverture de l’écran Flutter.

src/screens/HomeScreen.tsx :

Input pour saisir userId (ex. 1 ou 3).

Bouton “Sauvegarder” qui :

persiste userId (state / async storage possible),

redirige vers l’écran de profil.

src/screens/FlutterUserProfileScreen.tsx :

Récupère l’userId (via params / storage),

Appelle le module natif FlutterUserSdk.openUserProfile(userId) pour lancer l’activité Flutter.

src/native/FlutterUserSdk.ts :

Petit wrapper TypeScript autour du NativeModules RN.

4. Installation & exécution
4.1. Prérequis

Flutter : version compatible (>= 3.5.0)

Dart : >= 3.5.0

Node.js : recommandé >= 18

Java JDK : 17

Android SDK avec API 34

Android Studio (ou équivalent) pour les outils de build

4.2. Build du SDK Flutter
cd flutter_user_sdk
flutter pub get
flutter build aar


Cela génère les AAR dans :

flutter_user_sdk/build/host/outputs/repo


Ils sont ensuite référencés par l’app RN via maven { url '../../flutter_user_sdk/build/host/outputs/repo' }.

4.3. Installation des dépendances React Native
cd rn_app
npm install

4.4. Build Android
cd rn_app/android
./gradlew assembleDebug


L’APK debug générée se trouvera dans :

rn_app/android/app/build/outputs/apk/debug/

5. Choix techniques et justification
5.1. State management

Utilisation d’un ValueNotifier<int?> global pour gérer l’userId :

simple,

réactif,

facilement accessible depuis le host via MethodChannel.

L’écran Flutter lit l’état via un widget dédié (FlutterUserProfileApp) qui écoute ce notifier.

Ce choix permet d’éviter setState dispersé partout et d’avoir un point d’entrée unique pour les mises à jour d’état venant du host.

5.2. Architecture modulaire

Séparation stricte :

UI (écrans),

Service (API),

Modèle (User),

Bridge host (MethodChannel).

Cette structure facilite l’évolution vers un state management plus avancé (Riverpod, Bloc, etc.) si besoin.

5.3. Navigation

Pas d’utilisation de Navigator.push côté host.

Navigation “pilotée par l’état” :

host envoie userId à Flutter,

Flutter met à jour l’écran à partir de cet état.

5.4. Intégration API

Utilisation du package http pour :

requête GET vers /v1/users/me,

ajout des headers : Accept-Language, Authorization, X-User-Id,

parsing JSON → modèle User.

5.5. Cache minimal

Caching en mémoire des profils déjà récupérés (par userId) dans le service.

Permet d’éviter des calls réseau inutiles dans la même session.

6. Améliorations possibles

Ajouter des tests unitaires sur :

le UserService,

la gestion d’erreurs HTTP,

le parsing JSON.

Ajouter un cache persistant (SharedPreferences / local DB) pour gérer le offline.

Ajouter des écrans supplémentaires dans le SDK Flutter (2 onglets gérés entièrement côté Flutter, comme demandé dans l’énoncé) :

par exemple : Profil / Activité à l’intérieur du SDK.

Ajouter l’intégration iOS native (Swift) en important le module Flutter sur Xcode.

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
