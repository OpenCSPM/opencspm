<template>
  <div class="fixed z-10 inset-0 overflow-y-auto">
    <div
         class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
      <div class="fixed inset-0 transition-opacity"
           @click="$emit('close-modal')">
        <div class="absolute inset-0 bg-gray-500 opacity-75"></div>
      </div>

      <!-- This element is to trick the browser into centering the modal contents. -->
      <span class="hidden sm:inline-block sm:align-middle sm:h-screen"></span>&#8203;
      <div class="inline-block bg-white rounded-lg px-2 pt-5 pb-4 mt-48 mb-8 align-top max-w-3xl w-full p-6 text-left overflow-hidden shadow-xl transform transition-all"
           role="dialog"
           aria-modal="true"
           aria-labelledby="modal-headline">
        <div class="pb-2">
          <control-activity />
        </div>
        <div class="px-2 py-2 flex justify-between">
          <div>
            <div class="inline-flex items-center pl-1 pr-2 mb-3 bg-indigo-100 rounded-full">
              <span
                    class="px-2 py-px mr-2 text-xs font-bold text-blue-100 uppercase bg-blue-700 rounded-full">{{ data.platform }}</span>
              <span class="mr-1 text-sm leading-loose text-blue-800">{{ data.name }}</span>
            </div>
          </div>
          <div class="mr-1">
            <div v-if="data.impact > 7">
              <div class="inline-flex items-center pl-2 pr-1 mb-3 bg-pink-100 rounded-full">
                <span class="ml-1 text-sm leading-loose text-pink-800">Impact</span>
                <span
                      class="px-2 py-px ml-2 text-xs font-bold text-pink-100 uppercase bg-pink-800 rounded-full">High</span>
              </div>
            </div>
            <div v-if="data.impact <= 7 && data.impact >= 4">
              <div class="inline-flex items-center pl-2 pr-1 mb-3 bg-orange-100 rounded-full">
                <span class="ml-1 text-sm leading-loose text-orange-800">Impact</span>
                <span
                      class="px-2 py-px ml-2 text-xs font-bold text-orange-100 uppercase bg-orange-700 rounded-full">Moderate</span>
              </div>
            </div>
            <div v-if="data.impact < 4">
              <div class="inline-flex items-center pl-2 pr-1 mb-3 bg-gray-100 rounded-full">
                <span class="ml-1 text-sm leading-loose text-gray-800">Impact</span>
                <span
                      class="px-2 py-px ml-2 text-xs font-bold text-gray-100 uppercase bg-gray-700 rounded-full">Low</span>
              </div>
            </div>
          </div>
        </div>
        <div class="mx-2 pb-4 space-x-4">
          <Tag>pci-1.2</Tag>
          <Tag>cis-1.6</Tag>
          <Tag>dbp-6.2</Tag>
        </div>
        <div class="px-2 py-2">
          <h3 class="text-lg leading-6 font-medium text-gray-800">
            {{ data.title }}
          </h3>
          <div class="flex justify-between mt-2 w-full text-sm leading-5 text-gray-500">
            <div class="pr-6">
              <p>
                {{ data.description }}
              </p>
            </div>
          </div>
          <div class="pt-5 pb-2 text-sm text-gray-600">
            <h3 class="text-lg leading-6 font-medium text-gray-800">
              Affected Resources
            </h3>
            <div>
              <div class="text-sm text-gray-500 truncate"
                   v-for="(resource, idx) in resources"
                   :key="idx">
                <span class="mt-2 w-full max-w-4 inline-flex items-center justify-center px-2 py-0.5 rounded text-xs font-medium leading-4"
                      :class="{
                        'bg-green-100 text-green-800': resource.status === 'passed', 
                        'bg-red-100 text-red-800': resource.status === 'failed'
                      }">
                  {{ resource.status }}
                </span>
                {{ resource.name }}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

</template>

<script>
  import Tag from '../shared/Tag'
  import ControlActivity from './ControlActivity'

  export default {
    props: ['control'],
    components: {
      Tag,
      ControlActivity
    },
    mounted() {
      let url = `/controls/${this.control.id}`

      this.$http.get(url)
        .then(res => {
          this.resources = res.data.data.attributes.resources
        })
    },
    data() {
      return {
        data: this.control,
        resources: []
      }
    }
  }

</script>
