<template>
  <div v-if="campaign">
    <!-- Background color split screen for large screens -->
    <div class="relative flex flex-col">

      <Chart class="chart mx-0 p-4 bg-white"
             v-if="loaded"
             :data="chartData.data"
             :labels="chartData.labels" />

      <div v-if="!loaded"
           class="bg-white chart-loader flex items-center">
        <div class="mx-auto flex items-center justify-center text-sm text-gray-500">
          <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-gray-500"
               fill="none"
               viewBox="0 0 24 24">
            <circle class="opacity-25"
                    cx="12"
                    cy="12"
                    r="10"
                    stroke="currentColor"
                    stroke-width="4"></circle>
            <path class="opacity-75"
                  fill="currentColor"
                  d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z">
            </path>
          </svg>
          Loading...
        </div>
      </div>

      <!-- 3 column wrapper -->
      <div class="flex-grow w-full lg:flex">
        <!-- Left sidebar & main wrapper -->
        <div class="flex-1 min-w-0 bg-white xl:flex">
          <!-- Projects List -->
          <div class="bg-white lg:min-w-0 lg:flex-1">
            <div
                 class="pl-4 pr-6 pt-4 pb-4 border-b border-gray-200 sm:pl-6 lg:pl-8 xl:pl-6 xl:pt-6 xl:border-t-0">
              <div class="flex items-center justify-end text-xs text-gray-500">
                <div>
                  <span @click="settingsToggle"
                        class="inline-flex rounded-md shadow-sm">
                    <button type="button"
                            class="inline-flex items-center px-2.5 py-1.5 border border-transparent text-xs leading-4 font-medium rounded text-white bg-indigo-600 hover:bg-indigo-500 focus:outline-none focus:border-indigo-700 focus:shadow-outline-indigo active:bg-indigo-700 transition ease-in-out duration-150">
                      Settings
                    </button>
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <!-- Tabs -->
    <div class="-ml-4 my-4">
      <nav class="flex">
        <button v-on:click="selectedTab = 'controls'"
                class="ml-4 px-3 py-2 font-medium text-sm leading-5 rounded-md"
                v-bind:class="{'text-gray-800 bg-gray-200 focus:outline-none focus:bg-gray-200': selectedTab === 'controls','text-gray-600 hover:text-gray-800 focus:outline-none focus:text-gray-800 focus:bg-gray-200': selectedTab !== 'controls'  }">
          <div class="flex items-center space-x-2">
            <svg class="h-5 w-5 text-gray-400"
                 viewBox="0 0 20 20"
                 fill="currentColor">
              <path d="M9 2a1 1 0 000 2h2a1 1 0 100-2H9z" />
              <path fill-rule="evenodd"
                    d="M4 5a2 2 0 012-2 3 3 0 003 3h2a3 3 0 003-3 2 2 0 012 2v11a2 2 0 01-2 2H6a2 2 0 01-2-2V5zm3 4a1 1 0 000 2h.01a1 1 0 100-2H7zm3 0a1 1 0 000 2h3a1 1 0 100-2h-3zm-3 4a1 1 0 100 2h.01a1 1 0 100-2H7zm3 0a1 1 0 100 2h3a1 1 0 100-2h-3z"
                    clip-rule="evenodd" />
            </svg>
            <span class="text-sm text-gray-500 leading-5 font-medium">Controls</span>
          </div>
        </button>
        <button v-on:click="selectedTab = 'activity'"
                class="ml-4 px-3 py-2 font-medium text-sm leading-5 rounded-md"
                v-bind:class="{'text-gray-800 bg-gray-200 focus:outline-none focus:bg-gray-200': selectedTab === 'activity','text-gray-600 hover:text-gray-800 focus:outline-none focus:text-gray-800 focus:bg-gray-200': selectedTab !== 'activity'  }">
          <div class="flex items-center space-x-2">
            <svg class="h-5 w-5 text-gray-400"
                 viewBox="0 0 20 20"
                 fill="currentColor">
              <path
                    d="M2 11a1 1 0 011-1h2a1 1 0 011 1v5a1 1 0 01-1 1H3a1 1 0 01-1-1v-5zM8 7a1 1 0 011-1h2a1 1 0 011 1v9a1 1 0 01-1 1H9a1 1 0 01-1-1V7zM14 4a1 1 0 011-1h2a1 1 0 011 1v12a1 1 0 01-1 1h-2a1 1 0 01-1-1V4z" />
            </svg>
            <span class="text-sm text-gray-500 leading-5 font-medium">Activity</span>
          </div>
        </button>
      </nav>
    </div>
    <!-- Tab Content -->
    <div>
      <div v-if="selectedTab === 'activity'">
        <CampaignActivity />
      </div>
      <div v-if="selectedTab === 'controls'">
        <ControlsList v-if="controls"
                      :controls="controls" />
      </div>
    </div>
    <CampaignSettings v-show="settingsOpen"
                      @close="settingsToggle"
                      @update="update"
                      :campaign="campaign" />
  </div>
</template>

<script>
  import moment from 'moment'
  import Chart from '../shared/BarChartChartjs'
  import CampaignSettings from './CampaignSettings'
  import CampaignActivity from './CampaignActivity'
  import ControlsList from '../control/ControlsList'

  export default {
    components: {
      Chart,
      CampaignSettings,
      CampaignActivity,
      ControlsList
    },
    mounted() {
      this.loadControls()
      this.loadResults()
    },
    methods: {
      formattedTimestamp(utc) {
        let date = new Date(utc)
        return moment(date).format("MMM D")
      },
      settingsToggle() {
        this.settingsOpen = !this.settingsOpen
      },
      update(res) {
        this.campaign = res.data
        this.settingsOpen = false
      },
      loadControls() {
        let id = this.$route.params.campaign_id
        let url = `/campaigns/${id}`

        this.$http.get(url)
          .then(res => {
            this.campaign = res.data
            this.controls = res
              .data
              .data
              .attributes
              .controls
              .data.map(x => x.attributes)
          })
          .catch(e => {
            console.info(e)
          })
      },
      loadResults() {
        let id = this.$route.params.campaign_id
        let url = `/campaigns/${id}/results`
        let resultsHash = {}

        this.$http.get(url)
          .then(res => {
            // extract results
            res.data.data.map(r => {
              let result = r.attributes

              // add to total
              if (resultsHash[result.job_id]) {
                resultsHash[result.job_id] = {
                  timestamp: result.observed_at,
                  controls_total: resultsHash[result.job_id].controls_total +
                    1,
                  controls_failed: resultsHash[result.job_id].controls_failed +
                    (result.data.status === -1 ? 1 : 0), // record a failed control
                  resources_total: resultsHash[result.job_id].resources_total +
                    result.data.resources_total, // record total resources
                  resources_failed: resultsHash[result.job_id].resources_failed +
                    (result.data.status === -1 ? result.data.resources_failed :
                      0) // record failed resources
                }
              } else {
                // store new
                resultsHash[result.job_id] = {
                  timestamp: result.observed_at,
                  controls_total: 1,
                  controls_failed: result.data.status === -1 ? 1 : 0,
                  resources_total: result.data.resources_total,
                  resources_failed: result.data.resources_failed
                }
              }
            })


            // put the results hashes in an array for sorting and charting
            this.results = Object.keys(resultsHash).map(j => resultsHash[j]).sort((a, b) => (a
              .timestamp > b.timestamp ? 1 : -1))

            // populate chart data and labels
            let days = Object.keys(resultsHash).length
            let span = 90 // chart time window in days
            let results = Array(span).fill(0)
            let labels = Array(span).fill('-')

            console.log('r', this.results)
            // bar data
            this.results
              .map(x => results.push(x.controls_failed))
            this.chartData.data = results.slice(days, results.length)

            // X axis labels
            this.results
              .map(x => labels.push(this.formattedTimestamp(x.timestamp)))
            this.chartData.labels = labels.slice(days, labels.length)

            this.loaded = true
          })
      }
    },
    data() {
      return {
        loaded: false,
        selectedTab: 'controls',
        settingsOpen: false,
        campaign: null,
        controls: null,
        results: [],
        chartData: {
          data: [],
          labels: []
        },
      }
    }
  }

</script>
