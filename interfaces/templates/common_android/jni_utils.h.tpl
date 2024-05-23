// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial
{% include "common/generated_comment.cpp.tpl" %}

#ifndef JNI_UTILS_H
#define JNI_UTILS_H

#include <QVariantList>
#include <QJniEnvironment>

{{ module|begin_namespace }}

class JniUtils
{
public:
    static QVariantList fromJniArrayToVariantList(jintArray jarray);
    static jintArray fromVariantListToJniArray(QVariantList variantList);

private:
    JniUtils() {};
};

{{ module|end_namespace }}

#endif // JNI_UTILS_H
