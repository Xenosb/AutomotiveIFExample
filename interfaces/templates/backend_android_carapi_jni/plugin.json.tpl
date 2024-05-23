{# Copyright (C) 2020 The Qt Company Ltd. #}
{# SPDX-License-Identifier: LicenseRef-Qt-Commercial #}
{
    "interfaces" : [
{% for interface in module.interfaces %}
{%   set iid=interface.qualified_name %}
{%   if 'config' in interface.tags and 'id' in interface.tags.config %}
{%     set iid=interface.tags.config.id %}
{%   endif %}
      "{{iid}}"{% if not loop.last %},{%endif%}
{% endfor%}
    ]
}
