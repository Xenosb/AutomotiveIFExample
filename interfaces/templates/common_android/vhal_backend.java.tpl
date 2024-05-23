// Copyright (C) 2022 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial
{% include "common/generated_comment.cpp.tpl" %}
{% set interface_zoned = interface.tags.config and interface.tags.config.zoned %}

package io.qt.{{module|qml_type|lower}};

// Modification

import android.annotation.SuppressLint;
import android.car.VehiclePropertyIds;
import android.util.Log;
import android.content.Context;
import android.content.pm.PackageManager;
import android.car.Car;
import android.content.ComponentName;
import android.content.Context;
import android.content.ServiceConnection;
import android.car.hardware.property.CarPropertyManager;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Handler;
import androidx.lifecycle.MutableLiveData;
import androidx.annotation.RequiresApi;
import java.util.List;
import java.util.Objects;
import java.lang.Runnable;


import io.qt.androidautomotive.manager.QtCarPropertyManagerProvider;
import io.qt.androidautomotive.sensors.QtCarPropertiesDataSource;
import io.qt.androidautomotive.sensors.QtCarProperties;
import io.qt.androidautomotive.sensors.QtCarProperty;
{% if interface_zoned %}
import io.qt.androidautomotive.sensors.QtAreaId;
{% endif %}
import io.qt.{{module|qml_type|lower}}.I{{interface}};
import io.qt.{{module|qml_type|lower}}.{{interface}};
import io.qt.{{module|qml_type|lower}}.{{interface}}Sensors;

import org.qtproject.qt.android.bindings.QtActivity;

@RequiresApi(Build.VERSION_CODES.Q)
public class {{interface}}Backend implements I{{interface}} {
    private static final String TAG = "{{interface}}Backend";
    private Context ctx = null;
    private Car car;
    private QtCarPropertiesDataSource carPropertiesDataSource = null;
    private QtCarPropertyManagerProvider carManagerProvider = null;
    private boolean initialized = false;

    @SuppressLint("LongLogTag")
    public {{interface}}Backend(Context owner) {
        ctx = owner;
        if (ctx == null) {
            Log.e(TAG, "Context(owner) is null, aborting");
            return;
        }
        if (ctx instanceof QtActivity) {
            ((QtActivity)ctx).runOnUiThread(new Runnable() {
                public void run() {
                    initialize();
                }
            });
        } else {
            initialize();
        }
    }

    private void initialize() {
        carPropertiesDataSource = QtCarPropertiesDataSource.getInstance();
        initCar();
    }

    @SuppressLint("LongLogTag")
    private void initCar() {
        if (ctx != null && ctx.getPackageManager().hasSystemFeature(PackageManager.FEATURE_AUTOMOTIVE)) {
            if (car != null && car.isConnected()) {
                car.disconnect();
                car = null;
            }
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
                car = Car.createCar(ctx);
                if (car != null) {
                    //setupDataSource indirecrtly calls observeForever
                    //that should be called from main thread
                    Handler handler = new Handler(ctx.getMainLooper());
                    handler.post(new Runnable() {
                        @Override
                        public void run () {
                           setupDataSource(car);
                        }
                    });
                } else {
                    Log.w(TAG, "Cannot connect to Car Service");
                }
            } else {
                car = Car.createCar(ctx, null, Car.CAR_WAIT_TIMEOUT_WAIT_FOREVER,
                        (Car car, boolean ready) -> {
                            if (ready)
                                setupDataSource(car);
                            else
                                Log.w(TAG, "Disconnected from Car Service");
                        });
            }
        } else {
            Log.e(TAG, "No PackageManager.FEATURE_AUTOMOTIVE, it's not Android Automotive System");
        }
    }

    private void setupDataSource(Car car) {
        carManagerProvider = new QtCarPropertyManagerProvider(car);
        CarPropertyManager carPropertyManager = carManagerProvider.getPropertyManager();
        carPropertiesDataSource.registerCarPropertyManagerCallback(carPropertyManager, {{interface}}Sensors.getPropertyIds());
        addDataSourceObservers();
        initialized = true;
    }

    private void addDataSourceObservers() {
{% for property in interface.properties %}
{%  if property.tags.config_android_automotive and property.tags.config_android_automotive.vhalId %}
{%    set c = property.tags.config_android_automotive %}
{%    set property_zoned = c.zone and c.zone is iterable and c.zone is not string %}
{%    if interface_zoned and property_zoned %}
{%      for zoneItem in c.zone: %}
        carPropertiesDataSource.getSensorMutableLiveData({{interface}}Sensors.{{c.vhalId}}_{{loop.index}}).observeForever(this::update{{property|upperfirst}}_{{loop.index}});
{%      endfor %}
{%    else %}
        carPropertiesDataSource.getSensorMutableLiveData({{interface}}Sensors.{{c.vhalId}}).observeForever(this::update{{property|upperfirst}});
{%    endif %}
{%  endif %}
{% endfor %}
    }

    public void removeDataSourceObservers() {
{% for property in interface.properties %}
{%  if property.tags.config_android_automotive and property.tags.config_android_automotive.vhalId %}
{%    set c = property.tags.config_android_automotive %}
{%    set property_zoned = c.zone and c.zone is iterable and c.zone is not string %}
{%    if interface_zoned and property_zoned %}
{%      for zoneItem in c.zone: %}
        carPropertiesDataSource.getSensorMutableLiveData({{interface}}Sensors.{{c.vhalId}}_{{loop.index}}).removeObserver(this::update{{property|upperfirst}}_{{loop.index}});
{%      endfor %}
{%    else %}
        carPropertiesDataSource.getSensorMutableLiveData({{interface}}Sensors.{{c.vhalId}}).removeObserver(this::update{{property|upperfirst}});
{%    endif %}
{%  endif %}
{% endfor %}
    }

{% for property in interface.properties %}
{%  if property.tags.config_android_automotive %}
{%   set c = property.tags.config_android_automotive %}
{%   set property_zoned = c.zone and c.zone is iterable and c.zone is not string %}
{%   if c.vhalId %}
    @SuppressLint("LongLogTag")
{%     if interface_zoned and property_zoned %}
    private void update{{property|upperfirst}}({{property|java_type}} {{property}}, int zoneId) {
{%     else %}
    private void update{{property|upperfirst}}({{property|java_type}} {{property}}) {
{%     endif %}
        try {
{%       if interface_zoned %}
{%         if not property_zoned %}
            int zoneId = {{interface}}Sensors.{{c.vhalId}}.mLogicalAreaId;
{%         endif %}
            {{interface}}.{{property}}Changed({{property}}, zoneId);
{%       else %}
            {{interface}}.{{property}}Changed({{property}});
{%       endif %}
        } catch (UnsatisfiedLinkError e) {
            Log.d(TAG, "NativeBackend not ready: {{property}}({{c.vhalId}})");
        }
    }
{%      if interface_zoned and property_zoned %}
{%        for zoneItem in c.zone: %}
    private void update{{property|upperfirst}}_{{loop.index}}({{property|java_type}} {{property}}) {
            update{{property|upperfirst}}({{property}}, {{interface}}Sensors.{{property.tags.config_android_automotive.vhalId}}_{{loop.index}}.mLogicalAreaId);
    }
{%        endfor %}
{%      endif %}

    @Override
{%     if interface_zoned %}
{%       if property_zoned %}
    @SuppressWarnings("unchecked")
    @SuppressLint("LongLogTag")
{%       endif %}
    public {{property|java_type}} {{property|getter_name}}(int zoneId) {
{%     else %}
    public {{property|java_type}} {{property|getter_name}}() {
{%     endif %}
        if (initialized) {
            try {
{%       if interface_zoned and property_zoned %}
                QtCarProperty<{{property|java_object_type}}> sensor = (QtCarProperty<{{property|java_object_type}}>)QtCarProperties
                                            .getInstance()
                                            .getSensorForPropertyId(VehiclePropertyIds.{{c.vhalId}},
                                                                    zoneId);
{%       else %}
                QtCarProperty<{{property|java_object_type}}> sensor = {{interface}}Sensors.{{c.vhalId}};
{%       endif %}
                MutableLiveData<{{property|java_object_type}}> mutableLiveData = carPropertiesDataSource
                                                                  .getSensorMutableLiveData(sensor);
                if (mutableLiveData == null)
                    throw new NullPointerException();
                if (mutableLiveData.getValue() != null) {
                    return mutableLiveData.getValue();
                } else {
                    CarPropertyManager carPropertyManager = carManagerProvider.getPropertyManager();
{%       set javaTypeForGetter = property|java_object_type %}
{%       if javaTypeForGetter == "Integer" %}
{%           set javaTypeForGetter = "Int" %}
{%       endif  %}
{%       if interface_zoned and property_zoned %}
                    return carPropertyManager
                            .get{{javaTypeForGetter}}Property(VehiclePropertyIds.{{c.vhalId}},
                                                zoneId & ~QtAreaId.AREA_MASK);
{%       else %}
                    return carPropertyManager
                            .get{{javaTypeForGetter}}Property(VehiclePropertyIds.{{c.vhalId}},
                                                QtCarProperties.GLOBAL_AREA_ID);
{%       endif %}
                }
            } catch (NullPointerException e) {
                Log.w(TAG, "{{property}}({{c.vhalId}}) property is not initialized");
            } catch (IllegalArgumentException e) {
                Log.e(TAG, "Illegal argument used to get the data for {{property}}({{c.vhalId}})");
                e.printStackTrace();
            } catch (IllegalStateException e) {
                Log.e(TAG, "Illegal Car Service state while getting the data for {{property}}({{c.vhalId}})");
                e.printStackTrace();
            } catch (SecurityException e) {
                Log.w(TAG, "{{property}}({{c.vhalId}}) property is not initialized: "
                            + e.getMessage());
            }
        }
        return {{property|java_default_value}};
    }
{%     if not property.readonly %}
    @Override
{%       if interface_zoned %}
    @SuppressWarnings("ConstantConditions")
    @SuppressLint("LongLogTag")
    public void set{{property|upperfirst}}(final {{property|java_type}} {{property}}, int zoneId) {
{%       else %}
    public void set{{property|upperfirst}}(final {{property|java_type}} {{property}}) {
{%       endif %}
        if (initialized) {
            try {
{%       if c.vhalId == 'FUEL_DOOR_OPEN' %}
                // QAA-785
                // Special case for {{c.vhalId}}
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
                    Log.e(TAG, "{{c.vhalId}} is not writable on Android 10 and earlier versions.");
                    return;
                }
{%       endif %}
{%        if interface_zoned and property_zoned %}
{%        set sensor_value_argument = 'Objects.requireNonNull(zonedSensor)' %}
{%        set property_value_argument = 'zonedSensor' %}
{%        set update_call_argument = 'sensorValue, zoneId' %}
                QtCarProperty<{{property|java_object_type}}> zonedSensor = (QtCarProperty<{{property|java_object_type}}>)QtCarProperties.getInstance().getSensorForPropertyId(VehiclePropertyIds.{{c.vhalId}}, zoneId);
{%        else %}
{%        set sensor_value_argument = '{0}Sensors.{1}'.format(interface, c.vhalId) %}
{%        set property_value_argument = '{0}Sensors.{1}'.format(interface, c.vhalId) %}
{%        set update_call_argument = 'sensorValue' %}
{%        endif %}
                carManagerProvider.setSensorValue({{sensor_value_argument}}, {{property}});

                // workaround for https://bugreports.qt.io/browse/QAA-134 - seems redundant on Android 11+
                {{property|java_object_type}} sensorValue = carManagerProvider.getPropertyValue({{property_value_argument}});
                MutableLiveData<{{property|java_object_type}}> mutableLiveData = carPropertiesDataSource.getSensorMutableLiveData({{sensor_value_argument}});
                if (sensorValue == {{property}} && mutableLiveData != null && mutableLiveData.getValue() != sensorValue)
                     mutableLiveData.postValue(sensorValue);
                else if(sensorValue == null)
                    throw new NullPointerException();
            } catch (NullPointerException e) {
                Log.e(TAG, "Cannot set property value for {{property}}({{c.vhalId}}), retrieved value is null.");
            } catch (IllegalArgumentException e) {
                Log.e(TAG, "Cannot set property value for {{property}}({{c.vhalId}}), illegal argument was used.");
                e.printStackTrace();
            } catch (IllegalStateException e) {
                Log.e(TAG, "Cannot set property value for {{property}}({{c.vhalId}}), illegal state of the Car Service.");
                e.printStackTrace();
            } catch (RuntimeException e) {
                Log.e(TAG, "Cannot set property value for {{property}}({{c.vhalId}}).");
                e.printStackTrace();
            }
        }
    }
{%     endif %}
{%    endif %}
{%  endif %}
{% endfor %}
}
