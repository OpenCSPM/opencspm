<template>
  <div>

    <div class="mb-4">
      <div class="flex justify-between">
        <nav class="hidden sm:flex items-center text-sm leading-5 font-medium">
          <router-link to="/profiles"
                       class="text-gray-500 hover:text-gray-700 transition duration-150 ease-in-out">
            Profiles
          </router-link>
          <svg class="flex-shrink-0 mx-2 h-5 w-5 text-gray-400"
               viewBox="0 0 20 20"
               fill="currentColor">
            <path fill-rule="evenodd"
                  d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z"
                  clip-rule="evenodd" />
          </svg>
          <span v-if="profile"
                class="text-gray-500 hover:text-gray-700 transition duration-150 ease-in-out">{{ profile.data.attributes.name }}
          </span>
        </nav>
        <div class="text-sm text-gray-500 font-medium">Last checked 3 hours ago</div>
      </div>
    </div>

    <div class="relative flex flex-col">
      <!-- 3 column wrapper -->
      <div class="flex-grow w-full lg:flex">
        <div class="flex-1 min-w-0 bg-white">
          <div class="bg-white">
            <div class="py-4">
              <div class="flex items-center justify-between">
                <div class="flex-1 space-y-8">
                  <div class="space-y-8 sm:space-y-0 sm:flex sm:justify-between sm:items-center">
                    <CampaignDropdown v-if="profile"
                                      :profile="profile"
                                      :controls="profile.data.attributes.controls"
                                      :selected-controls="selectedControls" />
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <ProfileControlsList v-if="profile"
                         :controls="profile.data.attributes.controls"
                         @control-selected="updateSelectedControls" />
  </div>
</template>

<script>
  import CampaignDropdown from '../campaign/CampaignDropdown'
  import ProfileControlsList from '../control/ControlsList'

  import 'highlight.js/styles/atom-one-dark.css'
  import hljs from 'highlight.js/lib/core'

  // hljs.registerLanguage('ruby', ruby)


  export default {
    components: {
      CampaignDropdown,
      ProfileControlsList,
    },
    methods: {
      highlight() {
        document.querySelectorAll('pre code').forEach((block) => {
          hljs.highlightBlock(block)
        })
      },
      updateSelectedControls(controls) {
        this.selectedControls = controls
      }
    },
    // watch: {
    //   selectedControls() {
    //     console.log(this.selectedControls)
    //   }
    // },
    mounted() {
      let url = `/profiles/${this.$route.params.profile_id}`

      this.$http.get(url)
        .then(res => {
          this.profile = res.data
        })
    },
    data() {
      return {
        profile: null,
        selectedControls: []
      }
    }
  }

</script>
