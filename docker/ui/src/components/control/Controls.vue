<template>
  <div>
    <ControlsSearch :availableTags="availableTags"
                    :selectedTags="selectedTags"
                    :tagSearchDropdown="tagSearchDropdown"
                    :controls="filteredControls"
                    :filters="filters"
                    @close-tag-search-dropdown="closeTagSearchDropdown"
                    @update-search-filter="updateSearchFilter"
                    @update-status-filter="updateStatusFilter"
                    @update-impact-filter="updateImpactFilter"
                    @add-tag="addTag"
                    @remove-tag="removeTag"
                    @toggle-tag-mode="toggleTagMode" />
    <ControlsList v-if="filteredControls"
                  :controls="filteredControls"
                  @close-tag-search-dropdown="closeTagSearchDropdown"
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
            let term = c.title.toLowerCase() + c.control_id.toLowerCase()
            // let term = c.title.toLowerCase()
            return term.indexOf(this.filters.search.toLowerCase()) !== -1
          })

          return results
        } else {
          return controls
        }
      },
      /**
       * Return controls that match the selected Status
       *
       * @return {Array} filtered controls
       */
      applyStatusFilter() {
        let controls = this.applySearchFilter()
        let status = this.filters.status

        if (status !== 'any') {
          return controls.filter(c => {
            return c.status === status
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
        let controls = this.applyStatusFilter()
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
              this.selectedTags.some(t => c.tag_map.map(m => m.tag).includes(t)) :
              this.selectedTags.every(t => c.tag_map.map(m => m.tag).includes(t))
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
              .map(x => x.attributes.tag_map.map(x => x.tag))
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
       * Handle Status filter update event
       */
      updateStatusFilter(f) {
        this.filters.status = f
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
          this.$route.query.tags.split(',').map(x => x.toLowerCase()) : []
      },
      /**
       * Trigger an update to close the tag search dropdown
       */
      closeTagSearchDropdown() {
        this.tagSearchDropdown = Date.now()
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
        tagSearchDropdown: Date.now(),
        filters: {
          search: null,
          status: 'any',
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
