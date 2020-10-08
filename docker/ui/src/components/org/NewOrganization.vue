<template>
  <div>
    <div class="mb-4">
      <div>
        <nav class="sm:hidden">
          <a href="#"
            class="flex items-center text-sm leading-5 font-medium text-gray-500 hover:text-gray-700 transition duration-150 ease-in-out">
            <svg class="flex-shrink-0 -ml-1 mr-1 h-5 w-5 text-gray-400" viewBox="0 0 20 20"
              fill="currentColor">
              <path fill-rule="evenodd"
                d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z"
                clip-rule="evenodd" />
            </svg>
            Back
          </a>
        </nav>
        <nav class="hidden sm:flex items-center text-sm leading-5 font-medium">
          <router-link to="/dashboard"
            class="text-gray-500 hover:text-gray-700 transition duration-150 ease-in-out">
            Organizations
          </router-link>
          <svg class="flex-shrink-0 mx-2 h-5 w-5 text-gray-400" viewBox="0 0 20 20"
            fill="currentColor">
            <path fill-rule="evenodd"
              d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z"
              clip-rule="evenodd" />
          </svg>
          <router-link to="/campaigns"
            class="text-gray-500 hover:text-gray-700 transition duration-150 ease-in-out">New
          </router-link>
        </nav>
      </div>
    </div>

    <div class="bg-white">
      <div class="max-w-screen-xl mx-auto text-center py-12 px-4 sm:px-6 lg:py-16 lg:px-8">
        <h2
          class="text-3xl leading-9 font-extrabold tracking-tight text-gray-900 sm:text-4xl sm:leading-10">
          Add an organization.
        </h2>
        <p class="mt-4 max-w-3xl mx-auto text-center text-xl leading-7 text-gray-500">
          Organize your cloud resources by grouping them in an organization.
        </p>
        <div class="mt-8 max-w-md mx-auto">
          <div class="pt-8">
            <div class="text-left">
              <label for="name"
                class="block text-sm font-medium leading-5 text-gray-700">Name</label>
              <div class="mt-1 relative rounded-md shadow-sm">
                <input id="name" class="form-input block w-full sm:text-sm sm:leading-5"
                  placeholder="Acme Prod" aria-describedby="org-description">
              </div>
              <p class="mt-2 text-sm text-gray-500" id="org-description">The name your team calls
                this organization.</p>
            </div>
          </div>
          <div class="pt-8">
            <div class="text-left">
              <label for="id" class="block text-sm font-medium leading-5 text-gray-700">ID</label>
              <div class="mt-1 relative rounded-md shadow-sm">
                <input id="id" class="form-input block w-full sm:text-sm sm:leading-5"
                  placeholder="acme.dev.int" aria-describedby="id-description">
              </div>
              <p class="mt-2 text-sm text-gray-500" id="id-description">An optional unique
                identifier.</p>
            </div>
          </div>
          <div class="mt-8 border-t border-gray-200 pt-5">
            <div class="flex justify-end">
              <span class="ml-3 inline-flex rounded-md shadow-sm">
                <router-link to="/dashboard">
                  <button type="button"
                    class="inline-flex justify-center py-2 px-4 border border-transparent text-sm leading-5 font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-500 focus:outline-none focus:border-indigo-700 focus:shadow-outline-indigo active:bg-indigo-700 transition duration-150 ease-in-out">
                    Create
                  </button>

                </router-link>
              </span>
            </div>
          </div>
        </div>
      </div>
      <div class="mx-auto pb-12 max-w-lg w-full">
        <div class="bg-gray-50 sm:rounded-lg">
          <div class="px-4 py-5 sm:p-6">
            <h3 class="text-lg leading-6 font-medium text-gray-900">
              What is an organization?
            </h3>
            <div class="mt-2 max-w-xl text-sm leading-5 text-gray-500">
              <p>
                An organization is just a logical grouping of accounts or projects. You can add any
                number of data sources to an organization, but they should be related in some way to
                enable more efficient workflows. You might add multiple AWS accounts or Google Cloud
                projects to an Organization.
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
