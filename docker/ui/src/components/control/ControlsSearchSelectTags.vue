<template>
  <div>
    <label id="listbox-label"
           class="block text-sm leading-5 font-medium text-gray-700">
      Tags
    </label>
    <div class="flex">
      <div class="mt-1 flex rounded-md shadow-sm">
        <div class="relative flex-grow focus-within:z-10">
          <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
            <svg class="h-5 w-5 text-gray-300"
                 viewBox="0 0 20 20"
                 fill="currentColor">
              <path fill-rule="evenodd"
                    d="M17.707 9.293a1 1 0 010 1.414l-7 7a1 1 0 01-1.414 0l-7-7A.997.997 0 012 10V5a3 3 0 013-3h5c.256 0 .512.098.707.293l7 7zM5 6a1 1 0 100-2 1 1 0 000 2z"
                    clip-rule="evenodd" />
            </svg>
          </div>
          <input id="tag-search"
                 ref="search"
                 v-model="search"
                 @keydown.esc="search = ''"
                 class="form-input pl-10 rounded-none rounded-l-md block w-64 sm:text-sm sm:leading-5"
                 placeholder="type a tag name...">
        </div>
        <button @click="toggleTagMode"
                class="-ml-px relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm leading-5 font-medium rounded-r-md text-gray-500 bg-gray-50 hover:text-gray-500 hover:bg-white focus:outline-none focus:shadow-outline-blue focus:border-blue-300 active:bg-gray-100 active:text-gray-700 transition ease-in-out duration-150">
          <svg v-if="tagMode === 'any'"
               class="h-5 w-5 text-gray-400"
               viewBox="0 0 20 20"
               fill="currentColor">
            <path fill-rule="evenodd"
                  d="M4 4a2 2 0 012-2h4.586A2 2 0 0112 2.586L15.414 6A2 2 0 0116 7.414V16a2 2 0 01-2 2H6a2 2 0 01-2-2V4z"
                  clip-rule="evenodd" />
          </svg>
          <svg v-if="tagMode === 'all'"
               class="h-5 w-5 text-gray-400"
               viewBox="0 0 20 20"
               fill="currentColor">
            <path fill-rule="evenodd"
                  d="M6 2a2 2 0 00-2 2v12a2 2 0 002 2h8a2 2 0 002-2V7.414A2 2 0 0015.414 6L12 2.586A2 2 0 0010.586 2H6zm5 6a1 1 0 10-2 0v2H7a1 1 0 100 2h2v2a1 1 0 102 0v-2h2a1 1 0 100-2h-2V8z"
                  clip-rule="evenodd" />
          </svg>
          <div class="ml-2 capitalize">{{ tagMode }}</div>
        </button>
      </div>
      <div v-show="search.length > 0"
           class="z-10 mt-12 absolute w-80 rounded-md shadow-lg">
        <div v-if="filteredTags.length > 0"
             class="max-h-72 rounded-md bg-white shadow-xs overflow-y-scroll"
             role="menu"
             aria-orientation="vertical"
             aria-labelledby="options-menu">
          <div class="pt-1 pb-2 space-y-2">
            <div v-for="tag in filteredTags"
                 :key="tag"
                 @click="addTag(tag)"
                 class="mx-2 overflow-hidden cursor-pointer">
              <span
                    class="px-2 py-1 rounded text-xs font-medium leading-4 bg-gray-100 text-indigo-800 truncate">
                <span class="inline-flex items-center ">
                  <svg class="mr-1.5 h-2 w-2 text-indigo-400"
                       fill="currentColor"
                       viewBox="0 0 8 8">
                    <circle cx="4"
                            cy="4"
                            r="3" />
                  </svg>
                </span>
                {{ tag }}
              </span>
            </div>
          </div>
        </div>
      </div>
      <div class="flex flex-wrap items-center">
        <Tag v-for="tag in selectedTags"
             :key="tag"
             :tag="tag"
             action="remove"
             @remove-tag="removeTag"
             class="ml-4 cursor-pointer">
          {{ tag }}</Tag>
      </div>
    </div>
  </div>


</template>

<script>
  import Tag from '../shared/Tag'

  export default {
    props: ['availableTags', 'selectedTags', 'tagSearchDropdown', 'tagMode'],
    components: {
      Tag
    },
    methods: {
      addTag(t) {
        this.$emit('add-tag', t)
        this.$refs.search.focus()
      },
      removeTag(t) {
        this.$emit('remove-tag', t)
      },
      toggleTagMode() {
        this.search = '' // close search results
        this.$emit('toggle-tag-mode')
      },
      /**
       * Filter available tags based on search terms
       */
      filterTags() {
        let tags = this.availableTags

        if (this.search && this.search.length > 0) {
          let results = this.availableTags.filter(t => {
            let term = t.toLowerCase()
            return term.indexOf(this.search.toLowerCase()) !== -1
          })

          return results.sort()
        } else {
          return tags
        }
      }
    },
    watch: {
      /**
       * When tagSearchDropdown is triggered with a new value from a 
       * parent component, the search string will be deleted, causing 
       * the dropdown to close. This acts as an 'auto-close' on the 
       * dropdown, which would otherwise stay open to facilitate 
       * selecting multiple tags.
       */
      tagSearchDropdown() {
        this.search = ''
      },
      search() {
        this.filteredTags = this.filterTags()
      }
    },
    mounted() {
      // this.availableTags = this.tags
    },
    data() {
      return {
        timeout: null,
        search: '',
        filteredTags: [],
      }
    }
  }

</script>
