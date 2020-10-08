<template>
  <div>

    <div class="mb-4">
      <nav class="hidden sm:flex items-center text-sm leading-5 font-medium">
        <router-link to="/policies"
          class="text-gray-500 hover:text-gray-700 transition duration-150 ease-in-out">Campaigns
        </router-link>
        <svg class="flex-shrink-0 mx-2 h-5 w-5 text-gray-400" viewBox="0 0 20 20"
          fill="currentColor">
          <path fill-rule="evenodd"
            d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z"
            clip-rule="evenodd" />
        </svg>
        <a href="#"
          class="text-gray-500 hover:text-gray-700 transition duration-150 ease-in-out">Google
          Cloud IAM Escalation</a>
        <svg class="flex-shrink-0 mx-2 h-5 w-5 text-gray-400" viewBox="0 0 20 20"
          fill="currentColor">
          <path fill-rule="evenodd"
            d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z"
            clip-rule="evenodd" />
        </svg>
        <a href="#"
          class="text-gray-500 hover:text-gray-700 transition duration-150 ease-in-out">Issues</a>
      </nav>
    </div>

    <div id="scroll-anchor"></div>
    <div v-if="findings">
      <div class="w-full mb-4">
        <div class="space-x-4">
          <template v-for="(filter, idx) in filters">
            <span :key="idx" v-on:click="removeFilterTerm(filter.type)"
              class="filter-tag inline-flex items-center pl-1 pr-2 mb-3 bg-indigo-100 rounded-full cursor-pointer">
              <span
                class="px-2 py-px mr-2 text-xs font-bold text-indigo-100 uppercase bg-indigo-700 rounded-full">{{ filter.type }}</span>
              <span class="text-sm leading-loose text-indigo-800">{{ filter.term }}</span>
              <span class="remove-filter-icon hidden">
                <svg class="w-3 h-3 ml-1 text-gray-500" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd"
                    d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z"
                    clip-rule="evenodd"></path>
                </svg>
              </span>
            </span>
          </template>
        </div>
      </div>
      <div class="flex justify-between">
        <div class="w-full">
          <div class="mb-4 flex rounded-md shadow-sm">
            <input v-on:keyup.esc="clearSearch" v-on:keyup="showResults" v-model="searchTerms"
              class="form-input flex-1 block w-full rounded-none rounded-md transition duration-150 ease-in-out sm:text-sm sm:leading-5 text-gray-600"
              placeholder="search terms (esc to clear)" />
          </div>
        </div>
        <div class="w-48 text-right">
          <div v-if="!exportable" class="relative inline-block text-left">
            <div>
              <span class="rounded-md shadow-sm">
                <button v-on:click="toggleDropdown" type="button"
                  class="inline-flex justify-center w-full rounded-md border border-gray-300 px-4 py-2 bg-white text-sm leading-5 font-medium text-gray-700 hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue active:bg-gray-50 active:text-gray-800 transition ease-in-out duration-150"
                  id="options-menu" aria-haspopup="true" aria-expanded="true">
                  Export to
                  <svg class="-mr-1 ml-2 h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                    <path fill-rule="evenodd"
                      d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z"
                      clip-rule="evenodd" />
                  </svg>
                </button>
              </span>
            </div>
            <transition name="dropdown" enter-active-class="transition ease-out duration-100"
              enter-class="transform opacity-0 scale-95"
              enter-to-class="transform opacity-100 scale-100"
              leave-active-class="transition ease-in duration-75"
              leave-class="transform opacity-100 scale-100"
              leave-to-class="transform opacity-0 scale-95">
              <div v-if="dropdownIsOpen"
                class="origin-top-right absolute right-0 mt-2 w-56 rounded-md shadow-lg">
                <div class="rounded-md bg-white shadow-xs">
                  <div class="py-1" role="menu" aria-orientation="vertical"
                    aria-labelledby="options-menu">
                    <div
                      class="block px-4 py-2 text-sm leading-5 text-gray-700 hover:bg-gray-100 hover:text-gray-900 focus:outline-none focus:bg-gray-100 focus:text-gray-900">
                      <div class="flex px-4 py-2 items-center space-x-3 lg:pl-2">
                        <div class="flex-shrink-0 w-2.5 h-2.5 rounded-full bg-gray-300"></div>
                        <router-link to="/campaigns/1" class="truncate hover:text-gray-600">
                          <span>Google Cloud CIS 1.1</span>
                        </router-link>
                      </div>
                    </div>
                    <div
                      class="block px-4 py-2 text-sm leading-5 text-gray-700 hover:bg-blue-100 hover:text-gray-900 focus:outline-none focus:bg-gray-100 focus:text-gray-900">
                      <div class="flex px-4 py-2 items-center space-x-3 lg:pl-2">
                        <div class="flex-shrink-0 w-2.5 h-2.5 rounded-full bg-blue-300"></div>
                        <router-link to="/campaigns/1" class="truncate hover:text-gray-600">
                          <span>Public Resources</span>
                        </router-link>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </transition>
          </div>
          <div v-if="exportable" class="relative inline-block text-left">
            <div>
              <span class="rounded-md shadow-sm">
                <button v-on:click="toggleDropdown" type="button"
                  class="inline-flex justify-center w-full rounded-md border border-gray-300 px-4 py-2 bg-white text-sm leading-5 font-medium text-gray-700 hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue active:bg-gray-50 active:text-gray-800 transition ease-in-out duration-150"
                  id="options-menu" aria-haspopup="true" aria-expanded="true">
                  Export ({{ filteredFindings.length }})
                  <svg class="-mr-1 ml-2 h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                    <path fill-rule="evenodd"
                      d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z"
                      clip-rule="evenodd" />
                  </svg>
                </button>
              </span>
            </div>
            <transition name="dropdown" enter-active-class="transition ease-out duration-100"
              enter-class="transform opacity-0 scale-95"
              enter-to-class="transform opacity-100 scale-100"
              leave-active-class="transition ease-in duration-75"
              leave-class="transform opacity-100 scale-100"
              leave-to-class="transform opacity-0 scale-95">
              <div v-if="dropdownIsOpen"
                class="origin-top-right absolute right-0 mt-2 w-56 rounded-md shadow-lg">
                <div class="rounded-md bg-white shadow-xs">
                  <div class="py-1" role="menu" aria-orientation="vertical"
                    aria-labelledby="options-menu">
                    <a :href="this.downloadBlobJSON" download='darkbit_findings.json'
                      class="block px-4 py-2 text-sm leading-5 text-gray-700 hover:bg-gray-100 hover:text-gray-900 focus:outline-none focus:bg-gray-100 focus:text-gray-900"
                      role="menuitem">as JSON
                    </a>
                    <a :href="this.downloadBlobCSV" download='darkbit_findings.csv'
                      class="block px-4 py-2 text-sm leading-5 text-gray-700 hover:bg-gray-100 hover:text-gray-900 focus:outline-none focus:bg-gray-100 focus:text-gray-900"
                      role="menuitem">as CSV
                    </a>
                  </div>
                </div>
              </div>
            </transition>
          </div>
        </div>
      </div>
      <div class="flex flex-col">
        <div class="-my-2 py-2 -mx-8 px-8 overflow-x-auto">
          <div
            class="align-middle inline-block min-w-full shadow overflow-hidden sm:rounded-lg border-b border-gray-200">
            <table class="min-w-full">
              <thead>
                <tr>
                  <th
                    class="px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                    <span class="flex">
                      Issue
                      <span v-on:click="setSortOrder(1)" class="ml-2 cursor-pointer"
                        :class="sortIndicator(1)">
                        <svg class="h-4 w-4" fill="currentColor" viewBox="0 0 20 20">
                          <path
                            d="M5 12a1 1 0 102 0V6.414l1.293 1.293a1 1 0 001.414-1.414l-3-3a1 1 0 00-1.414 0l-3 3a1 1 0 001.414 1.414L5 6.414V12zM15 8a1 1 0 10-2 0v5.586l-1.293-1.293a1 1 0 00-1.414 1.414l3 3a1 1 0 001.414 0l3-3a1 1 0 00-1.414-1.414L15 13.586V8z">
                          </path>
                        </svg>
                      </span>
                    </span>
                  </th>
                  <th
                    class="px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                    <span class="flex">
                      Category
                      <span v-on:click="setSortOrder(2)" class="ml-2 cursor-pointer"
                        :class="sortIndicator(2)">
                        <svg class="h-4 w-4" fill="currentColor" viewBox="0 0 20 20">
                          <path
                            d="M5 12a1 1 0 102 0V6.414l1.293 1.293a1 1 0 001.414-1.414l-3-3a1 1 0 00-1.414 0l-3 3a1 1 0 001.414 1.414L5 6.414V12zM15 8a1 1 0 10-2 0v5.586l-1.293-1.293a1 1 0 00-1.414 1.414l3 3a1 1 0 001.414 0l3-3a1 1 0 00-1.414-1.414L15 13.586V8z">
                          </path>
                        </svg>
                      </span>
                    </span>
                  </th>
                  <th
                    class="pl-2 pr-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                    <span class="flex">
                      Resources
                      <span v-on:click="setSortOrder(3)" class="ml-2 cursor-pointer"
                        :class="sortIndicator(3)">
                        <svg class="h-4 w-4" fill="currentColor" viewBox="0 0 20 20">
                          <path
                            d="M5 12a1 1 0 102 0V6.414l1.293 1.293a1 1 0 001.414-1.414l-3-3a1 1 0 00-1.414 0l-3 3a1 1 0 001.414 1.414L5 6.414V12zM15 8a1 1 0 10-2 0v5.586l-1.293-1.293a1 1 0 00-1.414 1.414l3 3a1 1 0 001.414 0l3-3a1 1 0 00-1.414-1.414L15 13.586V8z">
                          </path>
                        </svg>
                      </span>
                    </span>
                  </th>
                  <th
                    class="px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                    <span class="flex">
                      Status
                      <span v-on:click="setSortOrder(4)" class="ml-2 cursor-pointer"
                        :class="sortIndicator(4)">
                        <svg class="h-4 w-4" fill="currentColor" viewBox="0 0 20 20">
                          <path
                            d="M5 12a1 1 0 102 0V6.414l1.293 1.293a1 1 0 001.414-1.414l-3-3a1 1 0 00-1.414 0l-3 3a1 1 0 001.414 1.414L5 6.414V12zM15 8a1 1 0 10-2 0v5.586l-1.293-1.293a1 1 0 00-1.414 1.414l3 3a1 1 0 001.414 0l3-3a1 1 0 00-1.414-1.414L15 13.586V8z">
                          </path>
                        </svg>
                      </span>
                    </span>
                  </th>
                  <th
                    class="px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                    <span class="flex">
                      Severity
                      <span v-on:click="setSortOrder(5)" class="ml-2 cursor-pointer"
                        :class="sortIndicator(5)">
                        <svg class="h-4 w-4" fill="currentColor" viewBox="0 0 20 20">
                          <path
                            d="M5 12a1 1 0 102 0V6.414l1.293 1.293a1 1 0 001.414-1.414l-3-3a1 1 0 00-1.414 0l-3 3a1 1 0 001.414 1.414L5 6.414V12zM15 8a1 1 0 10-2 0v5.586l-1.293-1.293a1 1 0 00-1.414 1.414l3 3a1 1 0 001.414 0l3-3a1 1 0 00-1.414-1.414L15 13.586V8z">
                          </path>
                        </svg>
                      </span>
                    </span>
                  </th>
                </tr>
              </thead>
              <tbody class="bg-white">
                <Finding v-for="(finding, i) in filteredFindings" :key="i" :finding="finding"
                  :threshold="threshold" @selected="openModal" @filter="addFilterTerm" />
              </tbody>
            </table>
          </div>
        </div>
      </div>
      <Modal :finding="selectedFinding" :isOpen="modalIsOpen" :threshold="threshold"
        @closed="closeModal" />
    </div>
  </div>
</template>

<script>
  import axios from 'axios'
  import Finding from './Finding'
  import Modal from './Modal'

  export default {
    components: {
      Finding,
      Modal
    },
    methods: {
      openModal(id) {
        let finding = this.findings.find(f => f.finding === id)

        if (finding) {
          this.selectedFinding = finding
          this.modalIsOpen = true
        }
      },
      closeModal() {
        this.modalIsOpen = false
      },
      toggleDropdown() {
        this.dropdownIsOpen = !this.dropdownIsOpen
      },
      clearSearch() {
        this.searchTerms = null
      },
      /**
       * Utility method to set resource filter terms
       * (e.g. Category, Platform, and Resource)
       */
      addFilterTerm(opts) {
        // lookup existing filters, if any
        // exclude the type we are currently setting,
        // so there can only be one of that type
        const resourceFilters = this.filters.filter(
          f => f.type !== opts.type
        )
        resourceFilters.push({
          ...opts
        })

        this.filters = resourceFilters

        // update results
        this.showResults()
      },
      /**
       * Utility method to remove resource filter term by type
       * (e.g. Category, Platform, and Resource)
       */
      removeFilterTerm(type) {
        const resourceFilters = this.filters.filter(f => f.type !== type)

        this.filters = resourceFilters

        // updat results
        this.showResults()
      },
      /**
       * Filter findings based on search terms
       * 
       * @return {Array} filterd findings
       */
      applySearchTerms() {
        if (this.searchTerms && this.searchTerms.length > 0) {
          const results = this.findings.filter(finding => {
            let term = finding.description.toLowerCase() + finding.title.toLowerCase()
            return term.indexOf(this.searchTerms.toLowerCase()) !== -1
          })

          return results
        } else {
          return this.findings
        }
      },
      /**
       * Filter findings based on matching filter terms
       * 
       * @return {Array} filtered findings
       */
      applyFilters() {
        const resourceFilters = this.filters
        let resourceFilteredFindings = this.applySearchTerms()

        // iterate through any filters that are set
        resourceFilters.map(filter => {
          resourceFilteredFindings = resourceFilteredFindings.filter(finding => {
            // if filter.type is 'status', check finding.result.status
            // otherwise, check the specific field
            if (filter.type === 'status') return finding.result.status === filter.term

            // if filter.type is 'severity', check severity boundaries
            if (filter.type === 'severity') {
              if (filter.term === 'high') {
                return finding.severity >= this.threshold.severity.high
              }
              if (filter.term === 'medium') {
                return (
                  finding.severity >= this.threshold.severity.medium &&
                  finding.severity < this.threshold.severity.high
                )
              }
              if (filter.term === 'low') {
                return finding.severity < this.threshold.severity.medium
              }
            }

            // for other filters, just match the term
            return finding[filter.type] === filter.term
          })
        })

        return resourceFilteredFindings
      },
      /**
       * Sort findings based on the current sort order 
       * and which column is the active sort column
       * 
       * @return {Array} sorted findings
       */
      applySort() {
        let findings = this.applyFilters()
        // Return if there's no ordering.
        if (this.ordering === this.Order.NONE) return findings

        // Get the property to sort each profile on.
        // By default use the `category` property.
        let propKey = 'category'
        if (this.orderedColumn === 2) propKey = 'category'
        if (this.orderedColumn === 3) propKey = 'resources'
        if (this.orderedColumn === 4) propKey = 'status'
        if (this.orderedColumn === 5) propKey = 'severity'

        let results = findings.sort((a, b) => {
          let aValue, bValue
          // if we are sorting on resources
          // we want resources count, not the
          // field value
          if (propKey === 'resources') {
            aValue = a[propKey].filter(r => r.status === 'failed').length
            bValue = b[propKey].filter(r => r.status === 'failed').length
          } else if (propKey === 'status') {
            aValue = a.result[propKey]
            bValue = b.result[propKey]
          } else {
            aValue = a[propKey]
            bValue = b[propKey]
          }

          // Support string comparison
          const sortTable = {
            true: 1,
            false: -1
          }

          // Order ascending (Order.ASC)
          if (this.ordering === this.Order.ASC) {
            return aValue === bValue ? 0 : sortTable[aValue > bValue]
          }

          // Order descending (Order.DESC)
          return bValue === aValue ? 0 : sortTable[bValue > aValue]
        })

        return results
      },
      /**
       * simple chain of applySearchTerms -> applyFilters -> applySort
       */
      showResults() {
        this.filteredFindings = this.applySort()
        this.buildExportDownloadLinks()
      },
      /**
       * Set sort column and direction
       * 
       * @param {Integer} column to sort on
       */
      setSortOrder(column) {
        let order = this.getSortOrder()
        this.ordering = order
        this.orderedColumn = column

        // update results
        this.showResults()
      },
      /**
       * Get current sort order and toggle it
       * 
       * @return {String} sort direction
       */
      getSortOrder() {
        switch (this.ordering) {
          case this.Order.ASC:
            return this.Order.DESC
          case this.Order.DESC:
            return this.Order.ASC
          default:
            return this.Order.DESC
        }
      },
      /**
       * Return conditional classes for indicator which 
       * column is currently being sorted on
       * 
       * @return {String} class name
       */
      sortIndicator(column) {
        let sortClass = {
          'text-indigo-600': this.orderedColumn === column,
          // 'border-indigo-600': this.orderedColumn === column,
          // 'border-b': this.ordering === 'DESC',
          // 'border-t': this.ordering === 'ASC',
        }

        return sortClass
      },
      /*
       * Build blob download links dynamically, based on current findings view
       */
      buildExportDownloadLinks() {
        const {
          parse
        } = require('json2csv')
        const findings = this.filteredFindings

        if (!findings || findings.length < 1) return

        // make a Blob in JSON format for download
        const dataJSON = new Blob([JSON.stringify(findings, null, 2)], {
          type: 'text/json',
        })

        this.downloadBlobJSON = window.URL.createObjectURL(dataJSON)

        // make a Blob in CSV format for download
        const fields = Object.keys(findings[0] || {})
        const opts = {
          fields
        }
        const csv = parse(findings, opts)
        const dataCSV = new Blob([csv], {
          type: 'text/csv'
        })

        this.downloadBlobCSV = window.URL.createObjectURL(dataCSV)
      },
      loadSampleFindings() {
        this.loading = true
        this.error = this.findings = null

        axios.get('/sample-findings.json').then(res => {
          if (res.data) {
            this.summary = res.data.summary
            this.findings = res.data.results
            this.filteredFindings = res.data.results
            this.buildExportDownloadLinks()
          }
        })
      }
    },
    data() {
      return {
        // temp for testing
        exportable: false,
        loading: false,
        filters: [],
        summary: null,
        findings: null,
        filteredFindings: null,
        selectedFinding: null,
        searchTerms: null,
        modalIsOpen: false,
        dropdownIsOpen: false,
        downloadBlobCSV: null,
        downloadBlobJSON: null,
        ordering: 'NONE',
        orderedColumn: 1,
        threshold: {
          severity: {
            high: 0.8,
            medium: 0.4,
          }
        },
        Order: {
          NONE: 'NONE',
          ASC: 'ASC',
          DESC: 'DESC',
        }
      }
    },
    /**
     * parse props passed from Results
     */
    mounted() {
      this.loadSampleFindings()

      if (process.env.NODE_ENV === 'production') {
        let el = document.getElementById('scroll-anchor')
        el.scrollIntoView()
      }
    }
  }

</script>
