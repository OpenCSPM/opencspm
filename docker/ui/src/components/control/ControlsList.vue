<template>
  <div @click="$emit('close-tag-search-dropdown')">
    <div class="sm:block">
      <div class="align-middle inline-block min-w-full border-b border-gray-200">
        <table class="min-w-full">
          <thead>
            <tr class="border-t border-gray-200">
              <th
                  class="items-center px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                <span class="ml-4">Control ({{ controls.length }})</span>
              </th>
              <th
                  class="px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                Impact
              </th>
              <th
                  class="px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                Resources
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-100">
            <tr class="hover:bg-gray-50"
                v-for="(control, idx) in controls"
                :key="idx">
              <td class="px-3 py-3 whitespace-no-wrap group">
                <div class="pl-2 flex items-start space-x-3">
                  <div class="space-y-4">
                    <div class="mt-1 flex-shrink-0 w-2.5 h-2.5 rounded-full"
                         :class="{
                        'bg-gray-200': control.status === 'unknown',
                        'bg-red-400': control.status === 'failed',
                        'bg-green-400': control.status === 'passed'
                      }"></div>
                  </div>
                  <span
                        class="truncate text-sm leading-5 font-medium text-gray-700 hover:text-gray-600">
                    <div class="cursor-pointer"
                         @click="openModal(control.id)">
                      {{ control.title }}
                    </div>
                    <div class="flex items-center space-x-4">
                      <span class="mt-2 inline-flex items-center px-2 py-0.5 rounded text-xs font-medium leading-4 bg-gray-100 text-gray-600"
                            @click="openModal(control.id)">
                        {{ control.control_id }}
                      </span>
                      <div class="flex flex-wrap space-y-2 invisible group-hover:visible">
                        <div></div>
                        <Tag v-for="(tag, idx) in control.tag_map.filter(t => t.primary).sort((a,b) => a.tag.length - b.tag.length).slice(0,5)"
                             :key="idx"
                             :tag="tag.tag"
                             action="add"
                             class="cursor-pointer"
                             @add-tag="addTag">
                          {{ tag.tag }}
                        </Tag>
                      </div>
                    </div>
                  </span>
                </div>
              </td>
              <td class="px-6 py-3 text-sm leading-5 text-gray-500 font-medium">
                <span v-if="control.status === 'failed'">
                  <span v-if="control.impact > 7"
                        class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium leading-4 bg-pink-100 text-pink-800">
                    {{ statusText[control.impact] }}
                  </span>
                  <span v-if="control.impact >= 4 && control.impact <= 7"
                        class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium leading-4 bg-orange-100 text-orange-800">
                    {{ statusText[control.impact] }}
                  </span>
                  <span v-if="control.impact < 4"
                        class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium leading-4 bg-gray-100 text-gray-800">
                    {{ statusText[control.impact] }}
                  </span>
                </span>
                <span v-if="control.status === 'passed'">
                  <span
                        class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium leading-4 bg-gray-100 text-gray-500">
                    {{ statusText[control.impact] }}
                  </span>
                </span>
              </td>
              <td class="px-6 py-3 text-sm leading-5 text-gray-500 font-medium">
                <span
                      class="w-full inline-flex items-center py-0.5 rounded text-xs font-medium leading-4 text-gray-500">
                  <span class="inline-flex items-center w-full h-1 bg-gray-200 rounded-full">
                    <span v-if="control.status !== 'passed'"
                          class="px-0.5 py-px h-1 text-xs font-bold text-indigo-100 uppercase bg-indigo-500 rounded-full"
                          :style="control | progress"></span>
                  </span>
                  <span class="h-4 w-12">
                    <span class="resources-affected ml-1 whitespace-no-wrap">
                      {{ control.resources_failed }} /
                      {{ control.resources_total }}
                    </span>
                  </span>
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <control-modal v-if="modalIsOpen"
                   @close-modal="closeModal"
                   :control="selectedControl" />
  </div>
</template>

<script>
  import Tag from '../shared/Tag'
  import ControlModal from './ControlModal'

  export default {
    props: ['controls'],
    components: {
      Tag,
      ControlModal
    },
    computed: {
      randomItem() {
        let item = this.titles[Math.floor(Math.random() * this.titles.length)]
        return item
      }
    },
    filters: {
      // calc percentage of affected resources failed for progress bar
      progress: f => {
        let pct

        if (f.resources_total > 0) {
          pct = (f.resources_failed / f.resources_total) * 100
        } else {
          pct = 0
        }

        return `width: ${pct}%;`
      }
    },
    methods: {
      addTag(t) {
        this.$emit('add-tag', t)
      },
      openModal(id) {
        this.selectedControl = this.controls.filter(x => x.id === id)[0]
        this.modalIsOpen = true
      },
      closeModal() {
        this.modalIsOpen = false
      },
      affectedResources(resources) {
        let affected = resources.filter(x => x.status !== 'passed')

        return `${affected.length} / ${resources.length}`
      }
    },
    watch: {},
    data() {
      return {
        modalIsOpen: false,
        selectedControl: null,
        statusText: {
          1: 'Low',
          2: 'Low',
          3: 'Low',
          4: 'Moderate',
          5: 'Moderate',
          6: 'Moderate',
          7: 'Moderate',
          8: 'High',
          9: 'High',
          10: 'Critical'
        }
      }
    }
  }

</script>
