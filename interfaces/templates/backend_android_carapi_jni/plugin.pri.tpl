# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial
#############################################################################
## This is an auto-generated file.
## Do not edit! All changes made to it will be lost.
#############################################################################
HEADERS += \
{% for interface in module.interfaces %}
    $$OUT_PWD/{{interface|lower}}backend.h \
{% endfor %}
    $$OUT_PWD/{{module.module_name|lower}}jniplugin.h \
    $$OUT_PWD/jniutils.h

SOURCES += \
{% for interface in module.interfaces %}
    $$OUT_PWD/{{interface|lower}}backend.cpp \
{% endfor %}
    $$OUT_PWD/{{module.module_name|lower}}jniplugin.cpp \
    $$OUT_PWD/native_mappings.cpp \
    $$OUT_PWD/jniutils.cpp

OTHER_FILES += \
{% for interface in module.interfaces %}
    $$OUT_PWD/android/src/io/qt/{{module|qml_type|replace('.', '/')|lower}}/{{interface}}.java \
    $$OUT_PWD/android/src/io/qt/{{module|qml_type|replace('.', '/')|lower}}/I{{interface}}.java \
    $$OUT_PWD/android/src/io/qt/{{module|qml_type|replace('.', '/')|lower}}/{{interface}}Sensors.java \
    $$OUT_PWD/android/src/io/qt/{{module|qml_type|replace('.', '/')|lower}}/{{interface}}Backend.java \
{% endfor %}
