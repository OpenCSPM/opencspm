<template>
  <div class="flex items-center space-x-3">
    <span aria-label="Running"
      :class="`h-4 w-4 ${inner[this.status]} rounded-full flex items-center justify-center`">
      <span :class="`h-2 w-2 ${outer[this.status]} rounded-full`"></span>
    </span>
    <span class="block">
      <p class="text-sm font-medium leading-5">
        <span class="inset-0"></span>
        {{ text }}
      </p>
    </span>
  </div>
</template>

<script>
  export default {
    props: ['status', 'text'],
    data() {
      return {
        inner: {
          'warn': 'bg-orange-100',
          'active': 'bg-green-100',
          'inactive': 'bg-gray-100',
          'pending': 'bg-gray-100'
        },
        outer: {
          'warn': 'bg-orange-400',
          'active': 'bg-green-400',
          'inactive': 'bg-gray-400',
          'pending': 'bg-gray-400'
        }
      }
    }
  }

</script>
