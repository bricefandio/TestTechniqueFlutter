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
