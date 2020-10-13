<template>
  <div class="flex flex-col rounded-lg shadow-lg overflow-hidden">
    <div class="flex-1 bg-white p-6 flex flex-col justify-between">
      <div class="flex-1">
        <div class="flex justify-between">
          <div class="text-sm leading-5 font-medium text-indigo-600">
            <div class="hover:underline">
              {{ profile.platform }}
            </div>
          </div>
          <div class="flex pt-0 ml-4 items-center space-x-2.5"
               v-if="profile.type === 'enterprise'">
            <svg class="h-5 w-5 text-gray-400 hover:text-indigo-500 cursor-pointer"
                 viewBox="0 0 20 20"
                 fill="currentColor">
              <path fill-rule="evenodd"
                    d="M6.267 3.455a3.066 3.066 0 001.745-.723 3.066 3.066 0 013.976 0 3.066 3.066 0 001.745.723 3.066 3.066 0 012.812 2.812c.051.643.304 1.254.723 1.745a3.066 3.066 0 010 3.976 3.066 3.066 0 00-.723 1.745 3.066 3.066 0 01-2.812 2.812 3.066 3.066 0 00-1.745.723 3.066 3.066 0 01-3.976 0 3.066 3.066 0 00-1.745-.723 3.066 3.066 0 01-2.812-2.812 3.066 3.066 0 00-.723-1.745 3.066 3.066 0 010-3.976 3.066 3.066 0 00.723-1.745 3.066 3.066 0 012.812-2.812zm7.44 5.252a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                    clip-rule="evenodd" />
            </svg>
          </div>
        </div>
        <router-link :to="`/controls?tags=${profile.tags}`">
          <div class="block">
            <h3 class="mt-2 text-xl leading-7 font-semibold text-gray-900">
              {{ profile.name }}
            </h3>
          </div>
        </router-link>
      </div>
      <div class="mt-6 flex justify-between items-center">
        <div class="flex text-sm leading-5 text-gray-500">
          <span>
            <StatusDot :status="profile.controls.length > 0 ? 'active' : 'inactive'"
                       :text="profile.controls.length > 0 ? 'active' : 'inactive'" />
          </span>
        </div>
        <div class="py-0.5">
          <span v-if="profile.controls.length > 0"
                class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium leading-4 bg-gray-100 text-indigo-800">
            {{ profile.controls.length }}
            {{ profile.controls.length === 1 ? 'control': 'controls' }}
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import StatusDot from '../shared/StatusDot'

  export default {
    components: {
      StatusDot
    },
    props: ['idx', 'profile'],
    data() {
      return {
        expanded: false
      }
    }
  }

</script>
