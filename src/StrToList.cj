package lab3

import std.collection.*

class StrToList {
    public static func part(str: String): (String, ArrayList<ArrayList<String>>) {
        let result = ArrayList<ArrayList<String>>()
        var beginBody = false
        var head: String = "?"
        let temp = ArrayList<String>()
        let strRuneArray = str.toRuneArray()
        for(c in strRuneArray) {
            // 滤掉空格
            if(c == r" ") {
                continue
            }
            if(!beginBody) {
                // 开始读取体的标志
                if(c == r">") {
                    beginBody = true
                }
                // 读到产生式的头
                else if(c != r"-") {
                    head = String(c)
                }
                // 否则读到r"-"，忽略
                continue
            }
            else{
                // println("??? " + String(c))
                if(c == r"|") {
                    // println("temp = " + temp.toString())
                    result.add(temp.clone())
                    temp.clear()
                }
                else {
                    temp.add(String(c))
                }
            }
        }
        return (head, result)
    }
}