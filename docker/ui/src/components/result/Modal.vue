<template>
  <div v-if="isOpen"
    class='flex fixed bottom-0 inset-x-0 px-4 pb-6 sm:inset-0 sm:p-0 sm:flex sm:items-center sm:justify-center'>
    <div v-on:click="close" class='fixed inset-0 transition-opacity'>
      <div class='absolute inset-0 bg-gray-500 opacity-75'></div>
    </div>
    <div class='modal-body bg-white rounded-lg overflow-hidden shadow-xl transform transition-all max-w-4xl sm:w-full'>
      <div class='bg-white shadow overflow-hidden  sm:rounded-lg'>
        <div class='px-6 pt-5'>
          <div class='flex content-start flex-wrap'>
            <div class='flex-shrink-0 h-10'>
              <div class="-ml-4">
                <div class="text-sm leading-5 text-gray-500">
                  <div class="inline-flex items-center pl-1 pr-2 mb-3 bg-indigo-100 rounded-full">
                    <span
                      class="px-2 py-px mr-2 text-xs font-bold text-indigo-100 uppercase bg-indigo-700 rounded-full">{{ finding.platform }}</span>
                    <span class="text-sm leading-loose text-indigo-800">{{ finding.category }}</span>
                  </div>
                </div>
              </div>
            </div>
            <div class='ml-auto modal-close-button'>
              <div v-on:click="close" class='flex justify-end text-gray-500 cursor-pointer'>
                <svg viewBox='0 0 24 24' stroke='currentColor' width='24' height='24' class='modal-close'>
                  <path strokeLinecap='round' strokeLinejoin='round' strokeWidth='2' d='M6 18L18 6M6 6l12 12' />
                </svg>
              </div>
            </div>
          </div>
          <div class="-ml-2 text-sm leading-5 font-medium text-gray-600">{{ finding.finding }} - {{ finding.title }}
          </div>
        </div>
        <div class='px-0 py-5'>
          <dl>
            <div class='mt-8 sm:mt-0 sm:grid sm:grid-cols-4 sm:gap-4 sm:border-t sm:border-gray-200 sm:px-6 sm:py-5'>
              <dt class='text-sm leading-5 font-medium text-gray-500'>
                Severity
              </dt>
              <dd class='mt-1 text-sm leading-5 text-gray-600 sm:mt-0 sm:col-span-3'>
                <span v-if="finding.severity >= threshold.severity.high"
                  class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium leading-4 bg-red-100 text-red-800">
                  high
                </span>
                <span v-if="finding.severity >= threshold.severity.medium && finding.severity < threshold.severity.high"
                  class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium leading-4 bg-yellow-100 text-yellow-800">
                  medium
                </span>
                <span v-if="finding.severity < threshold.severity.medium"
                  class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium leading-4 bg-gray-100 text-gray-800">
                  low
                </span>
              </dd>
            </div>
            <div class='mt-8 sm:mt-0 sm:grid sm:grid-cols-4 sm:gap-4 sm:border-t sm:border-gray-200 sm:px-6 sm:py-5'>
              <dt class='text-sm leading-5 font-medium text-gray-500'>
                Remediation Effort
              </dt>
              <dd class='mt-1 text-sm leading-5 text-gray-600 sm:mt-0 sm:col-span-3'>
                <span v-if="finding.effort >= threshold.severity.high"
                  class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium leading-4 bg-red-100 text-red-800">
                  high
                </span>
                <span v-if="finding.effort >= threshold.severity.medium && finding.effort < threshold.severity.high"
                  class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium leading-4 bg-yellow-100 text-yellow-800">
                  medium
                </span>
                <span v-if="finding.effort < threshold.severity.medium"
                  class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium leading-4 bg-gray-100 text-gray-800">
                  low
                </span>
              </dd>
            </div>
            <div
              class='description mt-8 sm:mt-0 sm:grid sm:grid-cols-4 sm:gap-4 sm:border-t sm:border-gray-200 sm:px-6 sm:py-5'>
              <dt class='text-sm leading-5 font-medium text-gray-500'>
                Description
              </dt>
              <dd v-html="markdown(finding.description)"
                class='mt-1 text-xs leading-5 text-gray-600 sm:mt-0 sm:col-span-3'></dd>
            </div>
            <div class='mt-8 sm:mt-0 sm:grid sm:grid-cols-4 sm:gap-4 sm:border-t sm:border-gray-200 sm:px-6 sm:py-5'>
              <dt class='text-sm leading-5 font-medium text-gray-500'>
                Affected Resources
              </dt>
              <dd class='mt-1 text-sm leading-5 text-gray-600 sm:mt-0 sm:col-span-3'>
                <ul class="space-y-1">
                  <li v-for="(resource, idx) in sortedResources" :key="idx" class="text-xs">
                    <div v-if="resource.status === 'failed'" class="flex">
                      <span
                        class="inline-flex justify-center px-2 py-0.5 mr-1 w-full max-w-4 rounded text-xs font-medium leading-4 bg-red-100 text-red-800">
                        {{ resource.status }}
                      </span>
                      <span v-on:click="copyToClipboard"
                        class="resource-name truncate hover:text-indigo-600 hover:font-medium">
                        {{ resource. resource }}
                      </span>
                    </div>
                    <div v-if="resource.status === 'passed'" class="flex">
                      <span
                        class="inline-flex justify-center px-2 py-0.5 mr-1 w-full max-w-4 rounded text-xs font-medium leading-4 bg-green-100 text-green-800">
                        {{ resource.status }}
                      </span>
                      <span v-on:click="copyToClipboard"
                        class="resource-name truncate hover:text-indigo-600 hover:font-medium">
                        {{ resource.resource }}
                      </span>
                    </div>
                  </li>
                </ul>
              </dd>
            </div>
            <div v-if="finding.remediation"
              class='remediation mt-8 sm:mt-0 sm:grid sm:grid-cols-4 sm:gap-4 sm:border-t sm:border-gray-200 sm:px-6 sm:py-5'>
              <dt class='text-sm leading-5 font-medium text-gray-500'>
                Remediation
              </dt>
              <dd v-html="markdown(finding.remediation)"
                class='mt-1 text-xs leading-5 text-gray-600 sm:mt-0 sm:col-span-3'></dd>
            </div>
            <div v-if="finding.validation"
              class='validation mt-8 sm:mt-0 sm:grid sm:grid-cols-4 sm:gap-4 sm:border-t sm:border-gray-200 sm:px-6 sm:py-5'>
              <dt class='text-sm leading-5 font-medium text-gray-500'>
                Validation
              </dt>
              <dd v-html="markdown(finding.validation)"
                class='mt-1 text-xs leading-5 text-gray-600 sm:mt-0 sm:col-span-3'></dd>
            </div>
            <div class='mt-8 sm:mt-0 sm:grid sm:grid-cols-4 sm:gap-4 sm:border-t sm:border-gray-200 sm:px-6 sm:py-5'>
              <dt class='text-sm leading-5 font-medium text-gray-500'>
                References
              </dt>
              <dd class='mt-1 text-sm leading-5 text-gray-600 sm:mt-0 sm:col-span-3'>
                <ul class='border-l border-r border-b border-gray-200 rounded-md'>
                  <li v-for="(reference, i) in finding.references" :key="i"
                    class='border-t border-gray-200 pl-3 pr-4 py-3 flex items-center justify-between text-sm leading-5'>
                    <div v-if="reference.ref === 'link'" class='w-0 flex-1 flex items-center'>
                      <a :href="reference.url" target='_blank' rel='noopener noreferrer'>
                        <svg class='flex-shrink-0 h-5 w-5 text-indigo-600 hover:text-indigo-500' fill='none'
                          viewBox='0 0 24 24' stroke='currentColor'>
                          <path stroke-linecap='round' stroke-linejoin='round' stroke-width='2'
                            d='M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14' />
                        </svg>
                      </a>
                      <span class='ml-2 truncate text-xs'>
                        <a :href="reference.url" target='_blank' rel='noopener noreferrer'>
                          {{ reference.text }}
                        </a>
                      </span>
                    </div>
                    <div v-if="reference.ref === 'csf'" class=''>
                      <div>
                        <p class="text-xs">NIST CyberSecurity Framework</p>
                      </div>
                      <div class="mt-2 flex flex-wrap">
                        <span v-for="(id, idx) in reference.ids" class='flex text-xs mr-2 mb-2' :key="idx">
                          <span class="inline-flex items-center pl-1 pr-2 bg-indigo-100 rounded-full">
                            <span
                              class="px-2 my-1 mr-2 text-xs font-bold text-indigo-100 uppercase bg-indigo-700 rounded-full">{{ id.split(".")[0] }}</span>
                            <span class="text-xs leading-loose text-indigo-800">{{ id.split(".")[1] }}</span>
                          </span>
                        </span>
                      </div>
                    </div>
                  </li>
                </ul>
              </dd>
            </div>
          </dl>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import marked from 'marked'

  export default {
    props: ['finding', 'threshold', 'isOpen'],
    methods: {
      copyToClipboard(event) {
        let el = event.target
        let x = event.pageX
        let y = event.pageY
        let alert = document.getElementById('modal-alert')

        if (alert && navigator.clipboard) {
          const contents = el.innerHTML

          navigator.clipboard.writeText(contents)

          alert.style.display = 'block'
          alert.style.top = `${y - 60}px`
          alert.style.left = `${x - 60}px`

          setTimeout(() => {
            alert.style.display = 'none'
          }, 2500)
        }
      },
      close() {
        this.$emit('closed', 1)
      },
      markdown(content) {
        return marked(content)
      },
    },
    computed: {
      sortedResources() {
        if (this.finding && this.finding.resources) {
          const res = this.finding.resources.slice().sort((a, b) => a.status.localeCompare(b.status))
          return res
        }

        return []
      }
    },
    data() {
      return {
        open: this.isOpen,
        // sortedResources: (this.finding && this.finding.resources) ? this.finding.resources.sort((a, b) => a.status
        //   .localeCompare(b.status)) : []
      }
    },
  }
</script>
