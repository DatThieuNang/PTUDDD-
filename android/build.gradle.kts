// android/build.gradle.kts

// Khai báo plugin Google Services ở root (apply false)
plugins {
    id("com.google.gms.google-services") version "4.4.3" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// (Giữ nguyên tối ưu build dir theo template Flutter)
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    // Bảo đảm app được evaluate đúng thứ tự (theo template Flutter)
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
