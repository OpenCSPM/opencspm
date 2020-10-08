<template>
  <div>
    <div class="mb-4">
      <nav class="hidden sm:flex items-center text-sm leading-5 font-medium">
        <router-link to="/profiles"
          class="text-gray-500 hover:text-gray-700 transition duration-150 ease-in-out">
          {{ organization.name }}</router-link>
      </nav>
    </div>
    <div>
      <StartCampaign />
    </div>
  </div>
</template>

<script>
  import StartCampaign from './dashboard/StartCampaign'
  // import SuggestedCampaigns from './dashboard/SuggestedCampaigns'

  export default {
    props: ['organization'],
    components: {
      StartCampaign,
      // SuggestedCampaigns
    }
  }

</script>
