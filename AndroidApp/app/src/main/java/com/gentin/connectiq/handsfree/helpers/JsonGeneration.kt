package com.gentin.connectiq.handsfree.helpers

import com.fasterxml.jackson.module.kotlin.jacksonObjectMapper
import kotlinx.serialization.json.Json


val mapper = jacksonObjectMapper()

inline fun <reified T> pojoMap(o: T): Any {
    val string = Json.encodeToString(o)
    return mapper.readValue(string, Map::class.java)
}
