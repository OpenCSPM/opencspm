<template>
  <div class="mx-4 relative min-h-screen flex flex-col">
    <!-- 3 column wrapper -->
    <div class="flex-grow w-full lg:flex">
      <div class="flex-1 min-w-0">
        <div class="lg:min-w-0 lg:flex-1">
          <div class="mt-6 grid gap-5 max-w-lg mx-auto lg:grid-cols-3 lg:max-w-none">
            <ProfileCard v-for="(profile, idx) in profiles"
                         :key="idx"
                         :profile="profile"
                         :idx="idx" />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import ProfileCard from './ProfileCard'

  export default {
    components: {
      // ProfileSearch,
      ProfileCard
    },
    methods: {
      filteredProfiles: function(t) {
        return this.profiles.filter(x => x.profile_type === t)
      }
    },
    mounted: function() {
      let url = '/profiles'

      this.$http.get(url)
        .then(res => {
          this.profiles = res.data.data.map(x => x.attributes).sort((a, b) => a.controls
            .length > b.controls.length ? -1 : 1)
        })
    },
    data() {
      return {
        profiles: []
      }
    }
  }

</script>
