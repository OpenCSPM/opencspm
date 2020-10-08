<template>
  <div>
    <div class="bg-white">
      <div class="max-w-screen-xl mx-auto text-center py-12 px-4 sm:px-6 lg:py-16 lg:px-8">
        <h2
          class="text-3xl leading-9 font-extrabold tracking-tight text-gray-900 sm:text-4xl sm:leading-10">
          Create a campaign.
        </h2>
        <p class="mt-4 max-w-3xl mx-auto text-center text-xl leading-7 text-gray-500">
          Start from a template, or create a blank campaign to customize.
        </p>
        <div class="mt-8 flex justify-center">
          <div class="inline-flex rounded-md shadow">
            <router-link to="/campaigns"
              class="inline-flex items-center justify-center px-5 py-3 border border-transparent text-base leading-6 font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-500 focus:outline-none focus:shadow-outline transition duration-150 ease-in-out">
              Use a template
            </router-link>
          </div>
          <div class="ml-3 inline-flex">
            <router-link to="/campaigns/new"
              class="inline-flex items-center justify-center px-5 py-3 border border-transparent text-base leading-6 font-medium rounded-md text-indigo-700 bg-indigo-100 hover:text-indigo-600 hover:bg-indigo-50 focus:outline-none focus:shadow-outline focus:border-indigo-300 transition duration-150 ease-in-out">
              Blank campaign
            </router-link>
          </div>
        </div>
      </div>
      <div class="mx-auto pb-12 max-w-lg w-full">
        <div class="bg-gray-50 sm:rounded-lg">
          <div class="px-4 py-5 sm:p-6">
            <h3 class="text-lg leading-6 font-medium text-gray-900">
              What is a campaign?
            </h3>
            <div class="mt-2 max-w-xl text-sm leading-5 text-gray-500">
              <p>
                A campaign is a collection of policies that you want to your environment to conform
                to. A campaign is an easy way to track progress towards a goal as you fix and
                remediate issues on your schedule. Use a template to see how easy it is
                to start a campaign.
              </p>
            </div>
          </div>
        </div>

      </div>
    </div>

  </div>
</template>

<script>
  export default {

  }

</script>
