<template>
  <div id="app">
    <div v-if="loggedIn && loaded" id="nav">
      <Nav v-on:logout="logout" />
      <omni-search />
    </div>
    <div v-if="!loggedIn && loaded" id="nav">
      <session v-on:login="login" v-on:login-error="loginError" />
    </div>
  </div>
</template>

<script>
  import Session from './components/session/NewSession'
  import OmniSearch from './components/shared/OmniSearch'
  import Nav from './components/nav/Nav'

  export default {
    name: 'App',
    components: {
      Session,
      OmniSearch,
      Nav
    },
    methods: {
      login: function () {
        this.loggedIn = true
      },
      logout: function () {
        this.loggedIn = false
        window.location.href = '/'
      },
      loginError: function () {
        console.info('LOGIN FAILED')
      }
    },
    mounted() {
      let url = '/sessions'

      this.$http.get(url)
        .then(resp => {
          if (resp.status == 200) {
            this.user = resp.data
            this.loggedIn = true
            console.log('vue logged in')
          }
        })
        .catch(err => {
          if (err.response.status === 401) console.info(err.response.statusText)
        })
        .finally(() => {
          this.loaded = true
        })
    },
    data() {
      return {
        loaded: false, // page has loaded and session has been checked
        loggedIn: null,
        user: null,
        unauthorized: false
      }
    }
  }

</script>
<style src="./assets/css/tailwind.css"></style>
<style src="./assets/css/custom.css"></style>
