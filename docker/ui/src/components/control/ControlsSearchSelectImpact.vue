<template>
  <div class="space-y-1">
    <label class="block text-sm leading-5 font-medium text-gray-700"
           id="listbox-label">
      Impact
    </label>
    <div class="relative">
      <span class="inline-block w-full rounded-md shadow-sm">
        <button @click="toggle"
                @blur="blur"
                type="button"
                class="cursor-default relative w-48 rounded-md border border-gray-300 bg-white pl-3 pr-10 py-2 text-left focus:outline-none focus:shadow-outline-blue focus:border-blue-300 transition ease-in-out duration-150 sm:text-sm sm:leading-5">
          <div class="flex items-center space-x-3">
            <span class="flex-shrink-0 inline-block h-2 w-2 rounded-full"
                  :class="`${impacts[selectedImpact].color}`"></span>
            <span class="block truncate">
              {{ impacts[selectedImpact].name }}
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
            role="listbox">
          <li class="text-gray-900 hover:bg-cool-gray-100 cursor-default select-none relative py-2 pl-3 pr-9"
              role="option"
              v-for="(impact, idx) in impacts"
              :key="idx"
              :id="`listbox-item-${idx}`"
              @click="selectedImpact = idx">
            <div class="flex items-center space-x-3">
              <span class="flex-shrink-0 inline-block h-2 w-2 rounded-full"
                    :class="`${impact.color}`"></span>
              <span v-if="idx !== selectedImpact"
                    class="font-normal block truncate">
                {{ impact.name }}
              </span>
              <span v-if="idx === selectedImpact"
                    class="font-semibold block truncate">
                {{ impact.name }}
              </span>
              <span v-if="idx === selectedImpact"
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
            </div>
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
      },
    },
    watch: {
      selectedImpact() {
        this.$emit('update-impact-filter', this.impacts[this.selectedImpact].value)
        this.isOpen = false
      }
    },
    data() {
      return {
        impacts: [{
            name: 'Any',
            value: 'any',
            color: 'bg-gray-300'
          },
          {
            name: 'Critical',
            value: 'critical',
            color: 'bg-pink-500'
          },
          {
            name: 'High',
            value: 'high',
            color: 'bg-orange-400'
          },
          {
            name: 'Moderate',
            value: 'moderate',
            color: 'bg-yellow-400'
          },
          {
            name: 'Low',
            value: 'low',
            color: 'bg-green-400'
          },
        ],
        selectedImpact: 0,
        isOpen: false
      }
    }
  }

</script>
