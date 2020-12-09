<template>
  <div class="control-modal fixed z-10 inset-0">
    <div
         class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
      <div class="fixed inset-0 transition-opacity"
           @click="$emit('close-modal')">
        <div class="absolute inset-0 bg-gray-500 opacity-75"></div>
      </div>

      <div class="inline-block max-h-4xl bg-white rounded-lg px-2 pt-5 pb-4 mt-10 mb-8 align-top max-w-3xl w-full p-6 text-left overflow-hidden overflow-y-scroll shadow-xl transform transition-all"
           role="dialog"
           aria-modal="true"
           aria-labelledby="modal-headline">
        <div class="px-2 py-2 flex justify-between">
          <div>
            <div class="inline-flex items-center pl-1 pr-2 mb-3 bg-indigo-100 rounded-md">
              <span class="mx-1 text-sm leading-loose text-blue-800">{{ data.control_id }}</span>
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
        <div v-if="data.tags"
             class="mx-2 pb-4">
          <Tag v-for="(tag, idx) in data.tags.filter(x => x.primary ).sort((a,b) => a.tag.localeCompare(b.tag) )"
               :key=idx>{{ tag.tag }}</Tag>
        </div>
        <div v-if="data.tags && data.tags.filter(x => !x.primary).length > 0"
             class="mx-2 pb-4">
          <div @click="toggleSecondaryTags"
               class="mt-4 cursor-pointer">
            <div class="flex items-center space-x-3">
              <h3>Secondary Tags
              </h3>
              <svg class="h-4 w-4 text-indigo-400"
                   viewBox="0 0 20 20"
                   fill="currentColor">
                <path fill-rule="evenodd"
                      d="M17.707 9.293a1 1 0 010 1.414l-7 7a1 1 0 01-1.414 0l-7-7A.997.997 0 012 10V5a3 3 0 013-3h5c.256 0 .512.098.707.293l7 7zM5 6a1 1 0 100-2 1 1 0 000 2z"
                      clip-rule="evenodd" />
              </svg>
              <svg v-if="!showSecondaryTags"
                   class="h-4 w-4 text-indigo-500"
                   viewBox="0 0 20 20"
                   fill="currentColor">
                <path
                      d="M6 10a2 2 0 11-4 0 2 2 0 014 0zM12 10a2 2 0 11-4 0 2 2 0 014 0zM16 12a2 2 0 100-4 2 2 0 000 4z" />
              </svg>
            </div>
            <div v-if="showSecondaryTags">
              <Tag v-for="(tag, idx) in data.tags.filter(x => !x.primary).sort((a,b) => a.tag.localeCompare(b.tag))"
                   :key=idx>{{ tag.tag }}</Tag>
            </div>
          </div>
        </div>
        <div class="px-2 py-2">
          <h3 class="text-lg leading-6 font-medium text-gray-800">
            {{ data.title }}
          </h3>
          <div class="flex justify-between mt-2 w-full text-sm leading-5 text-gray-500">
            <div class="pr-6">
              <p v-html="markdown(data.description)"></p>
            </div>
          </div>
          <h3 class="mt-4 text-lg leading-6 font-medium text-gray-800">
            Remediation
          </h3>
          <div class="flex justify-between mt-2 w-full text-sm leading-5 text-gray-500">
            <div class="flex min-w-full validation-details">
              <div class="min-w-full">
                <p v-html="markdown(data.remediation)"></p>
              </div>
            </div>
          </div>
          <h3 class="mt-4 text-lg leading-6 font-medium text-gray-800">
            Validation
          </h3>
          <div class="flex justify-between w-full text-sm leading-5 text-gray-500">
            <div class="flex min-w-full validation-details">
              <p class="min-w-full"
                 v-html="markdown(data.validation)"></p>
            </div>
          </div>
          <div v-if="data.refs && data.refs.length > 0">
            <h3 class="mt-4 text-lg leading-6 font-medium text-gray-800">
              References
            </h3>
            <div class="mt-2 w-full text-sm leading-5 text-gray-500">
              <div v-for="(ref,idx) in data.refs"
                   :key="idx">
                <div class="flex items-center space-x-2">
                  <svg class="h-4 w-4 text-indigo-500"
                       viewBox="0 0 20 20"
                       fill="currentColor">
                    <path
                          d="M11 3a1 1 0 100 2h2.586l-6.293 6.293a1 1 0 101.414 1.414L15 6.414V9a1 1 0 102 0V4a1 1 0 00-1-1h-5z" />
                    <path
                          d="M5 5a2 2 0 00-2 2v8a2 2 0 002 2h8a2 2 0 002-2v-3a1 1 0 10-2 0v3H5V7h3a1 1 0 000-2H5z" />
                  </svg>
                  <span class="mt-0.5">
                    <a :href="ref.table.url"
                       target="_blank"
                       rel="noopener noreferrer">{{ ref.table.text }}</a>
                  </span>
                </div>
              </div>
            </div>
          </div>
          <div class="pt-5 pb-2 text-sm text-gray-600">
            <h3 class="text-lg leading-6 font-medium text-gray-800">
              Affected Resources
            </h3>
            <div v-if="resources.length > 0">
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
            <div v-if="resources.length === 0">
              <div class="mt-4 rounded-md bg-green-50 p-4">
                <div class="flex">
                  <div class="flex-shrink-0">
                    <svg class="h-5 w-5 text-green-400"
                         viewBox="0 0 20 20"
                         fill="currentColor">
                      <path fill-rule="evenodd"
                            d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                            clip-rule="evenodd" />
                    </svg>
                  </div>
                  <div class="ml-3">
                    <p class="text-sm leading-5 font-medium text-green-800">
                      No affected resources found.
                    </p>
                  </div>
                </div>
              </div>

            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

</template>

<script>
  import marked from 'marked'
  import Tag from '../shared/Tag'

  export default {
    props: ['control'],
    components: {
      Tag,
    },
    methods: {
      toggleSecondaryTags() {
        this.showSecondaryTags = !this.showSecondaryTags
      },
      markdown(content) {
        if (content && content.length > 0) {
          return marked(content)
        } else {
          return ''
        }
      },
    },
    mounted() {
      let url = `/controls/${this.control.id}`

      this.$http.get(url)
        .then(res => {
          this.data = res.data.data.attributes
          this.resources = res.data.data.attributes.resources.sort((a, b) => a.status
            .localeCompare(b.status))
        })
        .then(() => {
          this.isEnterpriseControl = this.data.control_pack.startsWith(
            'opencspm-darkbit-enterprise')
        })
    },
    data() {
      return {
        isEnterpriseControl: false,
        showSecondaryTags: false,
        data: this.control,
        resources: []
      }
    }
  }

</script>
