cmake_minimum_required(VERSION 3.16)

project(AutomotiveInterfaceExample VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(
    Qt6 6.5
    REQUIRED COMPONENTS
        Quick
        InterfaceFramework
        IfAndroidVehicleProperties
)

qt_standard_project_setup(
    REQUIRES 6.5
)

add_subdirectory(frontend)
add_subdirectory(backend)

qt_add_executable(
    ${CMAKE_PROJECT_NAME}
        MANUAL_FINALIZATION
        main.cpp
)

qt_add_qml_module(
    ${CMAKE_PROJECT_NAME}
    URI "Main"
    VERSION 1.0
    QML_FILES
        Main.qml
)

target_link_libraries(
    ${CMAKE_PROJECT_NAME}
    PRIVATE
        AutomotiveFrontend
        Qt::Quick
        Qt::InterfaceFramework
        Qt::IfAndroidVehicleProperties
)

set_target_properties(
    ${CMAKE_PROJECT_NAME}
    PROPERTIES
        LIBRARY_OUTPUT_DIRECTORY "interfaceframework"
        QT_ANDROID_VERSION_CODE "1"
        QT_ANDROID_VERSION_NAME "1.0"
        QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android"
)

qt_finalize_target(${CMAKE_PROJECT_NAME})

install(
    TARGETS ${CMAKE_PROJECT_NAME}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

if (ANDROID)
    include(C:/workspace_android/SDK/android_openssl/CMakeLists.txt)
endif()
