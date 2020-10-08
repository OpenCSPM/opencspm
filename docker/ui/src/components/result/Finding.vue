<template>
  <tr class="hover:bg-gray-50">
    <td class="px-6 py-4 w-1/2 whitespace-no-wrap border-b border-gray-200">
      <div class="flex items-center">
        <div class="can-filter">
          <div v-on:click="openModal" class="text-sm leading-5 font-medium text-gray-700 cursor-pointer">
            {{ finding.title }}
          </div>
          <div class="flex">
            <div v-on:click="$emit('filter', {type: 'category', term: finding.category })"
              class="text-xs leading-5 text-gray-500 cursor-pointer">
              {{ finding.category }}
            </div>
            <IconFilter />
          </div>
        </div>
      </div>
    </td>
    <td class="px-6 py-3 whitespace-no-wrap border-b border-gray-200">
      <div class="flex can-filter">
        <div v-on:click="$emit('filter', {type: 'platform', term: finding.platform })"
          class="text-sm leading-5 text-gray-700 cursor-pointer">{{ finding.platform }}
        </div>
        <IconFilter />
      </div>
      <div class="flex can-filter">
        <div v-on:click="$emit('filter', {type: 'resource', term: finding.resource })"
          class="text-xs leading-5 text-gray-500 cursor-pointer">{{ finding.resource }}
        </div>
        <IconFilter />
      </div>
    </td>
    <td class="px-2 py-2 whitespace-no-wrap border-b border-gray-200">
      <div v-on:click="openModal" class='cursor-pointer'>
        <div class="">
          <div class="flex">
            <span class="w-full inline-flex items-center py-0.5 rounded text-xs font-medium leading-4 text-gray-500">
              <span class="inline-flex items-center w-full h-1 bg-gray-200 rounded-full">
                <span v-if="finding.result.status !== 'passed'"
                  class="px-0.5 py-px h-1 text-xs font-bold text-indigo-100 uppercase bg-indigo-700 rounded-full"
                  :style="finding | progress">
                </span>
              </span>
              <span v-if="finding.result.total - finding.result.passed > 0" class="h-4">
                <span class="resources-affected ml-1">
                  {{ finding.result.total - finding.result.passed }} / {{ finding.result.total}}
                </span>
              </span>
            </span>
          </div>
        </div>
      </div>
    </td>
    <td class="px-6 py-3 whitespace-no-wrap border-b border-gray-200 text-sm leading-5 text-gray-500">
      <div class="flex can-filter">
        <div class="w-16">
          <span v-on:click="$emit('filter', {type: 'status', term: 'passed' })"
            v-if="finding.result.status === 'passed'"
            class="w-full inline-flex justify-center px-2 py-0.5 rounded text-xs font-medium leading-4 bg-green-100 text-green-800 cursor-pointer">
            pass
          </span>
          <span v-on:click="$emit('filter', {type: 'status', term: 'failed' })"
            v-if="finding.result.status === 'failed'"
            class="w-full inline-flex justify-center px-2 py-0.5 rounded text-xs font-medium leading-4 bg-red-100 text-red-800 cursor-pointer">
            fail
          </span>
        </div>
        <IconFilter />
      </div>
    </td>
    <td class="px-6 py-3 whitespace-no-wrap border-b border-gray-200 text-sm leading-5 font-medium">
      <div class="flex can-filter">
        <div class="w-16">
          <span v-on:click="$emit('filter', {type: 'severity', term: 'high' })"
            v-if="finding.severity >= threshold.severity.high"
            class="w-full inline-flex justify-center px-2 py-0.5 rounded text-xs font-medium leading-4 bg-red-100 text-red-800 cursor-pointer">
            high
          </span>
          <span v-on:click="$emit('filter', {type: 'severity', term: 'medium' })"
            v-if="finding.severity >= threshold.severity.medium && finding.severity < threshold.severity.high"
            class="w-full inline-flex justify-center px-2 py-0.5 rounded text-xs font-medium leading-4 bg-yellow-100 text-yellow-800 cursor-pointer">
            medium
          </span>
          <span v-on:click="$emit('filter', {type: 'severity', term: 'low' })"
            v-if="finding.severity < threshold.severity.medium"
            class="w-full inline-flex justify-center px-2 py-0.5 rounded text-xs font-medium leading-4 bg-gray-100 text-gray-800 cursor-pointer">
            low
          </span>
        </div>
        <IconFilter />
      </div>
    </td>
  </tr>
</template>

<script>
  import IconFilter from '../shared/IconFilter'

  export default {
    props: ['finding', 'threshold'],
    components: {
      IconFilter
    },
    methods: {
      openModal() {
        // console.log(`fired ${this.finding.finding}`)
        this.$emit('selected', this.finding.finding)
      }
    },
    filters: {
      // calc percentage of affected resources failed for progress bar
      progress: f => {
        let pct

        if (f.result.total > 0) {
          pct = ((f.result.total - f.result.passed) / f.result.total) * 100
        } else {
          pct = 0
        }

        return `width: ${pct}%;`
      }
    }
  }
</script>
