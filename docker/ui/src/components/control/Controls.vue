<template>
  <div>
    <ControlsSearch :availableTags="availableTags"
                    :selectedTags="selectedTags"
                    :controls="filteredControls"
                    :filters="filters"
                    @update-search-filter="updateSearchFilter"
                    @update-platform-filter="updatePlatformFilter"
                    @update-impact-filter="updateImpactFilter"
                    @add-tag="addTag"
                    @remove-tag="removeTag"
                    @toggle-tag-mode="toggleTagMode" />
    <ControlsList v-if="filteredControls"
                  :controls="filteredControls"
                  @add-tag="addTag" />
  </div>
</template>

<script>
  import ControlsSearch from './ControlsSearch'
  import ControlsList from './ControlsList'

  export default {
    components: {
      ControlsSearch,
      ControlsList
    },
    methods: {
      /**
       * Return controls that match the selected search string
       *
       * @return {Array} filtered controls
       */
      applySearchFilter() {
        let controls = this.controls

        if (this.filters.search && this.filters.search.length > 1) {
          let results = controls.filter(c => {
            // TODO: search on title OR description
            // let term = c.title.toLowerCase() + c.description.toLowerCase()
            let term = c.title.toLowerCase()
            return term.indexOf(this.filters.search.toLowerCase()) !== -1
          })

          return results
        } else {
          return controls
        }
      },
      /**
       * Return controls that match the selected Platform type
       *
       * @return {Array} filtered controls
       */
      applyPlatformFilter() {
        let controls = this.applySearchFilter()
        let platform = this.filters.platform

        if (platform !== 'any') {
          return controls.filter(c => {
            return c.platform === platform
          })
        } else {
          return controls
        }
      },
      /**
       * Return controls that match the selected Impact level
       *
       * @return {Array} filtered controls
       */
      applyImpactFilter() {
        let controls = this.applyPlatformFilter()
        let impact = this.filters.impact

        if (impact !== 'any') {
          return controls.filter(c => {
            if (impact === 'critical') return c.impact > 9
            if (impact === 'high') return c.impact < 10 === c.impact > 7
            if (impact === 'moderate') return c.impact < 8 === c.impact > 3
            if (impact === 'low') return c.impact < 4
          })
        } else {
          return controls
        }
      },
      /**
       * Return controls that match the selected tags
       *
       * @return {Array} filtered controls
       */
      applyTagsFilter() {
        let controls = this.applyImpactFilter()

        if (this.selectedTags.length > 0) {
          return controls.filter(c => {
            return this.filters.tag_mode === 'any' ?
              this.selectedTags.some(t => c.tags.includes(t)) :
              this.selectedTags.every(t => c.tags.includes(t))
          })
        } else {
          return controls
        }
      },
      /**
       * Start applying the filter chain
       */
      applyFilters() {
        this.filteredControls = this.applyTagsFilter()
      },
      addTag(t) {
        console.log('adding tag', t)
        if (!this.selectedTags.includes(t)) {
          this.selectedTags.push(t)
        }
      },
      removeTag(t) {
        this.selectedTags = this.selectedTags.filter(x => x !== t)
      },
      /**
       * Load all controls from API server
       */
      loadControls() {
        let url = '/controls'

        this.$http.get(url).then(res => {
          this.controls = res.data.data.map(x => x.attributes)
          this.availableTags = [
            ...new Set(
              res.data.data
              .map(x => x.attributes)
              .map(x => x.tags)
              .flat()
            )
          ]
        })
      },
      /**
       *
       */
      toggleTagMode() {
        if (this.filters.tag_mode === 'any') {
          this.filters.tag_mode = 'all'
        } else {
          this.filters.tag_mode = 'any'
        }

        this.applyFilters()
      },
      /**
       * Handle Search filter update event
       */
      updateSearchFilter(f) {
        this.filters.search = f
        this.applyFilters()
      },
      /**
       * Handle Platform filter update event
       */
      updatePlatformFilter(f) {
        this.filters.platform = f
        this.applyFilters()
      },
      /**
       * Handle Impact filter update event
       */
      updateImpactFilter(f) {
        this.filters.impact = f
        this.applyFilters()
      },
      /**
       * Parse tags passed in through querystring so they are added to the filters
       */
      updateQueryTags() {
        this.selectedTags = this.$route.query.tags ?
          this.$route.query.tags.split(',').map(x => x.toLowerCase()) :
          []
      }
    },
    mounted() {
      this.loadControls()
      this.updateQueryTags()
    },
    watch: {
      controls() {
        this.applyFilters()
      },
      selectedTags() {
        this.filters.tags = this.selectedTags
        this.applyFilters()
      }
    },
    data() {
      return {
        availableTags: [],
        selectedTags: [],
        filters: {
          search: null,
          platform: 'any',
          impact: 'any',
          tags: [],
          tag_mode: 'any'
        },
        controls: null,
        filteredControls: null
      }
    }
  }

</script>
