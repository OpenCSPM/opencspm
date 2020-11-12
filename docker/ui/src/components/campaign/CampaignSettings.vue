<template>
  <transition name="slide-over-transition"
              enter-active-class="transform transition ease-in-out duration-200"
              enter-class="translate-x-full"
              enter-to-class="translate-x-0"
              leave-active-class="transform transition ease-in-out duration-700"
              leave-class="translate-x-0"
              leave-to-class="translate-x-full">
    <div class="fixed inset-0 overflow-hidden">
      <div class="absolute inset-0 overflow-hidden">
        <section class="absolute inset-y-0 pl-16 max-w-full right-0 flex">
          <div class="w-screen max-w-md">
            <div class="h-full divide-y divide-gray-200 flex flex-col bg-white shadow-xl">
              <div class="flex-1 h-0 overflow-y-auto">
                <header class="space-y-1 py-6 px-4 bg-gray-700 sm:px-6">
                  <div class="flex items-center justify-between space-x-3">
                    <h2 class="text-lg leading-7 font-medium text-white">
                      {{ name }}
                    </h2>
                  </div>
                  <div>
                    <p class="text-sm leading-5 text-indigo-300">
                      Get started by naming your campaign and entering a few descriptive notes.
                    </p>
                  </div>
                </header>
                <div class="flex-1 flex flex-col justify-between">
                  <div class="px-4 divide-y divide-gray-200 sm:px-6">
                    <div class="space-y-6 pt-6 pb-5">
                      <div class="space-y-1">
                        <label for="project_name"
                               class="block text-sm font-medium leading-5 text-gray-900">
                          Campaign name
                        </label>
                        <div class="relative rounded-md shadow-sm">
                          <input v-model="name"
                                 @keydown.enter="update"
                                 id="project_name"
                                 class="form-input block w-full sm:text-sm sm:leading-5 transition ease-in-out duration-150">
                        </div>
                      </div>
                      <div class="space-y-1">
                        <label for="description"
                               class="block text-sm font-medium leading-5 text-gray-900">
                          Notes
                        </label>
                        <div class="relative rounded-md shadow-sm">
                          <textarea id="description"
                                    rows="4"
                                    class="form-input block w-full sm:text-sm sm:leading-5 transition ease-in-out duration-150"></textarea>
                        </div>
                      </div>
                    </div>
                    <div class="space-y-4 pt-4 pb-6">
                      <div class="text-sm leading-5">
                        <label for="description"
                               class="block text-sm font-medium leading-5 text-gray-900">
                          Notifications
                        </label>

                        <div class="mt-1">
                          <fieldset>
                            <div class="mt-4">
                              <div class="flex items-start">
                                <div class="flex items-center h-5">
                                  <input id="notifications-slack"
                                         type="checkbox"
                                         disabled
                                         class="form-checkbox h-4 w-4 text-indigo-600 transition duration-150 ease-in-out">
                                </div>
                                <div class="ml-3 text-sm leading-5">
                                  <label for="notifications-slack"
                                         class="font-medium text-gray-700">Slack</label>
                                  <p class="text-gray-500">Get notified in a Slack channel when this
                                    campaign has more failed controls.</p>
                                </div>
                              </div>
                              <div class="mt-4">
                                <div class="flex items-start">
                                  <div class="flex items-center h-5">
                                    <input id="notifications-other"
                                           type="checkbox"
                                           disabled
                                           class="form-checkbox h-4 w-4 text-indigo-600 transition duration-150 ease-in-out">
                                  </div>
                                  <div class="ml-3 text-sm leading-5">
                                    <label for="notifications-other"
                                           class="font-medium text-gray-700">Other</label>
                                    <p class="text-gray-500">Get notified on other channels when
                                      this campaign has more failed controls. See options below.</p>
                                  </div>
                                </div>
                              </div>
                            </div>
                          </fieldset>
                          <div class="mt-4">
                            <a href="https://github.com/OpenCSPM/opencspm/issues/11"
                               target="_blank">
                              <button type="button"
                                      class="inline-flex justify-center py-2 px-4 border border-transparent text-sm leading-5 font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-500 focus:outline-none focus:border-indigo-700 focus:shadow-outline-indigo active:bg-indigo-700 transition duration-150 ease-in-out">
                                Vote: Notification Options Poll
                                <svg class="ml-3 h-4 w-4"
                                     xmlns="http://www.w3.org/2000/svg"
                                     viewBox="0 0 20 20"
                                     fill="currentColor">
                                  <path
                                        d="M11 3a1 1 0 100 2h2.586l-6.293 6.293a1 1 0 101.414 1.414L15 6.414V9a1 1 0 102 0V4a1 1 0 00-1-1h-5z" />
                                  <path
                                        d="M5 5a2 2 0 00-2 2v8a2 2 0 002 2h8a2 2 0 002-2v-3a1 1 0 10-2 0v3H5V7h3a1 1 0 000-2H5z" />
                                </svg>
                              </button>
                            </a>
                          </div>
                        </div>
                      </div>
                    </div>
                    <div class="space-y-4 pt-4 pb-6">
                      <div class="flex text-sm leading-5">
                        <a href="#"
                           class="group space-x-2 inline-flex items-center text-gray-500 hover:text-gray-900 transition ease-in-out duration-150">
                          <svg class="h-5 w-5 text-gray-400 group-hover:text-gray-500 transition ease-in-out duration-150"
                               viewBox="0 0 20 20"
                               fill="currentColor">
                            <path fill-rule="evenodd"
                                  d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-8-3a1 1 0 00-.867.5 1 1 0 11-1.731-1A3 3 0 0113 8a3.001 3.001 0 01-2 2.83V11a1 1 0 11-2 0v-1a1 1 0 011-1 1 1 0 100-2zm0 8a1 1 0 100-2 1 1 0 000 2z"
                                  clip-rule="evenodd" />
                          </svg>
                          <span>
                            {{ filters }}
                          </span>
                        </a>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              <div class="flex-shrink-0 px-4 py-4 space-x-4 flex justify-end">
                <span class="inline-flex rounded-md shadow-sm">
                  <button type="button"
                          @click="$emit('close')"
                          class="py-2 px-4 border border-gray-300 rounded-md text-sm leading-5 font-medium text-gray-700 hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue active:bg-gray-50 active:text-gray-800 transition duration-150 ease-in-out">
                    Cancel
                  </button>
                </span>
                <span @click="update"
                      class="inline-flex rounded-md shadow-sm">
                  <button type="submit"
                          class="inline-flex justify-center py-2 px-4 border border-transparent text-sm leading-5 font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-500 focus:outline-none focus:border-indigo-700 focus:shadow-outline-indigo active:bg-indigo-700 transition duration-150 ease-in-out">
                    Save
                  </button>
                </span>
              </div>
            </div>
          </div>
        </section>
      </div>
    </div>
  </transition>
</template>

<script>
  export default {
    props: ['campaign'],
    methods: {
      update() {
        let url = `/campaigns/${this.campaign.data.id}`
        let payload = {
          campaign: {
            name: this.name
          }
        }

        this.$http.patch(url, payload)
          .then(res => {
            this.$emit('update', res)
          })
      }
    },
    data() {
      return {
        name: this.campaign.data.attributes.name,
        filters: this.campaign.data.attributes.filters
      }
    }
  }

</script>
