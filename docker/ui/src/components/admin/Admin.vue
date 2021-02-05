<template>
  <div class="flex">
    <div class="flex-1 overflow-auto focus:outline-none"
         tabindex="0">
      <main class="flex-1 relative pb-8 z-0 overflow-y-auto">
        <!-- Page header -->
        <div class="bg-white shadow">
          <div class="px-4 sm:px-6 lg:px-8">
            <div
                 class="py-6 md:flex md:items-center md:justify-between lg:border-t lg:border-cool-gray-200">
              <div class="flex-1 min-w-0">
                <!-- Profile -->
                <div class="flex items-center">
                  <div>
                    <div class="flex items-center">
                      <h1
                          class="ml-3 text-2xl font-bold leading-7 text-cool-gray-900 sm:leading-9 sm:truncate">
                        My Organization
                      </h1>
                    </div>
                    <dl class="mt-6 flex flex-col sm:ml-3 sm:mt-1 sm:flex-row sm:flex-wrap">
                      <dt class="sr-only">Account status</dt>
                      <dd
                          class="mt-3 flex items-center text-sm leading-5 text-cool-gray-500 font-medium sm:mr-6 sm:mt-0 capitalize">
                        <svg class="flex-shrink-0 mr-1.5 h-5 w-5 text-green-400"
                             viewBox="0 0 20 20"
                             fill="currentColor">
                          <path fill-rule="evenodd"
                                d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                                clip-rule="evenodd" />
                        </svg>
                        Active
                      </dd>
                    </dl>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="mt-8">
          <div class="">
            <h2 class="mx-4 text-lg leading-6 font-medium text-cool-gray-700">Status</h2>
            <div class="mx-4 mt-2 grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
              <!-- Cards -->
              <AdminCard type="sources"
                         :data="sources" />
              <AdminCard type="profiles"
                         :data="profiles" />
              <AdminCard type="controls"
                         :data="controls" />
            </div>
          </div>

          <h2 class="mx-4 mt-8 text-lg leading-6 font-medium text-cool-gray-700">
            Recent activity
          </h2>

          <!-- Activity table (small breakopoint and up) -->
          <div class="mx-4">
            <div class="flex flex-col mt-2">
              <div
                   class="align-middle min-w-full overflow-x-auto shadow overflow-hidden sm:rounded-lg">
                <table class="min-w-full divide-y divide-cool-gray-200">
                  <thead>
                    <tr>
                      <th
                          class="px-6 py-3 bg-cool-gray-50 text-left text-xs leading-4 font-medium text-cool-gray-500 uppercase tracking-wider">
                        Job
                      </th>
                      <th
                          class="hidden px-6 py-3 bg-cool-gray-50 text-left text-xs leading-4 font-medium text-cool-gray-500 uppercase tracking-wider md:block">
                        Status
                      </th>
                      <th
                          class="px-6 py-3 bg-cool-gray-50 text-right text-xs leading-4 font-medium text-cool-gray-500 uppercase tracking-wider">
                        Time
                      </th>
                    </tr>
                  </thead>
                  <tbody class="bg-white divide-y divide-cool-gray-200">
                    <tr v-for="event in events"
                        :key="event.id"
                        class="bg-white">
                      <td
                          class="max-w-0 w-full px-6 py-4 whitespace-no-wrap text-sm leading-5 text-cool-gray-900">
                        <div class="flex">
                          <span class="group inline-flex space-x-2 truncate text-sm leading-5">

                            <svg class="flex-shrink-0 h-5 w-5 text-cool-gray-400 group-hover:text-cool-gray-500 transition ease-in-out duration-150"
                                 viewBox="0 0 20 20"
                                 fill="currentColor">
                              <path fill-rule="evenodd"
                                    d="M9.504 1.132a1 1 0 01.992 0l1.75 1a1 1 0 11-.992 1.736L10 3.152l-1.254.716a1 1 0 11-.992-1.736l1.75-1zM5.618 4.504a1 1 0 01-.372 1.364L5.016 6l.23.132a1 1 0 11-.992 1.736L4 7.723V8a1 1 0 01-2 0V6a.996.996 0 01.52-.878l1.734-.99a1 1 0 011.364.372zm8.764 0a1 1 0 011.364-.372l1.733.99A1.002 1.002 0 0118 6v2a1 1 0 11-2 0v-.277l-.254.145a1 1 0 11-.992-1.736l.23-.132-.23-.132a1 1 0 01-.372-1.364zm-7 4a1 1 0 011.364-.372L10 8.848l1.254-.716a1 1 0 11.992 1.736L11 10.58V12a1 1 0 11-2 0v-1.42l-1.246-.712a1 1 0 01-.372-1.364zM3 11a1 1 0 011 1v1.42l1.246.712a1 1 0 11-.992 1.736l-1.75-1A1 1 0 012 14v-2a1 1 0 011-1zm14 0a1 1 0 011 1v2a1 1 0 01-.504.868l-1.75 1a1 1 0 11-.992-1.736L16 13.42V12a1 1 0 011-1zm-9.618 5.504a1 1 0 011.364-.372l.254.145V16a1 1 0 112 0v.277l.254-.145a1 1 0 11.992 1.736l-1.735.992a.995.995 0 01-1.022 0l-1.735-.992a1 1 0 01-.372-1.364z"
                                    clip-rule="evenodd" />
                            </svg>

                            <p
                               class="text-cool-gray-500 truncate group-hover:text-cool-gray-900 transition ease-in-out duration-150">
                              {{ event.kind }} job
                              <span
                                    class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium leading-4 bg-gray-100 text-gray-400">
                                {{ event.guid.split('-')[0] }}
                              </span>
                            </p>
                          </span>
                        </div>
                      </td>
                      <td
                          class="hidden px-6 py-4 whitespace-no-wrap text-sm leading-5 text-cool-gray-500 md:block">
                        <span :class="{'bg-green-100 text-green-800': event.status === 'complete', 'bg-blue-100 text-blue-800': event.status === 'running', 'bg-red-100 text-red-800': event.status === 'failed'}"
                              class="inline-flex items-center px-2.5 py-0.5 rounded text-xs font-medium leading-4 capitalize">
                          {{ event.status }}
                        </span>
                      </td>
                      <td
                          class="px-6 py-4 text-right whitespace-no-wrap text-sm leading-5 text-cool-gray-500">
                        {{ event.created_at | format }}
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  </div>

</template>

<script>
  import AdminCard from './AdminCard'
  import moment from 'moment'

  export default {
    components: {
      AdminCard
    },
    filters: {
      format: function(value) {
        return moment(value).fromNow()
      }
    },
    methods: {
      load: function() {
        this.loadSources()
        this.loadProfiles()
        this.loadEvents()
        this.loadControls()
      },
      loadSources: function() {
        let url = '/sources'

        this.$http.get(url)
          .then(res => {
            this.sources = res.data
          })
      },
      loadProfiles: function() {
        let url = '/profiles'

        this.$http.get(url)
          .then(res => {
            this.profiles = res.data.data
          })
      },
      loadControls: function() {
        let url = '/controls'

        this.$http.get(url)
          .then(res => {
            this.controls = res.data.data
          })
      },
      loadEvents: function() {
        let url = '/jobs'

        this.$http.get(url)
          .then(res => {
            this.events = res.data
          })
      },
    },
    mounted: function() {
      this.load()
    },
    data() {
      return {
        sources: [],
        profiles: [],
        controls: [],
        events: []
      }
    }
  }

</script>
