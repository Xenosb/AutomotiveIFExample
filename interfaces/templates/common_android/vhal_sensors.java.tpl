// Copyright (C) 2020 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial
{% include "common/generated_comment.cpp.tpl" %}
{% set interface_zoned = interface.tags.config and interface.tags.config.zoned %}

package io.qt.{{module|qml_type|lower}};

import java.util.Set;
import java.util.HashSet;

import android.os.Build;
import androidx.annotation.RequiresApi;

import android.car.VehiclePropertyIds;
import android.car.VehiclePropertyType;
{% if interface.tags.config_android_automotive and interface.tags.config_android_automotive.imports %}
{%  for import in interface.tags.config_android_automotive.imports %}
import {{import}};
{%  endfor %}
{% endif %}
import io.qt.androidautomotive.sensors.QtCarProperties;
import io.qt.androidautomotive.sensors.QtCarProperty;
import io.qt.androidautomotive.sensors.QtAreaId;
import static io.qt.{{module|qml_type|lower}}.{{interface}}Sensors.*;

{% macro add_area_flag(area) -%}
{% set flag = ""%}
{% if 'VehicleAreaWindow.' in area %}
{%   set flag = "| QtAreaId.AREA_WINDOW_ID"%}
{% elif 'VehicleAreaMirror.' in area %}
{%   set flag = "| QtAreaId.AREA_MIRROR_ID"%}
{% elif 'VehicleAreaSeat.' in area %}
{%   set flag = "| QtAreaId.AREA_SEAT_ID"%}
{% elif 'VehicleAreaWheel.' in area %}
{%   set flag = "| QtAreaId.AREA_WHEEL_ID"%}
{% elif 'VehicleAreaDoor.' in area %}
{%   set flag = "| QtAreaId.AREA_DOOR_ID"%}
{% endif%}
{{flag}}
{%- endmacro %}

@RequiresApi(Build.VERSION_CODES.Q)
public class {{interface}}Sensors {

    public static void initStatic() {
        // This method intentionally left empty
        // Called to force creation of static class members
    }
{% if interface.tags.config_android_automotive and interface.tags.config_android_automotive.zoneAliases %}
{%   for zoneAlias in interface.tags.config_android_automotive.zoneAliases %}
    public static final int {{zoneAlias}}{{add_area_flag(zoneAlias)}};
{%   endfor %}
{% endif %}

{% for property in interface.properties %}
{%  if property.tags.config_android_automotive %}
{%   set c = property.tags.config_android_automotive %}
{%   set property_zoned = c.zone and c.zone is iterable and c.zone is not string %}
{%    if c.vhalId %}
{%      if interface_zoned and property_zoned %}
{%        for zoneItem in c.zone: %}
    public static final QtCarProperty<{{property|java_object_type}}> {{c.vhalId}}_{{loop.index}} = QtCarProperties.registerSensor(
        "{{c.vhalId}}_{{loop.index}}", VehiclePropertyIds.{{c.vhalId}}, {{zoneItem}},
        VehiclePropertyType.{{property|vhal_type}},
        carPropertyValue -> ({{property|java_object_type}}) carPropertyValue.getValue(),
        {{property|java_object_type}}.class);
{%        endfor %}
{%      else %}
    public static final QtCarProperty<{{property|java_object_type}}> {{c.vhalId}} = QtCarProperties.registerSensor(
        "{{c.vhalId}}", VehiclePropertyIds.{{c.vhalId}}, {{c.zone}}{{add_area_flag(c.zone)}},
        VehiclePropertyType.{{property|vhal_type}},
        carPropertyValue -> ({{property|java_object_type}}) carPropertyValue.getValue(),
        {{property|java_object_type}}.class);
{%      endif %}
{%    endif %}
{%  endif %}
{% endfor %}

    public static synchronized Set<Integer> getPropertyIds() {
        Set<Integer> sensorProperties = new HashSet<>();
{% for property in interface.properties %}
{%   if property.tags.config_android_automotive %}
{%   set c = property.tags.config_android_automotive %}
        sensorProperties.add(VehiclePropertyIds.{{c.vhalId}});
{%   endif %}
{% endfor %}
        return sensorProperties;
    }
}
