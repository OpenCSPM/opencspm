<template>
  <!--
  Custom select controls like this require a considerable amount of JS to implement from scratch. We're planning
  to build some low-level libraries to make this easier with popular frameworks like React, Vue, and even Alpine.js
  in the near future, but in the mean time we recommend these reference guides when building your implementation:

  https://www.w3.org/TR/wai-aria-practices/#Listbox
  https://www.w3.org/TR/wai-aria-practices/examples/listbox/listbox-collapsible.html
-->
  <div class="space-y-1">
    <label id="listbox-label"
           class="block text-sm leading-5 font-medium text-gray-700">
      Status
    </label>
    <div class="relative">
      <span class="inline-block w-48 rounded-md shadow-sm">
        <button @click="toggle"
                @blur="blur"
                type="button"
                aria-haspopup="listbox"
                aria-expanded="true"
                aria-labelledby="listbox-label"
                class="cursor-default relative w-full rounded-md border border-gray-300 bg-white pl-3 pr-10 py-2 text-left focus:outline-none focus:shadow-outline-blue focus:border-blue-300 transition ease-in-out duration-150 sm:text-sm sm:leading-5">
          <div class="flex items-center space-x-3">
            <span class="flex-shrink-0 inline-block h-2 w-2 rounded-full"
                  :class="`${statuses[selectedStatus].color}`"></span>
            <span class="block truncate">
              {{ statuses[selectedStatus].name }}
            </span>
          </div>
          <span class="absolute inset-y-0 right-0 flex items-center pr-2 pointer-events-none">
            <svg class="h-5 w-5 text-gray-400"
                 viewBox="0 0 20 20"
                 fill="none"
                 stroke="currentColor">
              <path d="M7 7l3-3 3 3m0 6l-3 3-3-3"
                    stroke-width="1.5"
                    stroke-linecap="round"
                    stroke-linejoin="round" />
            </svg>
          </span>
        </button>
      </span>

      <!-- Select popover, show/hide based on select state. -->
      <div class="absolute mt-1 w-full rounded-md bg-white shadow-lg"
           v-if="isOpen">
        <ul class="max-h-60 rounded-md py-1 text-base leading-6 shadow-xs overflow-auto focus:outline-none sm:text-sm sm:leading-5"
            tabindex="-1"
            role="listbox"
            aria-labelledby="listbox-label"
            aria-activedescendant="listbox-item-3">
          <li class="text-gray-900 hover:bg-gray-100 cursor-default select-none relative py-2 pl-3 pr-9"
              v-for="(status, idx) in statuses"
              :key="idx"
              :id="`listbox-option-${idx}`"
              @click="selectedStatus = idx">
            <div class="flex items-center space-x-3">
              <span class="flex-shrink-0 inline-block h-2 w-2 rounded-full"
                    :class="`${status.color}`"></span>
              <span v-if="idx !== selectedStatus"
                    class="font-normal block truncate">
                {{ status.name }}
              </span>
              <span v-if="idx === selectedStatus"
                    class="font-semibold block truncate">
                {{ status.name }}
              </span>
            </div>
            <span v-if="idx === selectedStatus"
                  class="text-indigo-600 absolute inset-y-0 right-0 flex items-center pr-4">
              <!-- Heroicon name: check -->
              <svg class="h-5 w-5"
                   viewBox="0 0 20 20"
                   fill="currentColor">
                <path fill-rule="evenodd"
                      d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
                      clip-rule="evenodd" />
              </svg>
            </span>
          </li>
        </ul>
      </div>
    </div>
  </div>


</template>

<script>
  export default {
    methods: {
      toggle() {
        this.isOpen = !this.isOpen
      },
      blur() {
        setTimeout(() => {
          this.isOpen = false
        }, 250)
      }
    },
    watch: {
      selectedStatus() {
        this.$emit('update-status-filter', this.statuses[this.selectedStatus].value)
        this.isOpen = false
      }
    },
    data() {
      return {
        statuses: [{
            name: 'Any',
            value: 'any',
            color: 'bg-gray-300'
          },
          {
            name: 'Passing',
            value: 'passed',
            color: 'bg-green-400'
          },
          {
            name: 'Failing',
            value: 'failed',
            color: 'bg-red-400'
          },
        ],
        selectedStatus: 0,
        isOpen: false
      }
    }
  }

</script>
