const path = require("path");
const utils = require('./webpack/utils')
const configs = require('./webpack/configs')
const webpack = require('webpack')
const merge = require('webpack-merge')
const vueLoaderConfig = require('./webpack/vue-loader.conf')
const HtmlWebpackPlugin = require('html-webpack-plugin')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')
const VueLoaderPlugin = require('vue-loader/lib/plugin')
const env = require('./webpack/prod.env')
const TerserPlugin = require("terser-webpack-plugin");
const dfxJson = require("./dfx.json");

function resolve(dir) {
    return path.join(__dirname, dir)
}

// List of all aliases for canisters. This creates the module alias for
// the `import ... from "ic:canisters/xyz"` where xyz is the name of a
// canister.
const aliases = Object.entries(dfxJson.canisters)
    .reduce((acc, [name, value]) => {
        // Get the network name, or `local` by default.
        const networkName = process.env["DFX_NETWORK"] || "local";
        const outputRoot = path.join(
            __dirname,
            ".dfx",
            networkName,
            "canisters",
            name
        );
        return {
            ...acc,
            ["ic:canisters/" + name]: path.join(outputRoot, name + ".js"),
            ["ic:idl/" + name]: path.join(outputRoot, name + ".did.js"),
            "vue$": "vue/dist/vue.esm.js",
            "@": resolve("src"),
        };
    }, {
        // This will later point to the userlib from npm, when we publish the userlib.
        "ic:userlib": path.join(
            process.env["HOME"],
            ".cache/dfinity/versions",
            dfxJson.dfx || process.env["DFX_VERSION"],
            "js-user-library/dist/lib.prod.js",
        ),
    });

/**
 * Generate a webpack configuration for a canister.
 */
function generateWebpackConfigForCanister(name, info) {
    if (typeof info.frontend !== 'object') {
        return;
    }

    const inputRoot = __dirname;

    return {
        mode: 'production',
        entry: {
            index: path.join(inputRoot, info.frontend.entrypoint),
        },
        devtool: configs.build.productionSourceMap ? '#source-map' : false,
        resolve: {
            extensions: ['.js', '.vue', '.json'],
            alias: aliases,
        },
        output: {
            // filename: utils.assetsPath('js/[name].[chunkhash].js'),
            // chunkFilename: utils.assetsPath('js/[id].[chunkhash].js'),
            filename: '[name].js',
            chunkFilename: '[id].js',
            path: path.join(__dirname, "dist", name),
            publicPath: './',
        },
        module: {
            rules: [{
                    test: /\.vue$/,
                    loader: 'vue-loader',
                    options: vueLoaderConfig
                },
                {
                    test: /\.js$/,
                    loader: 'babel-loader',
                    include: [resolve('src'), resolve('test'), resolve('node_modules/webpack-dev-server/client')],
                    options: {
                        //"babelrc": false,
                        "plugins": [
                            "dynamic-import-webpack"
                        ]
                    }
                },
                {
                    test: /\.(png|jpe?g|gif|svg)(\?.*)?$/,
                    loader: 'url-loader',
                    options: {
                        limit: 100000, //10000
                        name: 'img/[name].[ext]'
                            //name: 'img/[name].[hash:7].[ext]'
                    }
                },
                {
                    test: /\.(mp4|webm|ogg|mp3|wav|flac|aac)(\?.*)?$/,
                    loader: 'url-loader',
                    options: {
                        limit: 100000, //10000
                        name: 'media/[name].[ext]'
                            //name: 'media/[name].[hash:7].[ext]'
                    }
                },
                {
                    test: /\.(woff2?|eot|ttf|otf)(\?.*)?$/,
                    loader: 'url-loader',
                    options: {
                        //limit: 100000, //10000
                        name: 'fonts/[name].[ext]'
                            //name: 'fonts/[name].[hash:7].[ext]'
                    }
                }
            ]
        },
        plugins: [
            new HtmlWebpackPlugin({
                filename: path.resolve(__dirname, './dist/nnsexplorer_assets/index.html'),
                template: './src/nnsexplorer_assets/public/index.html',
                inject: true,
                minify: {
                    removeComments: true,
                    collapseWhitespace: true,
                    removeAttributeQuotes: true
                },
                chunksSortMode: 'none'
            }),
            new VueLoaderPlugin(),
            new webpack.DefinePlugin({
                'process.env': env,
            }),
            new MiniCssExtractPlugin({
                // filename: utils.assetsPath('css/[name].[hash].css'),
                // chunkFilename: utils.assetsPath('css/[id].[hash].css'),
                filename: '[name].css',
                chunkFilename: '[id].css',
            }),
            new webpack.HashedModuleIdsPlugin(),
        ],
        optimization: {
            minimize: true,
            minimizer: [
                new TerserPlugin({
                    warningsFilter: () => false,
                    sourceMap: true, //configs.build.productionSourceMap,
                    parallel: true,
                }),
                // new OptimizeCSSPlugin({
                //     cssProcessorOptions: { safe: true, map: { inline: false } }
                // }),
            ],
            // splitChunks: {
            //     chunks: "async",
            //     minSize: 30000,
            //     maxSize: 0,
            //     minChunks: 1,
            //     maxAsyncRequests: 5,
            //     maxInitialRequests: 3,
            //     automaticNameDelimiter: '~',
            //     automaticNameMaxLength: 30,
            //     name: true,
            //     cacheGroups: {
            //         default: {
            //             minChunks: 2,
            //             priority: -20,
            //             reuseExistingChunk: true
            //         },
            //         vendors: {
            //             test: /[\\/]node_modules[\\/]/,
            //             priority: -10
            //         }
            //     }
            // },
            // runtimeChunk: {
            //     name: "runtime"
            // }
        }
    };
}

// If you have additional webpack configurations you want to build
//  as part of this configuration, add them to the section below.
module.exports = [
    ...Object.entries(dfxJson.canisters).map(([name, info]) => {
        if (typeof info.frontend !== 'object') {
            return generateWebpackConfigForCanister(name, info)
        }

        return merge(generateWebpackConfigForCanister(name, info), {
            mode: 'production',
            module: {
                rules: utils.styleLoaders({
                    sourceMap: configs.build.productionSourceMap,
                    extract: true
                })
            }
        });
    }).filter((x) => !!x),
];