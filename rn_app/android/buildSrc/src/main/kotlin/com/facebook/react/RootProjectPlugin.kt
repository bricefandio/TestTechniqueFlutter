package com.facebook.react

import org.gradle.api.Plugin
import org.gradle.api.Project

/**
 * Minimal root-project plugin so the React Native Gradle plugin can be resolved without
 * relying on includeBuild.
 */
class RootProjectPlugin : Plugin<Project> {
    override fun apply(target: Project) {
        // No-op: the module-level plugin sets up all required configuration.
        // This placeholder simply allows builds to reference the 'com.facebook.react.rootproject'
        // plugin id without failing during evaluation.
    }
}
