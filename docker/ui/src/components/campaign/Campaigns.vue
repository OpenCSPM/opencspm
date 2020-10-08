<template>
  <div class="h-screen flex overflow-hidden bg-white">
    <!-- Main column -->
    <div class="flex flex-col w-0 flex-1 overflow-hidden">
      <main class="flex-1 relative z-0 overflow-y-auto focus:outline-none"
            tabindex="0">
        <!-- Pinned projects -->
        <div class="px-4 mt-6 sm:px-6 lg:px-8">
          <h2 class="text-gray-500 text-xs font-medium uppercase tracking-wide">Pinned Campaigns
          </h2>
          <ul class="grid grid-cols-1 gap-4 sm:gap-6 sm:grid-cols-2 lg:grid-cols-4 mt-3">
            <li v-for="campaign in pinned"
                :key="campaign.id"
                class="relative col-span-1 flex shadow-sm rounded-md">
              <div
                   :class="`flex-shrink-0 flex items-center justify-center w-16 ${campaign.bg} text-white text-sm leading-5 font-medium rounded-l-md`">
                {{ campaign.initials }}
              </div>
              <div
                   class="flex-1 flex items-center justify-between border-t border-r border-b border-gray-200 bg-white rounded-r-md truncate">
                <div class="flex-1 px-4 py-2 text-sm leading-5 truncate">
                  <router-link to="/campaigns/1"
                               class="text-gray-900 font-medium hover:text-gray-600 transition ease-in-out duration-150">
                    {{ campaign.name }}
                  </router-link>
                  <p class="text-gray-500">{{ campaign.policies }} Controls</p>
                </div>
                <div class="flex-shrink-0 pr-2">
                  <button id="pinned-project-options-menu-0"
                          aria-has-popup="true"
                          class="w-8 h-8 inline-flex items-center justify-center text-gray-400 rounded-full bg-transparent hover:text-gray-500 focus:outline-none focus:text-gray-500 focus:bg-gray-100 transition ease-in-out duration-150">
                    <svg class="w-5 h-5"
                         viewBox="0 0 20 20"
                         fill="currentColor">
                      <path
                            d="M10 6a2 2 0 110-4 2 2 0 010 4zM10 12a2 2 0 110-4 2 2 0 010 4zM10 18a2 2 0 110-4 2 2 0 010 4z" />
                    </svg>
                  </button>
                  <!--
                  Dropdown panel, show/hide based on dropdown state.

                  Entering: "transition ease-out duration-100"
                    From: "transform opacity-0 scale-95"
                    To: "transform opacity-100 scale-100"
                  Leaving: "transition ease-in duration-75"
                    From: "transform opacity-100 scale-100"
                    To: "transform opacity-0 scale-95"
                -->
                  <div v-if="1 == 2"
                       class="z-10 mx-3 origin-top-right absolute right-10 top-3 w-48 mt-1 rounded-md shadow-lg">
                    <div class="rounded-md bg-white shadow-xs"
                         role="menu"
                         aria-orientation="vertical"
                         aria-labelledby="pinned-project-options-menu-0">
                      <div class="py-1">
                        <a href="#"
                           class="block px-4 py-2 text-sm leading-5 text-gray-700 hover:bg-gray-100 hover:text-gray-900 focus:outline-none focus:bg-gray-100 focus:text-gray-900"
                           role="menuitem">View</a>
                      </div>
                      <div class="border-t border-gray-100"></div>
                      <div class="py-1">
                        <a href="#"
                           class="block px-4 py-2 text-sm leading-5 text-gray-700 hover:bg-gray-100 hover:text-gray-900 focus:outline-none focus:bg-gray-100 focus:text-gray-900"
                           role="menuitem">Removed from pinned</a>
                        <a href="#"
                           class="block px-4 py-2 text-sm leading-5 text-gray-700 hover:bg-gray-100 hover:text-gray-900 focus:outline-none focus:bg-gray-100 focus:text-gray-900"
                           role="menuitem">Share</a>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </li>

            <!-- More project cards... -->
          </ul>
        </div>
        <!-- Projects list (only on smallest breakpoint) -->
        <div class="mt-10 sm:hidden">
          <div class="px-4 sm:px-6">
            <h2 class="text-gray-500 text-xs font-medium uppercase tracking-wide">Projects</h2>
          </div>
          <ul class="mt-3 border-t border-gray-200 divide-y divide-gray-100">
            <li>
              <a href="#"
                 class="flex items-center justify-between px-4 py-4 hover:bg-gray-50 sm:px-6">
                <div class="flex items-center truncate space-x-3">
                  <div class="w-2.5 h-2.5 flex-shrink-0 rounded-full bg-pink-600"></div>
                  <p class="font-medium truncate text-sm leading-6">GraphQL API <span
                          class="truncate font-normal text-gray-500">in Engineering</span></p>
                </div>
                <svg class="ml-4 h-5 w-5 text-gray-400 group-hover:text-gray-500 group-focus:text-gray-600 transition ease-in-out duration-150"
                     viewBox="0 0 20 20"
                     fill="currentColor">
                  <path fill-rule="evenodd"
                        d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z"
                        clip-rule="evenodd" />
                </svg>
              </a>
            </li>

            <!-- More project rows... -->
          </ul>
        </div>
        <!-- Projects table (small breakpoint and up) -->
        <div class="hidden mt-8 sm:block">
          <div class="align-middle inline-block min-w-full border-b border-gray-200">
            <table class="min-w-full">
              <thead>
                <tr class="border-t border-gray-200">
                  <th
                      class="px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                    <span class="lg:pl-2">Campaign</span>
                  </th>
                  <th
                      class="px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                    Controls
                  </th>
                  <th
                      class="px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                    Issues
                  </th>
                  <th
                      class="hidden md:table-cell px-6 py-3 border-b border-gray-200 bg-gray-50 text-right text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                    Last updated
                  </th>
                  <th
                      class="pr-6 py-3 border-b border-gray-200 bg-gray-50 text-right text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  </th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-100">
                <tr v-for="campaign in campaigns"
                    :key="campaign.id">
                  <td
                      class="px-6 py-3 max-w-0 w-full whitespace-no-wrap text-sm leading-5 font-medium text-gray-900">
                    <div class="flex items-center space-x-3 lg:pl-2">
                      <div :class="`flex-shrink-0 w-2.5 h-2.5 rounded-full ${icon()}`">
                      </div>
                      <router-link :to="`/campaigns/${campaign.id}`"
                                   class="truncate hover:text-gray-600">
                        <span>{{ campaign.name }}</span>
                      </router-link>
                    </div>
                  </td>
                  <td class="px-6 py-3 text-sm leading-5 text-gray-500 font-medium">
                    <div class="flex items-center space-x-2">
                      <span
                            class="flex-shrink-0 text-xs leading-5 font-medium">{{ campaign.control_count }}</span>
                    </div>
                  </td>
                  <td class="px-6 py-3 text-sm leading-5 text-gray-500 font-medium">
                    <div class="flex items-center space-x-2">
                      <span
                            class="flex-shrink-0 text-xs leading-5 font-medium">{{ campaign.policies }}</span>
                    </div>
                  </td>
                  <td
                      class="hidden md:table-cell px-6 py-3 whitespace-no-wrap text-sm leading-5 text-gray-500 text-right">
                    {{ campaign.updated_at }}
                  </td>
                  <td class="pr-6">
                    <div class="relative flex justify-end items-center">
                      <button id="project-options-menu-0"
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
                      <div class="mx-3 origin-top-right absolute right-7 top-0 w-48 mt-1 rounded-md shadow-lg"
                           v-if="1 == 2">
                        <div class="z-10 rounded-md bg-white shadow-xs"
                             role="menu"
                             aria-orientation="vertical"
                             aria-labelledby="project-options-menu-0">
                          <div class="py-1">
                            <a href="#"
                               class="group flex items-center px-4 py-2 text-sm leading-5 text-gray-700 hover:bg-gray-100 hover:text-gray-900 focus:outline-none focus:bg-gray-100 focus:text-gray-900"
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
                              Edit
                            </a>
                            <a class="group flex items-center px-4 py-2 text-sm leading-5 text-gray-700 hover:bg-gray-100 hover:text-gray-900 focus:outline-none focus:bg-gray-100 focus:text-gray-900"
                               href="#"
                               role="menuitem">
                              <svg class="mr-3 h-5 w-5 text-gray-400 group-hover:text-gray-500 group-focus:text-gray-500"
                                   viewBox="0 0 20 20"
                                   fill="currentColor">
                                <path
                                      d="M7 9a2 2 0 012-2h6a2 2 0 012 2v6a2 2 0 01-2 2H9a2 2 0 01-2-2V9z" />
                                <path d="M5 3a2 2 0 00-2 2v6a2 2 0 002 2V5h8a2 2 0 00-2-2H5z" />
                              </svg>
                              Duplicate
                            </a>
                            <a class="group flex items-center px-4 py-2 text-sm leading-5 text-gray-700 hover:bg-gray-100 hover:text-gray-900 focus:outline-none focus:bg-gray-100 focus:text-gray-900"
                               href="#"
                               role="menuitem">
                              <svg class="mr-3 h-5 w-5 text-gray-400 group-hover:text-gray-500 group-focus:text-gray-500"
                                   viewBox="0 0 20 20"
                                   fill="currentColor">
                                <path
                                      d="M8 9a3 3 0 100-6 3 3 0 000 6zM8 11a6 6 0 016 6H2a6 6 0 016-6zM16 7a1 1 0 10-2 0v1h-1a1 1 0 100 2h1v1a1 1 0 102 0v-1h1a1 1 0 100-2h-1V7z" />
                              </svg>
                              Share
                            </a>
                          </div>
                          <div class="border-t border-gray-100"></div>
                          <div class="py-1">
                            <a class="group flex items-center px-4 py-2 text-sm leading-5 text-gray-700 hover:bg-gray-100 hover:text-gray-900 focus:outline-none focus:bg-gray-100 focus:text-gray-900"
                               href="#"
                               role="menuitem">
                              <svg class="mr-3 h-5 w-5 text-gray-400 group-hover:text-gray-500 group-focus:text-gray-500"
                                   viewBox="0 0 20 20"
                                   fill="currentColor">
                                <path fill-rule="evenodd"
                                      d="M9 2a1 1 0 00-.894.553L7.382 4H4a1 1 0 000 2v10a2 2 0 002 2h8a2 2 0 002-2V6a1 1 0 100-2h-3.382l-.724-1.447A1 1 0 0011 2H9zM7 8a1 1 0 012 0v6a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v6a1 1 0 102 0V8a1 1 0 00-1-1z"
                                      clip-rule="evenodd" />
                              </svg>
                              Delete
                            </a>
                          </div>
                        </div>
                      </div>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </main>
    </div>
  </div>
</template>

<script>
  import xhr from 'axios'

  export default {
    methods: {
      // random numnber of policies
      rand: function() {
        let i = Math.floor(Math.random() * (20 - 2) + 2)
        return i
      },
      // random campaign icon color
      icon: function() {
        let icons = ['bg-gray-300', 'bg-blue-500', 'bg-blue-500', 'bg-yellow-300']
        let str = icons[Math.floor(Math.random() * icons.length)]
        return str
      }
    },
    mounted() {
      let url = '/campaigns'

      xhr.get(url)
        .then(resp => {
          this.campaigns = resp.data.data.map(x => x.attributes)
        })
        .catch(e => {
          console.log(e)
        })
    },
    data() {
      return {
        pinned: [{
            name: 'Google Cloud CIS',
            policies: 12,
            initials: 'GC',
            bg: 'bg-pink-500'
          },
          {
            name: 'GKE CIS',
            policies: 12,
            initials: 'GK',
            bg: 'bg-purple-500'
          },
          {
            name: 'DB BP L1',
            policies: 3,
            initials: 'DB',
            bg: 'bg-orange-500'
          },
          {
            name: 'Public Resources',
            policies: 6,
            initials: 'PR',
            bg: 'bg-green-500'
          },
        ],
        campaigns: []
      }
    }
  }

</script>
