package com.gentin.connectiq.handsfree.helpers

import com.fasterxml.jackson.module.kotlin.jacksonObjectMapper


val mapper = jacksonObjectMapper()

inline fun <reified T> pojoMap(o: T): Any {
    return mapper.convertValue(o, Map::class.java)
}

inline fun <reified T> pojoList(o: T): Any {
    return mapper.convertValue(o, List::class.java)
}
