<template>
  <div>
    <slot class="block"></slot>
    <div class="z-50 relative mx-2">
      <div class="bg-gray-800 text-white text-xs font-medium rounded py-1 px-4 right-0 bottom-full">
        {{ content }}
        <svg class="absolute text-gray-800 h-2 w-full left-0 top-full" x="0px" y="0px"
          viewBox="0 0 255 255" xml:space="preserve">
          <polygon class="fill-current" points="0,0 127.5,127.5 255,0" />
        </svg>
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    props: ['content']
  }

</script>
