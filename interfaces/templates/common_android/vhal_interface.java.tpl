// Copyright (C) 2020 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial
{% include "common/generated_comment.cpp.tpl" %}
{% set interface_zoned = interface.tags.config and interface.tags.config.zoned %}

package io.qt.{{module|qml_type|lower}};

import android.os.Build;
import androidx.annotation.RequiresApi;

@RequiresApi(Build.VERSION_CODES.Q)
public interface I{{interface}} {
{% for property in interface.properties %}
{%   if interface_zoned %}
    public {{property|java_type}} {{property|getter_name}}(int zoneId);
{%   else %}
    public {{property|java_type}} {{property|getter_name}}();
{%   endif %}
{%   if not property.readonly %}
{%     if interface_zoned %}
    public void set{{property|upperfirst}}(final {{property|java_type}} {{property}}, int zoneId);
{%     else %}
    public void set{{property|upperfirst}}(final {{property|java_type}} {{property}});
{%     endif %}
{%   endif %}

{% endfor %}
}
