// Copyright (C) 2020 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial
{% import 'common/qtif_macros.j2' as qtif %}
{% include "common/generated_comment.cpp.tpl" %}
{% set class = '{0}Backend'.format(interface) %}
{% set interface_zoned = interface.tags.config and interface.tags.config.zoned %}
{% set oncedefine = '{0}_{1}_H_'.format(module.module_name|upper, class|upper) %}
#ifndef {{oncedefine}}
#define {{oncedefine}}

#include <QObject>
#include <QScopedPointer>
#include <QJniObject>
#include <QStringList>

{% if module.tags.config.module %}
#include <{{module.tags.config.module}}/{{class}}Interface>
{% else %}
#include "{{class|lower}}interface.h"
{% endif %}

{{ module|begin_namespace }}

class {{class}} : public {{class}}Interface
{
    Q_OBJECT

{% for property in interface.properties %}
{%   if property.type.is_model %}
{{     error("Model data types are not supported for this generarator") }}
{%   else %}
{%     set type = property|return_type %}
{%   endif %}
{%   if not property.readonly %}
    Q_PROPERTY({{type}} {{property}} READ {{property|getter_name}} WRITE {{property|setter_name}}  NOTIFY {{property.name}}Changed FINAL)
{%   else %}
    Q_PROPERTY({{type}} {{property}} READ {{property|getter_name}} NOTIFY {{property.name}}Changed FINAL)
{%   endif %}
{% endfor %}

public:
    static {{class}} *instance();
    {{class}}(const {{class}} &) = delete;
    {{class}} &operator=(const {{class}} &) = delete;

{%   if interface_zoned %}
    Q_INVOKABLE QStringList availableZones() const override;
    QStringList zones(int zoneId) const;
    int zoneId(QString zone) const;
{%   endif %}

    Q_INVOKABLE void initialize() override;

public Q_SLOTS:
{% for property in interface.properties %}
{%   set propKeyword = '' %}
{%   if property.readonly %}
{%     set propKeyword = 'READONLY' %}
{%   endif %}
{%   if not property.is_model %}
{%     if interface_zoned %}
{%       set getter_zone_argument = 'const QString &zone = QString()' %}
{%     else %}
{%       set getter_zone_argument = '' %}
{%     endif %}
    {{property|return_type|replace(" *", "")}} {{property|getter_name}}({{getter_zone_argument}});
{%     if not property.readonly %}
    {{qtif.prop_setter(property,  zoned = interface_zoned, model_interface = false, default_zone = interface_zoned)}} override;
{%     endif %}
{%   else %}
{{     error("Model data types are not supported for this generarator") }}
{%   endif %}
{% endfor %}

{% for operation in interface.operations %}
    QVariant {{operation}}({{qtif.join_params(operation, zoned = interface_zoned)}}) override;
{% endfor %}

Q_SIGNALS:
    void pendingResultAvailable(quint64 id, bool isSuccess, const QVariant &value);

private:
    explicit {{class}}();
    ~{{class}}();

    QScopedPointer<QJniObject> m_javaWrapper;
{% if interface_zoned %}
    QHash<QString, int> m_zoneMappings;
    QHash<int, QStringList> m_zoneIdToNamesMapping;
{% endif %}
};

{{ module|end_namespace }}

#endif // {{oncedefine}}
