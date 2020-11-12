<template>
  <div @click="$emit('close-tag-search-dropdown')"
       class="flex bg-cool-gray-100">
    <div class="flex-1 focus:outline-none"
         tabindex="0">
      <div
           class="relative flex-shrink-0 flex h-16 bg-white border-b border-gray-200 lg:border-none">
        <button class="px-4 border-r border-cool-gray-200 text-cool-gray-400 focus:outline-none focus:bg-cool-gray-100 focus:text-cool-gray-600 lg:hidden"
                aria-label="Open sidebar">
          <svg class="h-6 w-6 transition ease-in-out duration-150"
               fill="none"
               viewBox="0 0 24 24"
               stroke="currentColor">
            <path stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M4 6h16M4 12h8m-8 6h16" />
          </svg>
        </button>
        <!-- Search bar -->
        <div class="flex-1 px-4 flex justify-between sm:px-6">
          <div class="flex-1 flex">
            <form class="w-full flex md:ml-0"
                  action="#"
                  method="GET">
              <label class="sr-only"
                     for="search_field">Search</label>
              <div class="relative w-full text-cool-gray-400 focus-within:text-cool-gray-600">
                <div class="absolute inset-y-0 left-0 flex items-center pointer-events-none">
                  <svg class="h-5 w-5"
                       fill="currentColor"
                       viewBox="0 0 20 20">
                    <path fill-rule="evenodd"
                          clip-rule="evenodd"
                          d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z" />
                  </svg>
                </div>
                <input class="block w-full h-full pl-8 pr-3 py-2 rounded-md text-md text-cool-gray-600 font-medium placeholder-cool-gray-500 focus:outline-none focus:placeholder-cool-gray-400"
                       id="search_field"
                       v-model="search"
                       placeholder="Search controls"
                       type="search" />
              </div>
            </form>
            <div class="w-64 flex items-center">
              <CampaignDropdown v-if="controls"
                                :controls="controls"
                                :filters="filters" />
            </div>
          </div>
        </div>
      </div>
      <section class="flex-1 relative">
        <!-- Control filter dropdowns -->
        <div class="bg-white">
          <div class="px-6">
            <div class="py-6 flex items-center justify-between border-t border-cool-gray-200">
              <div class="flex space-x-4">
                <SelectStatus @update-status-filter="updateStatusFilter" />
                <SelectImpact @update-impact-filter="updateImpactFilter" />
                <SelectTags :availableTags="availableTags"
                            :selectedTags="selectedTags"
                            :tagSearchDropdown="tagSearchDropdown"
                            :tagMode="filters.tag_mode"
                            @add-tag="addTag"
                            @remove-tag="removeTag"
                            @toggle-tag-mode="toggleTagMode" />
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>
  </div>
</template>

<script>
  import CampaignDropdown from '../campaign/CampaignDropdown'
  import SelectStatus from './ControlsSearchSelectStatus'
  import SelectImpact from './ControlsSearchSelectImpact'
  import SelectTags from './ControlsSearchSelectTags'

  export default {
    props: ['filters', 'availableTags', 'queryTags', 'selectedTags', 'tagSearchDropdown',
      'controls'
    ],
    components: {
      CampaignDropdown,
      SelectStatus,
      SelectImpact,
      SelectTags
    },
    methods: {
      addTag(t) {
        this.$emit('add-tag', t)
      },
      removeTag(t) {
        this.$emit('remove-tag', t)
      },
      toggleTagMode() {
        this.$emit('toggle-tag-mode')
      },
      updateStatusFilter(f) {
        this.$emit('update-status-filter', f)
      },
      updateImpactFilter(f) {
        this.$emit('update-impact-filter', f)
      }
    },
    watch: {
      search() {
        this.$emit('update-search-filter', this.search)
      }
    },
    data() {
      return {
        search: null
      }
    }
  }

</script>
