<template>
  <div class="control-activity mx-2 mb-4">
    <div class="graph">
      <ul class="squares">
        <!-- added via javascript -->
      </ul>
    </div>
    <div class="mx-4 mt-2 flex">
      <div @mouseover2="show = true" @mouseleave2="show = false"
        class="flex items-center space-x-1 text-xs text-gray-500">
        <div>
          <span class="tooltip">
            fewer <span class="tooltip-text -mt-8 -ml-16 bg-gray-700 text-gray-200 rounded-md">fewer
              issues</span>
          </span>
        </div>
        <div class="w-3 h-3 rounded-sm  bg-indigo-50"></div>
        <div class="w-3 h-3 rounded-sm  bg-indigo-100"></div>
        <div class="w-3 h-3 rounded-sm  bg-indigo-300"></div>
        <div class="w-3 h-3 rounded-sm  bg-indigo-500"></div>
        <div>
          <span class="tooltip">
            more <span class="tooltip-text -mt-8 -ml-16 bg-gray-700 text-gray-200 rounded-md">more
              issues</span>
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    components: {},
    mounted() {
      // Add squares
      const squares = document.querySelector('.squares')
      const bg = {
        0: 'bg-indigo-50',
        1: 'bg-indigo-100',
        2: 'bg-indigo-300',
        3: 'bg-indigo-500',
      }

      for (var i = 1; i < 92; i++) {
        const level = Math.floor(Math.random() * 4)
        squares.insertAdjacentHTML('beforeend', `<li class="rounded-sm ${bg[level]}"></li>`)
      }
    },
    data() {
      return {
        show: true,
        days: Array(364).fill({})
      }
    }
  }

</script>
