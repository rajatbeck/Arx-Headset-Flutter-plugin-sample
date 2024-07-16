package com.example.arx_headset_plugin

import org.json.JSONObject

enum class ResolutionObj(val width: Int, val height: Int, val frameRate: Int = 30) {
    _640x480(640, 480),
    _800x600(800, 600),
    _1280x720(1280, 720),
    _1280x1024(1280, 1024),
    _1920x1080(1920, 1080),
    _2048x1536(2048, 1536, 20),
    _2592x1944(2592, 1944, 20),
    _3264x2448(3264, 2448, 15);

    fun toJson(): String {
        val jsonObject = JSONObject()
        jsonObject.put("name", name)
        jsonObject.put("width", width)
        jsonObject.put("height", height)
        jsonObject.put("frameRate", frameRate)
        return jsonObject.toString()
    }

    companion object {
        fun fromJson(json: String): ResolutionObj? {
            val jsonObject = JSONObject(json)
            val name = jsonObject.getString("name")
            return values().find { it.name == name }
        }
    }
}