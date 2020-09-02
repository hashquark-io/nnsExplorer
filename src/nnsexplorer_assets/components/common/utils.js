// 格式化时间： parseTime(time, '{y}{m}{d}')

import Vue from 'vue'
import Big from 'big.js'
import echarts from 'echarts'

export function parseTime(time, cFormat) {
    if (arguments.length === 0) {
        return null
    }
    const format = cFormat || '{y}-{m}-{d} {h}:{i}:{s}'
    let date
    if (typeof time === 'object') {
        date = time
    } else {
        if (('' + time).length === 10) time = parseInt(time) * 1000
        date = new Date(time)
    }
    const formatObj = {
        y: date.getFullYear(),
        m: date.getMonth() + 1,
        d: date.getDate(),
        h: date.getHours(),
        i: date.getMinutes(),
        s: date.getSeconds(),
        a: date.getDay(),
    }
    const time_str = format.replace(/{(y|m|d|h|i|s|a)+}/g, (result, key) => {
        let value = formatObj[key]
        if (key === 'a') return ['一', '二', '三', '四', '五', '六', '日'][value - 1]
        if (result.length > 0 && value < 10) {
            value = '0' + value
        }
        return value || 0
    })
    return time_str
}

export function formatTime(time, option) {
    time = +time * 1000
    const d = new Date(time)
    const now = Date.now()

    const diff = (now - d) / 1000

    if (diff < 30) {
        return '刚刚'
    } else if (diff < 3600) {
        // less 1 hour
        return Math.ceil(diff / 60) + '分钟前'
    } else if (diff < 3600 * 24) {
        return Math.ceil(diff / 3600) + '小时前'
    } else if (diff < 3600 * 24 * 2) {
        return '1天前'
    }
    if (option) {
        return parseTime(time, option)
    } else {
        return d.getMonth() + 1 + '月' + d.getDate() + '日' + d.getHours() + '时' + d.getMinutes() + '分'
    }
}

// 格式化时间
export function getQueryObject(url) {
    url = url == null ? window.location.href : url
    const search = url.substring(url.lastIndexOf('?') + 1)
    const obj = {}
    const reg = /([^?&=]+)=([^?&=]*)/g
    search.replace(reg, (rs, $1, $2) => {
        const name = decodeURIComponent($1)
        let val = decodeURIComponent($2)
        val = String(val)
        obj[name] = val
        return rs
    })
    return obj
}

/**
 *get getByteLen
 * @param {Sting} val input value
 * @returns {number} output value
 */
export function getByteLen(val) {
    let len = 0
    for (let i = 0; i < val.length; i++) {
        if (val[i].match(/[^\x00-\xff]/gi) != null) {
            len += 1
        } else {
            len += 0.5
        }
    }
    return Math.floor(len)
}

export function cleanArray(actual) {
    const newArray = []
    for (let i = 0; i < actual.length; i++) {
        if (actual[i]) {
            newArray.push(actual[i])
        }
    }
    return newArray
}

export function param(json) {
    if (!json) return ''
    return cleanArray(
        Object.keys(json).map((key) => {
            if (json[key] === undefined) return ''
            return encodeURIComponent(key) + '=' + encodeURIComponent(json[key])
        })
    ).join('&')
}

export function param2Obj(url) {
    const search = url.split('?')[1]
    if (!search) {
        return {}
    }
    return JSON.parse(
        '{"' + decodeURIComponent(search).replace(/"/g, '\\"').replace(/&/g, '","').replace(/=/g, '":"') + '"}'
    )
}

export function html2Text(val) {
    const div = document.createElement('div')
    div.innerHTML = val
    return div.textContent || div.innerText
}

export function objectMerge(target, source) {
    /* Merges two  objects,
       giving the last one precedence */

    if (typeof target !== 'object') {
        target = {}
    }
    if (Array.isArray(source)) {
        return source.slice()
    }
    Object.keys(source).forEach((property) => {
        const sourceProperty = source[property]
        if (typeof sourceProperty === 'object') {
            target[property] = objectMerge(target[property], sourceProperty)
        } else {
            target[property] = sourceProperty
        }
    })
    return target
}

export function scrollTo(element, to, duration) {
    if (duration <= 0) return
    const difference = to - element.scrollTop
    const perTick = (difference / duration) * 10
    setTimeout(() => {
        element.scrollTop = element.scrollTop + perTick
        if (element.scrollTop === to) return
        scrollTo(element, to, duration - 10)
    }, 10)
}

export function toggleClass(element, className) {
    if (!element || !className) {
        return
    }
    let classString = element.className
    const nameIndex = classString.indexOf(className)
    if (nameIndex === -1) {
        classString += '' + className
    } else {
        classString = classString.substr(0, nameIndex) + classString.substr(nameIndex + className.length)
    }
    element.className = classString
}

export const pickerOptions = {
    shortcuts: [{
            text: '今天',
            onClick(picker) {
                const end = new Date()
                const start = new Date(new Date().toDateString())
                end.setTime(start.getTime())
                picker.$emit('pick', [start, end])
            },
        },
        {
            text: '最近一周',
            onClick(picker) {
                const end = new Date(new Date().toDateString())
                const start = new Date()
                start.setTime(end.getTime() - 3600 * 1000 * 24 * 7)
                picker.$emit('pick', [start, end])
            },
        },
        {
            text: '最近一个月',
            onClick(picker) {
                const end = new Date(new Date().toDateString())
                const start = new Date()
                start.setTime(start.getTime() - 3600 * 1000 * 24 * 30)
                picker.$emit('pick', [start, end])
            },
        },
        {
            text: '最近三个月',
            onClick(picker) {
                const end = new Date(new Date().toDateString())
                const start = new Date()
                start.setTime(start.getTime() - 3600 * 1000 * 24 * 90)
                picker.$emit('pick', [start, end])
            },
        },
    ],
}

export function getTime(type) {
    if (type === 'start') {
        return new Date().getTime() - 3600 * 1000 * 24 * 90
    } else {
        return new Date(new Date().toDateString())
    }
}

export function debounce(func, wait, immediate) {
    let timeout, args, context, timestamp, result

    const later = function() {
        // 据上一次触发时间间隔
        const last = +new Date() - timestamp

        // 上次被包装函数被调用时间间隔last小于设定时间间隔wait
        if (last < wait && last > 0) {
            timeout = setTimeout(later, wait - last)
        } else {
            timeout = null
                // 如果设定为immediate===true，因为开始边界已经调用过了此处无需调用
            if (!immediate) {
                result = func.apply(context, args)
                if (!timeout) context = args = null
            }
        }
    }

    return function(...args) {
        context = this
        timestamp = +new Date()
        const callNow = immediate && !timeout
            // 如果延时不存在，重新设定延时
        if (!timeout) timeout = setTimeout(later, wait)
        if (callNow) {
            result = func.apply(context, args)
            context = args = null
        }

        return result
    }
}

export function deepClone(source) {
    if (!source && typeof source !== 'object') {
        throw new Error('error arguments', 'shallowClone')
    }
    const targetObj =
        source.constructor === Array ? [] : source.constructor === Date ? new Date(new Date(source).valueOf()) : {}
    Object.keys(source).forEach((keys) => {
        if (source[keys] && typeof source[keys] === 'object') {
            targetObj[keys] =
                source[keys].constructor === Array ? [] :
                source[keys].constructor === Date ?
                new Date(new Date(source).valueOf()) : {}
            targetObj[keys] = deepClone(source[keys])
        } else {
            targetObj[keys] = source[keys]
        }
    })
    return targetObj
}

export function createUniqueString() {
    const timestamp = +new Date() + ''
    const randomNum = parseInt((1 + Math.random()) * 65536) + ''
    return (+(randomNum + timestamp)).toString(32)
}

function pluralize(time, label) {
    if (time === 1) {
        return time + label
    }
    return time + label + 's'
}

export function timeAgo(time) {
    const between = Date.now() / 1000 - Number(time)
    if (between < 3600) {
        return pluralize(~~(between / 60), ' minute')
    } else if (between < 86400) {
        return pluralize(~~(between / 3600), ' hour')
    } else {
        return pluralize(~~(between / 86400), ' day')
    }
}

/* 数字 格式化*/
export function nFormatter(num, digits) {
    const si = [{
            value: 1e18,
            symbol: 'E',
        },
        {
            value: 1e15,
            symbol: 'P',
        },
        {
            value: 1e12,
            symbol: 'T',
        },
        {
            value: 1e9,
            symbol: 'G',
        },
        {
            value: 1e6,
            symbol: 'M',
        },
        {
            value: 1e3,
            symbol: 'k',
        },
    ]
    for (let i = 0; i < si.length; i++) {
        if (num >= si[i].value) {
            return (num / si[i].value + 0.1).toFixed(digits).replace(/\.0+$|(\.[0-9]*[1-9])0+$/, '$1') + si[i].symbol
        }
    }
    return num.toString()
}

export function toThousandslsFilter(num) {
    return (+num || 0).toString().replace(/^-?\d+/g, (m) => m.replace(/(?=(?!\b)(\d{3})+$)/g, ','))
}

// 仅限输入数字
export function onlyNumberInput(val) {
    if (event.keyCode != 37 && event.keyCode != 39) {
        val = val.replace(/^(-?\d+)(\.\d+)?$/g, '')
    } else {
        return val
    }
}

// 去除对象中为空的值
export function deleteNullAttribute(obj) {
    if (typeof obj === 'object') {
        let req = deepClone(obj)
        for (let prop in req) {
            if (req[prop] === '' || req[prop] === null || req[prop] === undefined) {
                delete req[prop]
            }
        }
        return req
    } else {
        // console.log('not an object !!!');
    }
}

// 表格数据补齐8位小数
export function turnFixedList(list = [{}], n = 8) {
    if (!Array.isArray(list)) {
        return []
    }
    list.forEach((obj) => {
        for (let key in obj) {
            let escapeList = ['phoneNo', 'txTypeDesc', 'status', 'id', 'day']
            let escapeIndex = escapeList.findIndex((v) => v === key || ~key.toLowerCase().indexOf(v))
            if (~escapeIndex) continue
            const v = obj[key]
            if (v && !isNaN(Number(v))) {
                obj[key] = Number(v).toFixed(n)
            }
        }
    })
    return list
}

function format(num) {
    var reg = /\d{1,3}(?=(\d{3})+$)/g
    return `${num}`.replace(reg, '$&,')
}
// 加上千分位
export const thousandth = (v, num) => {
    if (isNaN(+v)) return
    if (v == 0) return Big(v).toFixed(num)
    let val
    if (num) {
        val = (parseInt(v * Math.pow(10, num)) / Math.pow(10, num)).toFixed(num)
    } else {
        val = Big(v).toFixed()
    }
    const [left, right] = `${val}`.split('.')
    v = right ? [format(left), right].join('.') : format(left)
    return v
}

Vue.prototype.thousandth = thousandth

export const Mathfloor = (v, num = 2) => {
    if (isNaN(+v)) return
    return (parseInt(v * Math.pow(10, num)) / Math.pow(10, num)).toFixed(num)
}
Vue.prototype.Mathfloor = Mathfloor

export function initChart({
    data,
    dataOpt = {
        xAxis: '',
        dataKey: {
            y1: [],
            y2: [],
            y1MinZero: true,
            y2MinZero: true,
        },
        format: {},
        legend: [],
    },
    dom,
    chartOpt,
}) {
    dataOpt.format = dataOpt.format || {}
    const option = deepClone(chartOpt)
    option.legend.data = Object.values(dataOpt.legend)
    option.xAxis.data = data.map((t) => {
        const { xAxis, format } = dataOpt
        return format[xAxis] ? format[xAxis](t[xAxis]) : t[xAxis]
    })

    const y1Datas = dataOpt && dataOpt.dataKey && dataOpt.dataKey.y1.map((key) =>
        data.map((t) => {
            return dataOpt.format[key] ? dataOpt.format[key](t[key]) : t[key]
        })
    )
    const y2Datas = dataOpt && dataOpt.dataKey && dataOpt.dataKey.y2.map((key) =>
        data.map((t) => {
            return dataOpt.format[key] ? dataOpt.format[key](t[key]) : t[key]
        })
    )
    if (data.length >= 1) {
        y1Datas && calcMaxMin(y1Datas.flat(), option, 0, dataOpt && dataOpt.dataKey && dataOpt.dataKey.y1MinZero)
        y2Datas && calcMaxMin(y2Datas.flat(), option, 1, dataOpt && dataOpt.dataKey && dataOpt.dataKey.y2MinZero)
    }
    const allData = [...(y1Datas || []), ...(y2Datas || [])]
    option.series.forEach((t, i) => {
        t.data = allData[i]
        t.name = dataOpt.legend[i]
        option.legend.data[i] = allData[i].every((t) => t === undefined) ? '' : option.legend.data[i]
    })
    const chartIns = echarts.init(dom)
    chartIns.setOption(option)
    return chartIns
}

function calcMaxMin(data, option, ind, yMinZero) {
    yMinZero = yMinZero === undefined ? true : yMinZero
    if (data.every((t) => t === undefined || t === null)) return
    const max = Math.max(...data.filter((t) => t !== undefined && t !== null).map((j) => j.value || j))
    const min = Math.min(...data.filter((t) => t !== undefined && t !== null).map((j) => j.value || j))

    const interval = (max - min) / 3
    if (Math.abs(interval) > 0 && min - interval > 0) {
        option.yAxis[ind].min = min - interval
        option.yAxis[ind].max = max + interval
        option.yAxis[ind].interval = interval
        return
    }

    if (min - interval < 0) {
        if (yMinZero) {
            option.yAxis[ind].min = 0
            option.yAxis[ind].max = max + max / 4
            option.yAxis[ind].interval = max / 4
        } else {
            option.yAxis[ind].min = min - interval
            option.yAxis[ind].max = max + interval
            option.yAxis[ind].interval = interval
        }
        return
    }

    if (interval === 0) {
        if (min === 0 && max === 0) {
            option.yAxis[ind].min = 0
            option.yAxis[ind].max = 5
            option.yAxis[ind].interval = 1
        } else {
            const val = max
            option.yAxis[ind].min = 0
            option.yAxis[ind].max = +val + val / 4
            option.yAxis[ind].interval = val / 4
        }
        return
    }
}