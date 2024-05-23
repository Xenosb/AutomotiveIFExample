// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial
{% include "common/generated_comment.cpp.tpl" %}

{% for interface in module.interfaces %}
#include "{{interface|lower}}backend.h"
{% endfor %}
#include "jniutils.h"

#include <jni.h>
#include <android/log.h>

#include <QCoreApplication>
#include <QDateTime>
#include <QDebug>
#include <QMetaObject>

{% for interface in module.interfaces %}
{%    set class = '{0}Backend'.format(interface) %}
{%    set interface_zoned = interface.tags.config and interface.tags.config.zoned %}
{%    for property in interface.properties %}
{%      if interface_zoned %}
{%        set signal_arguments = ', jint zoneId' %}
{%      else %}
{%        set signal_arguments = '' %}
{%      endif %}

{{ module|begin_namespace }}

static void {{interface}}{{property|upperfirst}}Changed(JNIEnv * env, jobject /*obj*/, {{property|jni_type}} {{property}}{{signal_arguments}})
{
    Q_UNUSED(env)
{%        if property.type.is_string %}
    {{property|return_type}} value;
    if ({{property}})
        QString value(env->GetStringUTFChars({{property}}, nullptr));
{%        elif property.type.is_flag or property.type.is_enum %}
    bool ok;
    {{property|return_type}} value = {{property.module.module_name}}::to{{property|flag_type}}({{property}}, &ok);
{%        elif property.type.is_list %}
    {{property|return_type}} value = JniUtils::fromJniArrayToVariantList({{property}});
{%        else %}
    {{property|return_type}} value = {{property}};
{%        endif %}
{%        if property.tags.config_android_automotive %}
{%          set c = property.tags.config_android_automotive %}
{%          if interface_zoned %}
    const QStringList &zones = {{class}}::instance()->zones(zoneId);
    for (const QString &zone : zones)
        QMetaObject::invokeMethod({{class}}::instance(), "{{property}}Changed", Qt::QueuedConnection , Q_ARG({{property|return_type}}, value),  Q_ARG(QString, zone));
{%          else %}
    QMetaObject::invokeMethod({{class}}::instance(), "{{property}}Changed", Qt::QueuedConnection , Q_ARG({{property|return_type}}, value));
{%          endif %}
{%        endif %}

}
{%    endfor %}
static JNINativeMethod {{interface|lower}}_methods[] = {
{%    for property in interface.properties %}
{%      if interface_zoned %}
    {"{{property}}Changed", "({{property|jni_signature_type}}I)V", (void *){{interface}}{{property|upperfirst}}Changed},
{%      else %}
    {"{{property}}Changed", "({{property|jni_signature_type}})V", (void *){{interface}}{{property|upperfirst}}Changed},
{%      endif %}
{%    endfor %}
};

{% endfor %}

static bool isFeatureAutomotive()
{
    QJniObject context(QNativeInterface::QAndroidApplication::context());

    auto pm = context.callObjectMethod("getPackageManager",
                                       "()Landroid/content/pm/PackageManager;");
    auto automotiveField = QJniObject::getStaticObjectField("android/content/pm/PackageManager",
                                                            "FEATURE_AUTOMOTIVE",
                                                            "Ljava/lang/String;");
    return pm.callMethod<jboolean>("hasSystemFeature",
                                    "(Ljava/lang/String;)Z",
                                    automotiveField.object());
}

static bool isAppPlatformSigned()
{
    return QJniObject::callStaticMethod<jboolean, QtJniTypes::Context>(
                                                  "io/qt/androidautomotive/utils/QtCertUtils",
                                                  "isAppPlatformSigned",
                                                  QNativeInterface::QAndroidApplication::context());
}

static void reportError(const QString &error)
{
    QString finalError("Skipping back end initialization. " + error);
    if (!qEnvironmentVariableIsSet("NO_FATAL_PREREQUISITES_FAIL"))
        qFatal("%s", finalError.toUtf8().data());
    else
        qCritical("%s", finalError.toUtf8().data());
}

{{ module|end_namespace }}

{% set ns = module|namespace %}
{% if ns|length %}
using namespace {{ns}};
{% endif %}

// this method is called automatically by Java after the .so file is loaded
JNIEXPORT jint JNI_OnLoad(JavaVM* vm, void* /*reserved*/)
{
    bool IsValidForCarApi = true;
    IsValidForCarApi &= (QNativeInterface::QAndroidApplication::sdkVersion() >= 29);
    if (!IsValidForCarApi) {
        reportError("The Car API back end supports only Android 10 (Q) and above.");
    }

    IsValidForCarApi &= isFeatureAutomotive();
    if (!IsValidForCarApi) {
        reportError("The Car API back end supports only Android Automotive. "
                    "The current OS doesn't support FEATURE_AUTOMOTIVE feature.");
    }

    IsValidForCarApi &= isAppPlatformSigned();
    if (!IsValidForCarApi) {
        reportError("The app is not signed with a valid platform signature. "
                    "The Car API back end cannot work with an unsigned app.");
    }

    JNIEnv* env;
    // get the JNIEnv pointer.
    if (vm->GetEnv(reinterpret_cast<void**>(&env), JNI_VERSION_1_6) != JNI_OK) {
      __android_log_write(ANDROID_LOG_ERROR,"{{module}}Jni","Can't get JNIenv");
      return JNI_ERR;
    }
{% for interface in module.interfaces %}
    // search for {{module|qml_type|lower}}.{{interface}} class which declares the native methods
    jclass javaClass{{interface}} = env->FindClass("io/qt/{{module|qml_type|replace('.', '/')|lower}}/{{interface}}");
    if  (!javaClass{{interface}}) {
       __android_log_write(ANDROID_LOG_ERROR,"{{module}}Jni","{{interface}}: Can't find javaclass");
      return JNI_ERR;
    }

    // register native methods related to interfaces - function pointers are stored in {{interface|lower}}_methods array
    if (env->RegisterNatives(javaClass{{interface}}, {{interface|lower}}_methods,
                          sizeof({{interface|lower}}_methods) / sizeof({{interface|lower}}_methods[0])) < 0) {
     __android_log_write(ANDROID_LOG_ERROR,"{{module}}Jni","{{interface}}: Can't register natives");
      return JNI_ERR;
    }
{% endfor %}
    return JNI_VERSION_1_6;
}

