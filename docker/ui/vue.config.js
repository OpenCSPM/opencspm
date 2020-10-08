// vue.config.js
// prevent loading unnecessary amChart libraries
// https://www.amcharts.com/docs/v4/tutorials/preventing-vue-js-from-loading-external-libraries/
module.exports = {
  chainWebpack: config => {
    config.plugin('prefetch').tap(args => {
      return [
        {
          rel: 'prefetch',
          include: 'asyncChunks',
          fileBlacklist: [
            /pdfmake\.[^.]+\.js$/,
            /xlsx\.[^.]+\.js$/,
            /fabric[^.]*\.[^.]+\.js$/,
            /responsivedefaults\.[^.]+\.js$/
          ]
        }
      ]
    })
  }
}
