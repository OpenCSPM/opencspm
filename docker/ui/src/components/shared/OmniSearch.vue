<template>
  <div v-show="isOpen"
    class="fixed z-50 px-4 pt-16 flex items-start justify-center inset-0 sm:pt-24">
    <div v-show="isOpen" class="fixed inset-0 transition-opacity">
      <div class="absolute inset-0 bg-gray-900 opacity-50"></div>
    </div>

    <div v-show="isOpen"
      class="relative bg-gray-900 rounded-lg overflow-hidden shadow-xl transform transition-all max-w-lg w-full">
      <input ref="search" @keydown.tab.prevent="" @keydown.prevent.stop.enter="go()"
        @keydown.prevent.up="selectUp()" @keydown.prevent.down="selectDown()" v-model="search"
        type="text" style="caret-color: #6b7280"
        class="appearance-none w-full bg-transparent px-6 py-4 text-gray-300 text-lg placeholder-gray-500 focus:outline-none"
        placeholder="Find anything...">
      <div class="border-t border-gray-800" v-show="filteredItems().length > 0">
        <ul style="max-height: 265px;" class="overflow-y-auto">
          <div v-for="(item, idx) in filteredItems()" :key="item.url">
            <li @click="close">
              <router-link :to="item.url" class="block px-6 py-3"
                :class="{ 'bg-gray-700': selected === idx, 'hover:bg-gray-800': selected !== idx }">
                <span
                  :class="{'text-gray-300': selected !== idx, 'text-white': selected === idx }">{{ item.name }}</span>
                <span class="ml-1"
                  :class="{'text-gray-500': selected !== idx, 'text-gray-400': selected === idx }">{{ item.category }}</span>
              </router-link>
            </li>
          </div>
        </ul>
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    methods: {
      open() {
        setTimeout(() => {
          this.$refs.search.focus()
        }, 250)

        this.isOpen = true
      },
      close() {
        this.isOpen = false
        this.search = null
      },
      selectUp() {
        this.selected = Math.max(0, this.selected - 1)
      },
      selectDown() {
        this.selected = Math.min(this.results.length - 1, this.selected + 1)
      },
      filteredItems() {
        return this.results
      }
    },
    mounted() {
      document.addEventListener('keydown', e => {
        if (e.key === '/') this.open()
        if (e.key === 'Escape') this.close()
      })
    },
    data() {
      return {
        search: null,
        selected: 0,
        results: [{
            name: 'Campaign 1',
            url: '/campaigns/2',
            category: 'campaign'
          },
          {
            name: 'Campaign 2',
            url: '/campaigns/4',
            category: 'campaign'
          }
        ],
        isOpen: false
      }
    }
  }

</script>

<style>

</style>
