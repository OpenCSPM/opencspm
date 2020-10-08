<template>
  <div>
    <div class="mt-12 pb-5 border-b border-gray-200">
      <h3 class="text-lg leading-6 font-medium text-gray-900">
        Suggested Campaigns
      </h3>
    </div>

    <div class="mt-6 grid gap-5 max-w-lg mx-auto lg:grid-cols-3 lg:max-w-none">
      <div v-for="suggestion in suggestions" :key="suggestion.name"
        class="flex flex-col rounded-lg shadow-lg overflow-hidden">
        <div class="flex-1 bg-white p-6 flex flex-col justify-between">
          <div class="flex-1">
            <p class="text-sm leading-5 font-medium text-indigo-600">
              <a href="#" class="hover:underline">
                {{ suggestion.category }}
              </a>
            </p>
            <a href="#" class="block">
              <h3 class="mt-2 text-xl leading-7 font-semibold text-gray-900">
                {{ suggestion.title }}
              </h3>
              <p class="mt-3 text-base leading-6 text-gray-500">
                Lorem ipsum dolor sit amet consectetur adipisicing elit. Velit facilis asperiores
                porro quaerat doloribus, eveniet dolore. Adipisci tempora aut inventore optio
                animi., tempore temporibus quo laudantium.
              </p>
            </a>
          </div>
          <div class="mt-6 flex items-center">
            <div class="">
              <p class="text-sm leading-5 font-medium text-gray-900">
                <a href="#" class="hover:underline">
                  {{ suggestion.name }}
                </a>
              </p>
              <div class="flex text-sm leading-5 text-gray-500">
                <span>
                  {{ suggestion.policies }} policies
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    data() {
      return {
        suggestions: [{
            title: 'Google Cloud CIS Benchmark 1.1',
            name: 'GCP CIS 1.1',
            category: 'Google',
            summary: 'sdf',
            policies: 2
          },
          {
            title: 'Google Kubernetes Engine CIS Benchmark 1.1',
            name: 'GKE CIS 1.1',
            category: 'Kubernetes',
            summary: 'sdf',
            policies: 3
          },
          {
            title: 'Darkbit Best Practices Level 1',
            name: 'Darkbit Best Practices L1',
            category: 'Best Practices',
            summary: 'sdf',
            policies: 5
          },
        ]
      }
    }
  }

</script>
