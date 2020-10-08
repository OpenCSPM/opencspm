<template>
  <div class="space-y-8">
    <!-- Data Sources -->
    <div>
      <div class="bg-white px-4 py-5 border-b border-gray-200 sm:px-6">
        <div class="-ml-4 -mt-2 flex items-center justify-between flex-wrap sm:flex-no-wrap">
          <div class="ml-4 mt-2">
            <h3 class="text-lg leading-6 font-medium text-gray-900">
              Data Sources
            </h3>
          </div>
        </div>
      </div>
      <div class="bg-white">
        <DataSources v-for="(source, idx) in sources" :key="idx" :source="source" />
      </div>
    </div>

  </div>
</template>

<script>
  import xhr from 'axios'
  import DataSources from './settings/DataSources'

  export default {
    components: {
      DataSources
    },
    mounted: function () {
      let url = '/sources'

      xhr.get(url)
        .then(res => {
          this.sources = res.data
        })
        .catch(() => {})
    },
    data() {
      return {
        sources: []
      }
    }
  }

</script>
