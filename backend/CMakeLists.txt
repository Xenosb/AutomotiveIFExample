set(MODULE_NAME AutomotiveBackend)

qt_add_plugin(
    ${MODULE_NAME}
    PLUGIN_TYPE interfaceframework
)

# set_target_properties(
#     ${MODULE_NAME}
#     PROPERTIES
#         LIBRARY_OUTPUT_DIRECTORY ../interfaceframework
# )

qt_ifcodegen_extend_target(
    ${MODULE_NAME}
        IDL_FILES ../interfaces/ifandroidvehicleproperties.qface
        TEMPLATE ../interfaces/templates/backend_android_carapi_jni
)

target_link_libraries(
    ${MODULE_NAME}
    PRIVATE
        AutomotiveFrontend
)
