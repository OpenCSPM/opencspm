<template>
  <div>
    <ul class=" divide-y divide-gray-200 border-b border-gray-200">
      <li class=" pl-4 pr-6 py-5 sm:py-6 sm:pl-6 lg:pl-8 xl:pl-6">
        <div class="flex items-center justify-between space-x-4">
          <!-- Repo name and link -->
          <div class="min-w-0 space-y-3">
            <div class="flex items-center space-x-3">
              <span v-if="ds.status !== 'disabled'"
                    aria-label="Running"
                    class="h-4 w-4 bg-green-100 rounded-full flex items-center justify-center">
                <span class="h-2 w-2 bg-green-400 rounded-full"></span>
              </span>
              <span v-if="ds.status === 'disabled'"
                    aria-label="Disable"
                    class="h-4 w-4 bg-gray-100 rounded-full flex items-center justify-center">
                <span class="h-2 w-2 bg-gray-400 rounded-full"></span>
              </span>
              <span class="block">
                <h2 class="text-sm font-medium leading-5">
                  <span>
                    {{ ds.name }}
                  </span>
                </h2>
              </span>
            </div>
            <span class="relative group flex items-center space-x-2.5">
              <div
                   class="text-sm leading-5 text-gray-500 group-hover:text-gray-900 font-medium truncate">
                {{ ds.location }}
              </div>
            </span>
          </div>
          <!-- Repo meta info -->
          <div class="hidden sm:flex flex-col flex-shrink-0 items-end space-y-3">
            <div class="flex items-center space-x-4">
              <div class="relative flex justify-end items-center">
                <button @click="toggle"
                        @blur="close"
                        id="project-options-menu-0"
                        aria-has-popup="true"
                        type="button"
                        class="w-8 h-8 inline-flex items-center justify-center text-gray-400 rounded-full bg-transparent hover:text-gray-500 focus:outline-none focus:text-gray-500 focus:bg-gray-100 transition ease-in-out duration-150">
                  <svg class="w-5 h-5"
                       viewBox="0 0 20 20"
                       fill="currentColor">
                    <path
                          d="M10 6a2 2 0 110-4 2 2 0 010 4zM10 12a2 2 0 110-4 2 2 0 010 4zM10 18a2 2 0 110-4 2 2 0 010 4z" />
                  </svg>
                </button>
                <transition name="dropdown-transition"
                            enter-class="transform opacity-0 scale-95"
                            enter-active-class="transition ease-out duration-100"
                            enter-to-class="transform opacity-100 scale-100"
                            leave-class="transform opacity-100 scale-100"
                            leave-active-class="transition ease-in duration-75"
                            leave-to-class="transform opacity-0 scale-95">
                  <div v-if="actionPanelOpen"
                       class="mx-3 origin-top-right absolute right-7 top-0 w-48 mt-1 rounded-md shadow-lg">
                    <div class="rounded-md bg-white shadow-xs"
                         role="menu"
                         aria-orientation="vertical"
                         aria-labelledby="project-options-menu-0">
                      <button @click="scan"
                              class="py-1 w-full">
                        <span class="group flex items-center px-4 py-2 text-sm leading-5 text-gray-700 hover:bg-gray-100 hover:text-gray-900 focus:outline-none focus:bg-gray-100 focus:text-gray-900"
                              role="menuitem">
                          <svg class="mr-3 h-5 w-5 text-gray-400 group-hover:text-gray-500 group-focus:text-gray-500"
                               viewBox="0 0 20 20"
                               fill="currentColor">
                            <path
                                  d="M17.414 2.586a2 2 0 00-2.828 0L7 10.172V13h2.828l7.586-7.586a2 2 0 000-2.828z" />
                            <path fill-rule="evenodd"
                                  d="M2 6a2 2 0 012-2h4a1 1 0 010 2H4v10h10v-4a1 1 0 112 0v4a2 2 0 01-2 2H4a2 2 0 01-2-2V6z"
                                  clip-rule="evenodd" />
                          </svg>
                          Analyze Now
                        </span>
                      </button>
                      <div class="border-t border-gray-100"></div>
                      <button @click="disable"
                              class="py-1 w-full">
                        <a href="#"
                           class="group flex items-center px-4 py-2 text-sm leading-5 text-gray-700 hover:bg-gray-100 hover:text-gray-900 focus:outline-none focus:bg-gray-100 focus:text-gray-900"
                           role="menuitem">
                          <svg class="mr-3 h-5 w-5 text-gray-400 group-hover:text-gray-500 group-focus:text-gray-500"
                               viewBox="0 0 20 20"
                               fill="currentColor">
                            <path fill-rule="evenodd"
                                  d="M9 2a1 1 0 00-.894.553L7.382 4H4a1 1 0 000 2v10a2 2 0 002 2h8a2 2 0 002-2V6a1 1 0 100-2h-3.382l-.724-1.447A1 1 0 0011 2H9zM7 8a1 1 0 012 0v6a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v6a1 1 0 102 0V8a1 1 0 00-1-1z"
                                  clip-rule="evenodd" />
                          </svg>
                          Disable
                        </a>
                      </button>
                    </div>
                  </div>
                </transition>
              </div>
            </div>
            <p class="flex text-gray-500 text-sm leading-5 space-x-2">
              <span>Last activity {{ ds.updated_at | moment }}</span>
            </p>
          </div>
        </div>
      </li>
    </ul>
  </div>
</template>

<script>
  import moment from 'moment'

  export default {
    props: ['source', 'menuOpen'],
    methods: {
      scan: function() {
        let payload = {
          source: {
            status: 'scan_requested'
          }
        }

        this.$http.patch(this.url, payload)
          .then(res => {
            this.ds = res.data
            this.check()
          })
      },
      check: function() {
        this.$http.get(this.url)
          .then(res => {
            this.ds = res.data
          })
      },
      disable: function() {
        let payload = {
          source: {
            status: 'disabled'
          }
        }

        this.$http.patch(this.url, payload)
          .then(res => {
            this.ds = res.data
          })
      },
      toggle: function() {
        this.actionPanelOpen = !this.actionPanelOpen
      },
      close: function() {
        setTimeout(() => {
          this.actionPanelOpen = false
        }, 100)
      }
    },
    filters: {
      moment: function(value) {
        return moment(value).fromNow()
      }
    },
    data() {
      return {
        url: `/sources/${this.source.id}`,
        ds: this.source,
        scanTimeout: 1500,
        actionPanelOpen: false,
      }
    }
  }

</script>
