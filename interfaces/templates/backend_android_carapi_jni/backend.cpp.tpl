// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial
{% import 'common/qtif_macros.j2' as qtif %}
{% include "common/generated_comment.cpp.tpl" %}
{% set class = '{0}Backend'.format(interface) %}
{% set interface_zoned = interface.tags.config and interface.tags.config.zoned %}
#include "{{class|lower}}.h"
#include "jniutils.h"

#include <QCoreApplication>
#include <QDebug>
#include <QTimer>
#include <private/qandroidextras_p.h>

{% set _permissions = dict()%}
{# This is the case when only one permission is defined #}
{% if interface.tags.config.required_permissions is string %}
{% set _dummy = _permissions.update({interface.tags.config.required_permissions: "_"}) %}
{% else %}
{# This is the case when many permissions are defined #}
{% for permission in interface.tags.config.required_permissions %}
{% set _dummy = _permissions.update({permission: "_"}) %}
{% endfor %}
{% endif%}

{{ module|begin_namespace }}

{{class}} *{{class}}::instance()
{
    static {{class}}* inst = new {{class}}();
    return inst;
}

{{class}}::{{class}}()
    : {{class}}Interface()
    , m_javaWrapper(nullptr)
{
{% for permission in _permissions%}
    const QString perm_{{loop.index}}("{{permission}}");
    if(QtAndroidPrivate::requestPermission(perm_{{loop.index}}).result() != QtAndroidPrivate::Authorized)
        qWarning() << "Could not get permission for:" << perm_{{loop.index}};
{% endfor%}

    QJniObject::callStaticMethod<void>("io/qt/{{module|qml_type|replace('.', '/')|lower}}/{{interface}}Sensors",
                                       "initStatic");
{% if interface_zoned %}
{%   if interface.tags.config_android_automotive and interface.tags.config_android_automotive.zoneMappings %}
{%     set zonesMapDict = dict() %}
{%     for zone, zoneMapping in interface.tags.config_android_automotive.zoneMappings.items() %}
{%       set _dummy = zonesMapDict.update( {zoneMapping: zone }) %}
{%       set _const_var = 'zoneId_{0}'.format(loop.index) %}
    const int {{_const_var}} = QJniObject::getStaticField<jint>("io/qt/{{module|qml_type|replace('.', '/')|lower}}/{{interface}}Sensors", "{{zoneMapping}}");
    m_zoneMappings.insert(QStringLiteral("{{zone}}"), {{_const_var}});
    m_zoneIdToNamesMapping[{{_const_var}}].append(QStringLiteral("{{zone}}"));
{%     endfor %}
{%   endif %}
{% endif %}

    {{module.module_name|upperfirst}}::registerTypes();
    QJniEnvironment qjniEnv;
    jclass clazz = qjniEnv->FindClass("io/qt/{{module|qml_type|replace('.', '/')|lower}}/I{{interface}}");
    QtJniTypes::Context context = QNativeInterface::QAndroidApplication::context();
    if (qjniEnv->IsInstanceOf(context.object(), clazz))
        m_javaWrapper.reset(new QJniObject(context));
    else
        m_javaWrapper.reset(new QJniObject("io/qt/{{module|qml_type|replace('.', '/')|lower}}/{{interface}}Backend", context));
}

{{class}}::~{{class}}()
{
}

void {{class}}::initialize()
{
    if (!m_javaWrapper.isNull()) {
{% for property in interface.properties %}
{%   if interface_zoned and interface.tags.config_android_automotive and interface.tags.config_android_automotive.zoneMappings %}
{%     if not zonesMapDict %}
{%         set zonesMapDict = dict() %}
{%           for zone, zoneMapping in interface.tags.config_android_automotive.zoneMappings.items() %}
{%             set _dummy = zonesMapDict.update( {zoneMapping: zone }) %}
{%           endfor %}
{%     endif %}
{%     set zones = property.tags.config_android_automotive.zone %}
{%     if zones is string %}
{%       set zones = [property.tags.config_android_automotive.zone] %}
{%     endif %}
{%     for zone in zones %}
        {{property}}Changed({{property|getter_name}}("{{zonesMapDict[zone]}}"), "{{zonesMapDict[zone]}}");
{%     endfor %}
{%   else %}
        {{property}}Changed({{property|getter_name}}());
{%   endif %}
{% endfor %}
        Q_EMIT initializationDone();
    } else {
        qWarning() << "{{class}}: JAVA wrapper not ready";
    }
}

{% for property in interface.properties %}
{%   if not property.is_model %}
{%     if interface_zoned %}
{{property|return_type|replace(" *", "")}} {{class}}::{{property|getter_name}}(const QString &zone)
{
    auto zoneIdValue = zoneId(zone);
{%     else %}
{{property|return_type|replace(" *", "")}} {{class}}::{{property|getter_name}}()
{
{%     endif %}
    {{property|return_type}} value = {{property|default_type_value}};
    if (!m_javaWrapper.isNull() && m_javaWrapper->isValid()) {
{%     if interface_zoned %}
{%       set signal_arguments = '"{0}", "(I){1}", zoneIdValue'.format(property|getter_name, property|jni_signature_type) %}
{%     else %}
{%       set signal_arguments = '"{0}"'.format(property|getter_name) %}
{%     endif %}

{%     if property.type.is_string %}
        value = m_javaWrapper->callObjectMethod<{{property|jni_type}}>({{signal_arguments}}).toString();
{%     elif property.type.is_flag or property.type.is_enum %}
        bool ok;
        value = {{property.module.module_name}}::to{{property|flag_type}}(m_javaWrapper->callMethod<{{property|jni_type}}>({{signal_arguments}}), &ok);
{%     elif property.type.is_list%}
        value = JniUtils::fromJniArrayToVariantList(m_javaWrapper->callObjectMethod({{signal_arguments}}).object<{{property|jni_type}}>());
{%     else %}
        value = m_javaWrapper->callMethod<{{property|jni_type}}>({{signal_arguments}});
{%     endif %}
    } else {
        qWarning() << "{{class}} JAVA wrapper not ready";
    }
    return value;
}

{%     if not property.readonly %}
{{qtif.prop_setter(property, class, zoned = interface_zoned)}}
{
{%       if property.tags.config_android_automotive %}
{%         set c = property.tags.config_android_automotive %}
{%         if interface_zoned %}
{%           set property_if_argument = 'zone' %}
{%           set property_call_method_argument = ', zoneIdValue' %}
{%           set property_zone_type = 'I' %}
    auto zoneIdValue = zoneId(zone);
{%         else %}
{%           set property_if_argument = '' %}
{%           set property_call_method_argument = '' %}
{%           set property_zone_type = '' %}
{%         endif %}
    if (this->{{property|getter_name}}({{property_if_argument}}) == {{property}} || m_javaWrapper.isNull() || !m_javaWrapper->isValid()) {
        return;
    }
{%         set jni_call_signature = '"set{0}","({1}{2})V"'.format(property|upperfirst, property|jni_signature_type, property_zone_type) %}
{%         if property.type.is_string %}
    QJniObject str = QJniObject::fromString({{property}});
    m_javaWrapper->callMethod<void>({{jni_call_signature}},
                                    str.object<jstring>(){{property_call_method_argument}});
{%         elif property.type.is_list %}
    m_javaWrapper->callMethod<void>({{jni_call_signature}},
                                    JniUtils::fromVariantListToJniArray({{property}}){{property_call_method_argument}});
{%         else %}
    m_javaWrapper->callMethod<void>({{jni_call_signature}},
                                    {{property}}{{property_call_method_argument}});
{%         endif %}
{%       endif %}
}

{%     endif %}
{%   else %}
{{     error("Model data types are not supported for this generarator") }}
{%   endif %}
{% endfor %}

{% if interface_zoned %}
QStringList {{class}}::availableZones() const
{
    return m_zoneMappings.keys();
}

QStringList {{class}}::zones(int zoneId) const
{
    return m_zoneIdToNamesMapping[zoneId];
}

int {{class}}::zoneId(QString zone) const
{
    return m_zoneMappings.value(zone);
}
{% endif %}
{% for operation in interface.operations %}

QVariant {{class}}::{{operation}}({{qtif.join_params(operation, zoned = interface_zoned)}})
{
    // TODO: handle operations if proper usecase exists otherwise remove that after QAA-48
{{ warning("Operations are not supported yet by this template and will result in returning invalid values") }}
    return QVariant();
}
{% endfor %}

{{ module|end_namespace }}
