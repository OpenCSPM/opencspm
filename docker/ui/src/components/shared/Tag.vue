<template>
  <span class="mr-2 inline-flex items-center px-2 py-0.5 rounded text-xs font-medium leading-4 bg-gray-100 text-indigo-800"
        @click="doAction">
    <svg class="mr-1.5 h-2 w-2 text-indigo-400"
         fill="currentColor"
         viewBox="0 0 8 8">
      <circle cx="4"
              cy="4"
              r="3" />
    </svg>
    <slot></slot>
  </span>
</template>

<script>
  export default {
    props: ['tag', 'action'],
    methods: {
      doAction() {
        if (this.action === 'add') this.$emit('add-tag', this.tag)
        if (this.action === 'remove') this.$emit('remove-tag', this.tag)
      }
    }
  }

</script>
