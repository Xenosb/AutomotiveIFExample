// Copyright (C) 2020 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial
{% include "common/generated_comment.cpp.tpl" %}
{% set class = '{0}JniPlugin'.format(module.module_name) %}

#include "{{class|lower}}.h"

{% for interface in module.interfaces %}
#include "{{interface|lower}}backend.h"
{% endfor %}

#include <QStringList>
#include <QDebug>
#include <jni.h>
#include <private/qjnihelpers_p.h>
extern jint JNI_OnLoad(JavaVM* vm, void* /*reserved*/);

{{ module|begin_namespace }}

{{class}}::{{class}}(QObject *parent)
    : QObject(parent)
{
    // When loading Qt IF plugin dll - the JNI_OnLoad needs to be called manually
    // in order to create JNI bindings
    if (JNI_OnLoad(QtAndroidPrivate::javaVM(), nullptr) != JNI_ERR) {
{% for interface in module.interfaces %}
        m_interfaces << {{interface}}Backend::instance();
{% endfor %}
    } else {
        qWarning() << "{{module}}: Unable to create JNI binding, interfaces not registered.";
    }
}

QStringList {{class}}::interfaces() const
{
    QStringList list;
{% for iface in module.interfaces %}
{%   if loop.first %}    list{% endif %} << {{module.module_name|upperfirst}}_{{iface}}_iid{% if loop.last %};{% endif %}
{% endfor %}

    return list;
}

QIfFeatureInterface *{{class}}::interfaceInstance(const QString &interface) const
{
     int index = interfaces().indexOf(interface);
     return index < 0 ? nullptr : m_interfaces.at(index);
}

{{ module|end_namespace }}
