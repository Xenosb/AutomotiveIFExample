// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial
{% include "common/generated_comment.cpp.tpl" %}

#include "jniutils.h"

{{ module|begin_namespace }}

QVariantList JniUtils::fromJniArrayToVariantList(jintArray jarray)
{
    QJniEnvironment env;
    const int size = env->GetArrayLength(jarray);
    std::unique_ptr<jint[]> array(new jint[size]);
    env->GetIntArrayRegion(jarray, 0, size, array.get());
    env.checkAndClearExceptions(QJniEnvironment::OutputMode::Silent);

    QVariantList result;
    for (int i = 0; i < size; ++i)
        result.append(array[i]);

    return result;
}

jintArray JniUtils::fromVariantListToJniArray(QVariantList variantList)
{
    QJniEnvironment env;
    const int size = variantList.size();
    jintArray result = env->NewIntArray(size);
    if (!result)
        return nullptr;

    std::unique_ptr<jint[]> array(new jint[size]);
    for (int i = 0; i < size; ++i)
        array[i] = variantList.at(i).toInt();

    env->SetIntArrayRegion(result, 0, size, array.get());
    env.checkAndClearExceptions(QJniEnvironment::OutputMode::Silent);

    return result;
}

{{ module|end_namespace }}
