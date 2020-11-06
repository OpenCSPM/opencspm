<template>
  <div class="min-h-screen bg-white flex">
    <div
         class="flex-1 flex flex-col justify-center py-12 px-4 sm:px-6 lg:flex-none lg:px-20 xl:px-24">
      <div class="mx-auto w-full max-w-sm lg:w-96">
        <div class="flex justify-center mb-16">
          <img class="h-48 w-48"
               src="/img/logos/opencspm-mark-on-light.svg"
               alt="OpenCSPM" />
        </div>
        <div class="text-center">
          <h2 class="mt-6 text-3xl leading-9 font-extrabold text-gray-900">
            Open<span class="tracking-tighter border-b-2 border-yellow-300">CSPM</span>
          </h2>
        </div>

        <div class="mt-2">
          <div>

            <div class="mt-6">
              <div class="space-y-6">
                <div>
                  <span class="block w-full rounded-md shadow-sm">
                    <button v-on:click="login"
                            class="w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-500 focus:outline-none focus:border-indigo-700 focus:shadow-outline-indigo active:bg-indigo-700 transition duration-150 ease-in-out">
                      Demo Admin Sign in
                    </button>
                  </span>
                </div>
              </div>
            </div>

            <div class="mt-10 relative">
              <div class="absolute inset-0 flex items-center">
                <div class="w-full border-t border-gray-300"></div>
              </div>
              <div class="mb-4 relative flex justify-center text-sm leading-5">
                <span class="px-2 bg-white text-gray-500">
                  Or with <span class="font-semibold">Enterprise SSO</span> account
                </span>
              </div>
            </div>
          </div>

          <div class="mt-1 grid grid-cols-2 gap-3">
            <div>
              <a :href="`${this.BASE_URL}/auth/google`"
                 class="w-full inline-flex rounded-md shadow-sm">
                <button type="button"
                        class="w-full inline-flex justify-center py-2 px-4 border border-gray-300 rounded-md bg-white text-sm leading-5 font-medium text-gray-500 hover:text-gray-400 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue transition duration-150 ease-in-out"
                        aria-label="Sign in with Google">
                  <svg class="w-5 h-5"
                       fill="currentColor"
                       viewBox="0 0 767 617"
                       version="1.1">
                    <g transform="matrix(1,0,0,1,-16.6667,-83.2542)">
                      <g transform="matrix(4.16667,0,0,4.16667,0,0)">
                        <path
                              d="M121.109,60.875L127.003,60.987L143.016,44.973L143.792,38.193C131.069,26.875 114.328,19.981 96,19.981C62.815,19.981 34.817,42.554 26.515,73.148C28.268,71.937 31.996,72.839 31.996,72.839L63.999,67.581C63.999,67.581 65.655,64.86 66.473,65.028C73.792,57.016 84.319,51.981 96,51.981C105.504,51.981 114.239,55.319 121.109,60.875Z" />
                        <path
                              d="M165.496,73.189C161.782,59.469 154.109,47.365 143.777,38.18L121.094,60.863C130.175,68.202 136,79.422 136,91.981L136,95.981C147.028,95.981 156,104.953 156,115.981C156,127.009 147.028,135.981 135.996,135.981L96,135.981L91.996,140.001L91.996,164.002L96,167.981L136,167.981C164.673,167.981 188,144.654 188,115.981C188,98.255 179.078,82.58 165.496,73.189Z" />
                        <path
                              d="M55.998,167.981L95.967,167.981L95.967,135.981L56.003,135.981C53.064,135.981 50.28,135.328 47.763,134.184L41.998,135.946L25.978,151.967L24.574,157.373C33.31,164.022 44.198,167.98 55.998,167.981Z" />
                        <path
                              d="M56,63.981C27.327,63.981 4,87.308 4,115.981C4,132.864 12.092,147.887 24.596,157.392L47.79,134.198C40.849,131.058 36,124.082 36,115.981C36,104.953 44.971,95.981 56,95.981C64.1,95.981 71.076,100.83 74.217,107.771L97.411,84.577C87.906,72.074 72.883,63.981 56,63.981Z" />
                      </g>
                    </g>
                  </svg>
                </button>
              </a>
              <div class="mt-1 text-xs text-center font-medium text-gray-600">Google</div>
            </div>

            <div>
              <a :href="`${this.BASE_URL}/auth/github`"
                 class="w-full inline-flex rounded-md shadow-sm">
                <button type="button"
                        class="w-full inline-flex justify-center py-2 px-4 border border-gray-300 rounded-md bg-white text-sm leading-5 font-medium text-gray-500 hover:text-gray-400 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue transition duration-150 ease-in-out"
                        aria-label="Sign in with GitHub">
                  <svg class="w-5 h-5"
                       fill="currentColor"
                       viewBox="0 0 20 20">
                    <path fill-rule="evenodd"
                          d="M10 0C4.477 0 0 4.484 0 10.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0110 4.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.203 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.942.359.31.678.921.678 1.856 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0020 10.017C20 4.484 15.522 0 10 0z"
                          clip-rule="evenodd" />
                  </svg>
                </button>
              </a>
              <div class="mt-1 text-xs text-center font-medium text-gray-600">GitHub</div>
            </div>
          </div>

        </div>
      </div>
    </div>
    <div class="hidden lg:block relative w-0 flex-1">
      <img class="absolute inset-0 h-full w-full object-cover"
           src="https://images.unsplash.com/photo-1545243424-0ce743321e11?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1534&q=80"
           alt="">
    </div>
  </div>

</template>

<script>
  import xhr from 'axios'

  export default {
    methods: {
      login: function() {
        let url = '/sessions'
        let payload = {
          session: {
            username: 'demo',
            password: 'demo'
          }
        }

        xhr.post(url, payload)
          .then(res => {
            if (res.status === 200) {
              this.$emit('login')
            } else {
              this.$emit('login-error')
            }
          })
      }
    }
  }

</script>
