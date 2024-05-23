// Copyright (C) 2020 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial
{% include "common/generated_comment.cpp.tpl" %}
{% set class = '{0}JniPlugin'.format(module.module_name) %}
{% set oncedefine = '{0}_{1}_H_'.format(module.module_name|upper, class|upper) %}

#ifndef {{oncedefine}}
#define {{oncedefine}}

#include <QVector>
#include <QtInterfaceFramework/QIfServiceInterface>

{{ module|begin_namespace }}

class {{class}} : public QObject, QIfServiceInterface
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QIfServiceInterface_iid FILE "{{module.module_name|lower}}.json")
    Q_INTERFACES(QIfServiceInterface)

public:
    typedef QVector<QIfFeatureInterface *> (InterfaceBuilder)({{class}} *);

    explicit {{class}}(QObject *parent = nullptr);

    QStringList interfaces() const;
    QIfFeatureInterface* interfaceInstance(const QString& interface) const;

private:
    QVector<QIfFeatureInterface *> m_interfaces;
};

{{ module|end_namespace }}

#endif // {{oncedefine}}
