<template>
  <div class="h-screen flex overflow-hidden bg-white">
    <!-- Main column -->
    <div class="flex flex-col w-0 flex-1 overflow-hidden">
      <main class="flex-1 relative z-0 overflow-y-auto focus:outline-none"
            tabindex="0">
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
                  Campaigns
                </h3>
                <div class="mt-2 text-sm leading-5 text-indigo-700">
                  <p>
                    Campaigns allow you to track the progress of controls you care about.
                  </p>
                </div>
              </div>
              <div class="ml-auto pl-3">
                <div class="-mx-1.5 -my-1.5">
                  <button @click="hideCampaignTip"
                          class="inline-flex rounded-md p-1.5 text-indigo-500 hover:bg-indigo-100 focus:outline-none focus:bg-indigo-100 transition ease-in-out duration-150"
                          aria-label="Dismiss">
                    <!-- Heroicon name: x -->
                    <svg class="h-5 w-5"
                         xmlns="http://www.w3.org/2000/svg"
                         viewBox="0 0 20 20"
                         fill="currentColor">
                      <path fill-rule="evenodd"
                            clip-rule="evenodd"
                            d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" />
                    </svg>
                  </button>
                </div>
              </div>
            </div>
          </div>

        </div>
        <div class="mt-0">
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
                      class="table-cell px-6 py-3 whitespace-no-wrap border-b border-gray-200 bg-gray-50 text-right text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                    Last Changed
                  </th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-100">
                <tr v-for="campaign in campaigns"
                    :key="campaign.id">
                  <td
                      class="px-6 py-3 max-w-0 w-full whitespace-no-wrap text-sm leading-5 font-medium text-gray-900">
                    <div class="flex items-center space-x-3 lg:pl-2">
                      <div class="flex-shrink-0 w-2.5 h-2.5 rounded-full bg-indigo-400">
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
                            class="mx-auto flex-shrink-0 text-xs text-center leading-5 font-medium">{{ campaign.control_count }}</span>
                    </div>
                  </td>
                  <td
                      class="table-cell px-6 py-3 whitespace-no-wrap text-sm leading-5 text-gray-500 text-right">
                    {{ campaign.updated_at | moment }}
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
  import moment from 'moment'

  export default {
    methods: {
      loadCampaigns: function() {
        let url = '/campaigns'

        this.$http.get(url)
          .then(resp => {
            this.campaigns = resp.data.data.map(x => x.attributes)
          })
      },
      hideCampaignTip: function() {
        localStorage.show_tip_campaigns = false
        this.showTip = false
      },
      loadCampaignTip: function() {
        this.showTip = localStorage.show_tip_campaigns ? false : true
      }
    },
    filters: {
      moment: function(value) {
        return moment(value).fromNow()
      }
    },
    mounted() {
      this.loadCampaignTip()
      this.loadCampaigns()
    },
    data() {
      return {
        showTip: true,
        campaigns: []
      }
    }
  }

</script>
