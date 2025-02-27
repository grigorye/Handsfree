#! /usr/bin/env kotlin
@file:DependsOn("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.3")

import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.addJsonObject
import kotlinx.serialization.json.buildJsonArray
import kotlinx.serialization.json.buildJsonObject
import java.io.File

val path = args[0]
val file = File(path)
val text = file.readText()

val keyPrefix = file.nameWithoutExtension.lowercase()

val json = buildJsonArray {
    for (match in "\\[(.*)\\]\\((lk:([^)]*))\\)".toRegex().findAll(text)) {
        val rawKey = match.groupValues[3]
        val key = keyPrefix + "_" + rawKey
        val value = match.groupValues[1]
        addJsonObject {
            put("term", JsonPrimitive(key))
            put("translation", buildJsonObject {
                put("content", JsonPrimitive(value))
            })
        }
    }
}

print(json)
