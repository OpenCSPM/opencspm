<template>
  <!-- Activity feed -->
  <div
    class="bg-gray-50 pr-4 sm:pr-6 lg:pr-8 lg:flex-shrink-0 lg:border-l lg:border-gray-200 xl:pr-0">
    <div class="px-6">
      <div>
        <ul class="divide-y divide-gray-200">
          <li v-for="(activity, idx) in activities" :key="idx" class="py-4">
            <div class="flex space-x-3">
              <div class="flex-1 space-y-1">
                <div class="flex items-center justify-between">
                  <span class="text-sm leading-5 text-gray-500">
                    {{ activity.title }}</span>
                  <span class="text-sm leading-5 text-gray-500">{{ activity.time }} ago</span>
                </div>
              </div>
            </div>
          </li>
        </ul>
        <div class="py-4 text-sm leading-5 border-t border-gray-200">
          <a href="#" class="text-indigo-600 font-semibold hover:text-indigo-900">View all activity
            &rarr;</a>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    data() {
      return {
        activities: [{
            title: 'processed 4 profiles',
            time: '1h'
          },
          {
            title: 'processed 4 profiles',
            time: '7h'
          },
          {
            title: 'processed 4 profiles',
            time: '13h'
          },
          {
            title: 'processed 4 profiles',
            time: '19h'
          },
          {
            title: 'processed 4 profiles',
            time: '25h'
          },
          {
            title: 'processed 4 profiles',
            time: '1d'
          },
          {
            title: 'processed 4 profiles',
            time: '1d'
          },
          {
            title: 'processed 4 profiles',
            time: '1d'
          },
          {
            title: 'processed 4 profiles',
            time: '2d'
          },
          {
            title: 'processed 4 profiles',
            time: '2d'
          },
          {
            title: 'processed 4 profiles',
            time: '2d'
          },
          {
            title: 'processed 4 profiles',
            time: '3d'
          },
          {
            title: 'processed 4 profiles',
            time: '3d'
          },
        ]
      }
    }
  }

</script>
