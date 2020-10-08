<template>
  <div class="h-screen flex overflow-hidden bg-gray-100">
    <!-- Static sidebar for desktop -->
    <div class="hidden md:flex md:flex-shrink-0">
      <div class="flex flex-col w-64 bg-gray-800">
        <div class="h-0 flex-1 flex flex-col pt-5 pb-4 overflow-y-auto">
          <div class="flex items-center flex-shrink-0 px-4">
            <router-link to="/profiles">
              <img class="h-12 w-auto"
                   src="/img/logos/opencspm-logo-on-dark.svg"
                   alt="OpenCSPM" />
            </router-link>
          </div>

          <nav class="mt-5 flex-1 px-2 bg-gray-800">
            <router-link class="mt-1 group flex items-center px-2 py-2 text-sm leading-5 font-medium text-gray-300 rounded-md hover:text-white hover:bg-gray-700 focus:outline-none focus:text-white focus:bg-gray-700 transition ease-in-out duration-50"
                         active-class="group flex items-center px-2 py-2 text-sm leading-5 font-medium text-white rounded-md bg-gray-900 focus:outline-none focus:bg-gray-900 transition ease-in-out duration-50"
                         v-for="nav in navItems"
                         :key="nav.path"
                         :to="nav.path">
              <svg class="mt-1 mr-3 h-6 w-6 text-gray-300 group-hover:text-gray-300 group-focus:text-gray-300 transition ease-in-out duration-150"
                   :class="{'scale-x-mirror': nav.path === '/campaigns'}"
                   fill="currentColor"
                   stroke-linecap="round"
                   stroke-linejoin="round"
                   stroke-width="2"
                   stroke="none"
                   viewBox="0 0 24 24">

                <path v-if="nav.path === '/campaigns'"
                      d="M5 3a2 2 0 00-2 2v2a2 2 0 002 2h2a2 2 0 002-2V5a2 2 0 00-2-2H5zM5 11a2 2 0 00-2 2v2a2 2 0 002 2h2a2 2 0 002-2v-2a2 2 0 00-2-2H5zM11 5a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V5zM14 11a1 1 0 011 1v1h1a1 1 0 110 2h-1v1a1 1 0 11-2 0v-1h-1a1 1 0 110-2h1v-1a1 1 0 011-1z" />

                <path v-if="nav.path === '/sources'"
                      d="M3 12v3c0 1.657 3.134 3 7 3s7-1.343 7-3v-3c0 1.657-3.134 3-7 3s-7-1.343-7-3z" />
                <path v-if="nav.path === '/sources'"
                      d="M3 7v3c0 1.657 3.134 3 7 3s7-1.343 7-3V7c0 1.657-3.134 3-7 3S3 8.657 3 7z" />
                <path v-if="nav.path === '/sources'"
                      d="M17 5c0 1.657-3.134 3-7 3S3 6.657 3 5s3.134-3 7-3 7 1.343 7 3z" />

                <path v-if="nav.path === '/admin'"
                      d="M11 17a1 1 0 001.447.894l4-2A1 1 0 0017 15V9.236a1 1 0 00-1.447-.894l-4 2a1 1 0 00-.553.894V17zM15.211 6.276a1 1 0 000-1.788l-4.764-2.382a1 1 0 00-.894 0L4.789 4.488a1 1 0 000 1.788l4.764 2.382a1 1 0 00.894 0l4.764-2.382zM4.447 8.342A1 1 0 003 9.236V15a1 1 0 00.553.894l4 2A1 1 0 009 17v-5.764a1 1 0 00-.553-.894l-4-2z" />

                <path v-if="nav.path === '/controls'"
                      d="M9 2a1 1 0 000 2h2a1 1 0 100-2H9z" />
                <path v-if="nav.path === '/controls'"
                      fill-rule="evenodd"
                      d="M4 5a2 2 0 012-2 3 3 0 003 3h2a3 3 0 003-3 2 2 0 012 2v11a2 2 0 01-2 2H6a2 2 0 01-2-2V5zm3 4a1 1 0 000 2h.01a1 1 0 100-2H7zm3 0a1 1 0 000 2h3a1 1 0 100-2h-3zm-3 4a1 1 0 100 2h.01a1 1 0 100-2H7zm3 0a1 1 0 100 2h3a1 1 0 100-2h-3z"
                      clip-rule="evenodd" />

                <path v-if="nav.path === '/profiles'"
                      d="M5 4a1 1 0 00-2 0v7.268a2 2 0 000 3.464V16a1 1 0 102 0v-1.268a2 2 0 000-3.464V4zM11 4a1 1 0 10-2 0v1.268a2 2 0 000 3.464V16a1 1 0 102 0V8.732a2 2 0 000-3.464V4zM16 3a1 1 0 011 1v7.268a2 2 0 010 3.464V16a1 1 0 11-2 0v-1.268a2 2 0 010-3.464V4a1 1 0 011-1z" />

              </svg>
              <span>
                {{ nav.name }}
              </span>
              <span class="ml-auto inline-block py-0.5 px-3 text-xs leading-4 font-medium rounded-full bg-gray-900 transition ease-in-out duration-150 group-hover:bg-gray-800 group-focus:bg-gray-800"
                    v-if="nav.num">
                {{ nav.num }}
              </span>
            </router-link>
          </nav>
        </div>
        <div class="flex-shrink-0 flex bg-gray-700 p-4">
          <div class="flex w-full justify-between">
            <div v-if="navLoaded"
                 class="flex items-center">
              <div class="flex-none h-9 w-9">
                <img class="inline-block h-9 w-9 rounded-full"
                     :src="`https://www.gravatar.com/avatar/${userData.email_hash}?d=mp`"
                     alt="" />
              </div>
              <div class="ml-3 w-40">
                <p class="text-sm leading-5 font-medium text-white truncate">
                  {{ userData.name }}
                </p>
                <p
                   class="text-xs leading-4 font-medium text-gray-300 group-hover:text-gray-200 truncate">
                  {{ userData.username }}
                </p>
              </div>
            </div>
            <div class="flex-none">
              <button class="focus:outline-none"
                      v-on:click="logout">
                <svg class="h-5 w-5 text-gray-200"
                     xmlns="http://www.w3.org/2000/svg"
                     viewBox="0 0 20 20"
                     fill="currentColor">
                  <path fill-rule="evenodd"
                        d="M3 3a1 1 0 00-1 1v12a1 1 0 102 0V4a1 1 0 00-1-1zm10.293 9.293a1 1 0 001.414 1.414l3-3a1 1 0 000-1.414l-3-3a1 1 0 10-1.414 1.414L14.586 9H7a1 1 0 100 2h7.586l-1.293 1.293z"
                        clip-rule="evenodd" />
                </svg>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div class="flex flex-col w-0 flex-1 overflow-hidden">
      <div class="md:hidden pl-1 pt-1 sm:pl-3 sm:pt-3">
        <button class="-ml-0.5 -mt-0.5 h-12 w-12 inline-flex items-center justify-center rounded-md text-gray-500 hover:text-gray-900 focus:outline-none focus:bg-gray-200 transition ease-in-out duration-150"
                aria-label="Open sidebar">
          <svg class="h-6 w-6"
               stroke="currentColor"
               fill="none"
               viewBox="0 0 24 24">
            <path stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M4 6h16M4 12h16M4 18h16" />
          </svg>
        </button>
      </div>
      <main class="flex-1 relative z-0 overflow-y-auto pb-6 focus:outline-none"
            tabindex="0">
        <div class="px-0">
          <router-view />
        </div>
      </main>
    </div>
  </div>
</template>

<script>
  import xhr from 'axios'

  export default {
    methods: {
      logout: function () {
        let url = '/sessions/logout'

        xhr.delete(url).then(() => {
          this.$emit('logout')
        }).catch(e => {
          // eslint-disable-next-line
          console.log(e)
        })
      }
    },
    mounted() {
      let url = '/sessions/nav'

      xhr.get(url).then(resp => {
        this.navItems = resp.data.nav_items
        this.userData = resp.data.user_data
        this.navLoaded = true
      }).catch(e => {
        // eslint-disable-next-line
        console.info(e)
      })
    },
    data() {
      return {
        navLoaded: false,
        navItems: [],
        userData: null
      }
    }
  }

</script>
