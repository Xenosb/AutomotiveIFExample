set(MODULE_NAME AutomotiveFrontend)

qt_add_library(
    ${MODULE_NAME}
    STATIC
)

set_target_properties(
    ${MODULE_NAME}
    PROPERTIES
        OUTPUT_NAME ${MODULE_NAME}
        RUNTIME_OUTPUT_DIRECTORY ../
)

qt_ifcodegen_extend_target(
    ${MODULE_NAME}
        IDL_FILES ../interfaces/ifandroidvehicleproperties.qface
        TEMPLATE frontend
)

target_link_libraries(
    ${MODULE_NAME}
    PRIVATE
        Qt::Quick
        Qt::InterfaceFramework
        Qt::IfAndroidVehicleProperties
)
