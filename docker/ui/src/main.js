import Vue from 'vue'
import App from './App.vue'
import router from './router'
import axios from 'axios'

Vue.config.productionTip = false

// api url
// customize for self-hosted environment
const API_BASE_URL =
  process.env.NODE_ENV === 'production' ? 'http://localhost:5000/api' : 'http://localhost:5000/api'

// base url for oauth links
// customize for self-hosted environment
Vue.prototype.BASE_URL =
  process.env.NODE_ENV === 'production' ? 'https://auth.opencspm.org' : 'http://localhost:5000'

// axios defaults
axios.defaults.baseURL = API_BASE_URL
axios.defaults.withCredentials = true
axios.defaults.xsrfCookieName = '_opencspm_token'
axios.defaults.xsrfHeaderName = 'x-csrf-token'

Vue.prototype.$http = axios

new Vue({
  router,
  render: h => h(App)
}).$mount('#app')
