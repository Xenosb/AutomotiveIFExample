#!/usr/bin/env python3
# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial
import inspect

from qface.idl.domain import Module, Interface, Property, Parameter, Field, Struct
from qface.helper.generic import lower_first, upper_first
from qface.helper.qtcpp import Filters

from generator.global_functions import jinja_error, jinja_warning
from generator.filters import deprecated_filter

def  jni_signature_type(symbol):
    """
    Return the Java VM’s representation of type signatures for property
    """
    prefix = Filters.classPrefix

    if symbol.type.is_string:
        return 'Ljava/lang/String'
    if symbol.type.is_int or symbol.type.is_enum or symbol.type.is_flag:
        return 'I'
    if symbol.type.is_bool:
        return 'Z'
    if symbol.type.is_real:
        return 'F'
    if symbol.type.is_list:
        if symbol.type.nested.is_int or symbol.type.nested.is_enum or symbol.type.nested.is_flag:
            return '[I'
        if symbol.type.nested.is_real:
            return '[F'
    jinja_error('return_type: Unknown symbol {0} of type {1}'.format(symbol, symbol.type))

def jni_type(symbol):
    """
    Return the native equivalent of java primitive type for property
    """
    prefix = Filters.classPrefix

    if symbol.type.is_string:
        return 'jstring'
    if symbol.type.is_int or symbol.type.is_enum or symbol.type.is_flag:
        return 'jint'
    if symbol.type.is_bool:
        return 'jboolean'
    if symbol.type.is_real:
        return 'jfloat'
    if symbol.type.is_list:
        if symbol.type.nested.is_int or symbol.type.nested.is_enum or symbol.type.nested.is_flag:
            return 'jintArray'
        if symbol.type.nested.is_real:
            return 'jfloatArray'
    jinja_error('return_type: Unknown symbol {0} of type {1}'.format(symbol, symbol.type))

def java_type(symbol):
    """
    Return the java primitive type for property
    """
    prefix = Filters.classPrefix

    if symbol.type.is_string:
        return 'String'
    if symbol.type.is_int or symbol.type.is_enum or symbol.type.is_flag:
        return 'int'
    if symbol.type.is_bool:
        return 'boolean'
    if symbol.type.is_real:
        return 'float'
    if symbol.type.is_list:
        if symbol.type.nested.is_int or symbol.type.nested.is_enum or symbol.type.nested.is_flag:
            return 'int[]'
        if symbol.type.nested.is_real:
            return 'float[]'
    jinja_error('return_type: Unknown symbol {0} of type {1}'.format(symbol, symbol.type))

def java_object_type(symbol):
    """
    Return the java object type for property used with vhal types
    """
    prefix = Filters.classPrefix
    if symbol.type.is_string:
        return 'String'
    if symbol.type.is_int or symbol.type.is_enum or symbol.type.is_flag:
        return 'Integer'
    if symbol.type.is_bool:
        return 'Boolean'
    if symbol.type.is_real:
        return 'Float'
    if symbol.type.is_list:
        if symbol.type.nested.is_int or symbol.type.nested.is_enum or symbol.type.nested.is_flag:
            return 'Integer[]'
        if symbol.type.nested.is_real:
            return 'Float[]'
    jinja_error('return_type: Unknown symbol {0} of type {1}'.format(symbol, symbol.type))

def java_default_value(symbol):
    """
    Return default value for property based on primitive type
    """
    prefix = Filters.classPrefix

    if symbol.type.is_string:
        return '""'
    if symbol.type.is_int or symbol.type.is_enum or symbol.type.is_flag:
        return '0'
    if symbol.type.is_bool:
        return 'false'
    if symbol.type.is_real:
        return '0.0f'
    if symbol.type.is_list:
        if symbol.type.nested.is_int or symbol.type.nested.is_enum or symbol.type.nested.is_flag:
            return 'new int[0]'
        if symbol.type.nested.is_real:
            return 'new float[0]'
    jinja_error('return_type: Unknown symbol {0} of type {1}'.format(symbol, symbol.type))

def vhal_type(symbol):
    """
    Return the vhal type for property
    """
    prefix = Filters.classPrefix
    if symbol.type.is_string:
        return 'STRING'
    if symbol.type.is_int or symbol.type.is_enum or symbol.type.is_flag:
        return 'INT32'
    if symbol.type.is_bool:
        return 'BOOLEAN'
    if symbol.type.is_real:
        return 'FLOAT'
    if symbol.type.is_list:
        if symbol.type.nested.is_int or symbol.type.nested.is_enum or symbol.type.nested.is_flag:
            return 'INT32_VEC'
        if symbol.type.nested.is_real:
            return 'FLOAT_VEC'
    jinja_error('return_type: Unknown symbol {0} of type {1}'.format(symbol, symbol.type))

def module_name_signature(symbol):
    """
    Return module name converted to the form used in package names
    """
    prefix = Filters.classPrefix

    s = str(symbol)
    if s.startswith('QtIfAndroid'):
        return (s[len('QtIfAndroid'):]).lower()
    jinja_error('return_type: Unknown symbol {0} of type {1}. Expected string type'.format(symbol, symbol.type))

filters['jni_type'] = jni_type
filters['java_type'] = java_type
filters['java_object_type'] = java_object_type
filters['jni_signature_type'] =  jni_signature_type
filters['java_default_value'] = java_default_value
filters['vhal_type'] = vhal_type
filters['module_name_signature'] = module_name_signature
