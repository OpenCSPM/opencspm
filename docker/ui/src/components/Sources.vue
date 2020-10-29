<template>
  <div class="space-y-8">
    <!-- Data Sources -->
    <div>
      <div v-if="showTip"
           class="mx-4 my-4">
        <!--
            Tailwind UI components require Tailwind CSS v1.8 and the @tailwindcss/ui plugin.
            Read the documentation to get started: https://tailwindui.com/documentation
          -->
        <div class="bg-indigo-50 border-l-4 border-indigo-400 p-4">
          <div class="flex">
            <div class="flex-shrink-0">
              <svg class="h-5 w-5 text-indigo-400"
                   xmlns="http://www.w3.org/2000/svg"
                   viewBox="0 0 20 20"
                   fill="currentColor">
                <path fill-rule="evenodd"
                      d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z"
                      clip-rule="evenodd" />
              </svg>
            </div>
            <div class="ml-3">
              <h3 class="text-sm leading-5 font-bold text-indigo-800">
                Inventory Sources
              </h3>
              <div class="mt-2 text-sm leading-5 text-indigo-700">
                <p>
                  Inventory sources allow you to import data into OpenCSPM. Inventory sources can be
                  cloud provider accounts (AWS & Google Cloud), G Suite accounts, or container
                  orchestration clusters (Kubernetes - provider manager, or standalone). Edit
                  <span
                        class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium leading-4 bg-purple-100 text-purple-800">
                    config.yaml
                  </span> to add new inventory sources.
                </p>
              </div>
            </div>
            <div class="ml-auto pl-3">
              <div class="-mx-1.5 -my-1.5">
                <button @click="hideSourceTip"
                        class="inline-flex rounded-md p-1.5 text-indigo-500 hover:bg-indigo-100 focus:outline-none focus:bg-indigo-100 transition ease-in-out duration-150"
                        aria-label="Dismiss">
                  <!-- Heroicon name: x -->
                  <svg class="h-5 w-5"
                       xmlns="http://www.w3.org/2000/svg"
                       viewBox="0 0 20 20"
                       fill="currentColor">
                    <path fill-rule="evenodd"
                          d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z"
                          clip-rule="evenodd" />
                  </svg>
                </button>
              </div>
            </div>
          </div>
        </div>

      </div>
      <div class="bg-white px-4 py-5 border-b border-gray-200 sm:px-6">
        <div class="-ml-4 -mt-2 flex items-center justify-between">
          <div class="ml-4 mt-2">
            <h3 class="text-lg leading-6 font-medium text-gray-900">
              Inventory Sources
            </h3>
          </div>
        </div>
      </div>
      <div class="bg-white">
        <DataSources v-for="(source, idx) in sources"
                     :key="idx"
                     :source="source" />
      </div>
    </div>

  </div>
</template>

<script>
  import DataSources from './settings/DataSources'

  export default {
    components: {
      DataSources
    },
    methods: {
      loadDataSources: function() {
        let url = '/sources'

        this.$http.get(url)
          .then(res => {
            this.sources = res.data
          })
          .catch(() => {})
      },
      hideSourceTip: function() {
        localStorage.show_tip_datasource = false
        this.showTip = false
      },
      loadSourceTip: function() {
        this.showTip = localStorage.show_tip_datasource ? false : true
      }
    },
    mounted: function() {
      this.loadDataSources()
      this.loadDataSources()
    },
    data() {
      return {
        showTip: true,
        sources: []
      }
    }
  }

</script>
