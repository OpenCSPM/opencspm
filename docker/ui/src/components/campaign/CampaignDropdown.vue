<template>
  <div class="flex items-center space-x-3">
    <div v-if="controls">
      <span class="flex">
        <transition name="slidein-transition"
                    enter-class="transform opacity-0 scale-95"
                    enter-active-class="transition ease-out duration-200"
                    enter-to-class="transform opacity-100 scale-100"
                    leave-class="transform opacity-100 scale-100"
                    leave-active-class="transition ease-in duration-75"
                    leave-to-class="transform opacity-0 scale-95">
          <div v-show="controls.length > 0"
               class="pl-4 py-0 flex items-center bg-white">
            <div class="relative inline-block text-left">
              <div>
                <span class="rounded-md shadow-sm">
                  <button @click="toggleMenu"
                          type="button"
                          class="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-cool-gray-700 bg-cool-gray-100 hover:bg-cool-gray-50 focus:outline-none focus:border-cool-gray-300 focus:shadow-outline-indigo active:bg-indigo-200 transition ease-in-out duration-150"
                          id="options-menu"
                          aria-haspopup="true"
                          aria-expanded="true">
                    Send to campaign
                    <!-- Heroicon name: chevron-down -->
                    <svg class="-mr-1 ml-2 h-5 w-5"
                         viewBox="0 0 20 20"
                         fill="currentColor">
                      <path fill-rule="evenodd"
                            d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z"
                            clip-rule="evenodd" />
                    </svg>
                  </button>
                </span>
              </div>
              <transition name="dropdown-transition"
                          enter-class="transform opacity-0 scale-95"
                          enter-active-class="transition ease-out duration-100"
                          enter-to-class="transform opacity-100 scale-100"
                          leave-class="transform opacity-100 scale-100"
                          leave-active-class="transition ease-in duration-75"
                          leave-to-class="transform opacity-0 scale-95">
                <div v-if="menuIsOpen"
                     class="z-10 origin-top-left absolute right-0 mt-2 w-72 rounded-md shadow-lg">
                  <div class="rounded-md bg-white shadow-xs"
                       role="menu"
                       aria-orientation="vertical"
                       aria-labelledby="options-menu">
                    <div class="border-t border-gray-100"></div>
                    <div class="py-1">
                      <button class="group flex items-center px-4 py-2 w-full text-sm leading-5 text-gray-700 hover:bg-gray-100 hover:text-gray-900 focus:outline-none focus:bg-gray-100 focus:text-gray-900"
                              @click="createCampaign"
                              role="menuitem">
                        <svg class="mr-3 h-5 w-5 text-gray-400 group-hover:text-gray-500 group-focus:text-gray-500"
                             viewBox="0 0 20 20"
                             fill="currentColor">
                          <path
                                d="M2 6a2 2 0 012-2h5l2 2h5a2 2 0 012 2v6a2 2 0 01-2 2H4a2 2 0 01-2-2V6z" />
                          <path stroke="#fff"
                                stroke-linecap="round"
                                stroke-linejoin="round"
                                stroke-width="2"
                                d="M8 11h4m-2-2v4" />
                        </svg>
                        Send {{ controls.length }} controls to campaign
                      </button>
                    </div>
                  </div>
                </div>
              </transition>
            </div>
          </div>
        </transition>
      </span>
    </div>
  </div>
</template>

<script>
  import moment from 'moment'

  export default {
    props: ['filters', 'controls'],
    filters: {
      format(value) {
        return moment(value).fromNow()
      }
    },
    methods: {
      createCampaign() {
        let url = '/campaigns'
        let payload = {
          campaign: {
            name: 'New Campaign',
            filters: this.filters
          }
        }

        this.$http.post(url, payload).then(res => {
          this.$router.push({
            name: 'campaign',
            params: {
              campaign_id: res.data.data.id
            }
          })
        })
      },
      closeMenu() {
        this.menuIsOpen = false
      },
      toggleMenu() {
        this.menuIsOpen = !this.menuIsOpen
      }
    },
    mounted() {},
    data() {
      return {
        menuIsOpen: false,
        campaigns: []
      }
    }
  }

</script>
