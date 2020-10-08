<template>
  <div>
    <Chart :chart-data="data"
           :chart-labels="labels" />
  </div>
</template>

<script>
  import Chart from './BarChart.js'

  export default {
    components: {
      Chart
    },
    props: ['data', 'labels'],
    data() {
      return {
        chartOptions: {
          responsive: true
        }
      }
    }
  }

</script>
