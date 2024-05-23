// Copyright (C) 2020 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial
{% include "common/generated_comment.cpp.tpl" %}
{% set interface_zoned = interface.tags.config and interface.tags.config.zoned %}

package io.qt.{{module|qml_type|lower}};

// Special comment because I am special

public class {{interface}} {
{% for property in interface.properties %}
{%   if interface_zoned %}
    public static native void {{property}}Changed({{property|java_type}} {{property}}, int zoneId);
{%   else %}
    public static native void {{property}}Changed({{property|java_type}} {{property}});
{%   endif %}
{% endfor %}
}
