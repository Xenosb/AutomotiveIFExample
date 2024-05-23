# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial
#############################################################################
## This is an auto-generated file.
## Do not edit! All changes made to it will be lost.
#############################################################################
qt6_set_ifcodegen_variable(${VAR_PREFIX}_SOURCES

{% for interface in module.interfaces %}
    ${CMAKE_CURRENT_LIST_DIR}/{{interface|lower}}backend.cpp
{% endfor %}
    ${CMAKE_CURRENT_LIST_DIR}/{{module.module_name|lower}}jniplugin.cpp
    ${CMAKE_CURRENT_LIST_DIR}/native_mappings.cpp
    ${CMAKE_CURRENT_LIST_DIR}/jniutils.cpp
)

if (TARGET ${CURRENT_TARGET})
    target_sources(${CURRENT_TARGET}
        PRIVATE
        ${${VAR_PREFIX}_SOURCES}
    )
endif()
