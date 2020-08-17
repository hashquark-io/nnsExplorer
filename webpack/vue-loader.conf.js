'use strict'
const utils = require('./utils')
const configs = require('./configs')
const isProduction = true
const sourceMapEnabled = configs.build.productionSourceMap

module.exports = {
    loaders: utils.cssLoaders({
        sourceMap: sourceMapEnabled,
        extract: isProduction
    }),
    // cssSourceMap: sourceMapEnabled,
    // cacheBusting: true,
    // transformToRequire: {
    //     video: ['src', 'poster'],
    //     source: 'src',
    //     img: 'src',
    //     image: 'xlink:href'
    // }
}