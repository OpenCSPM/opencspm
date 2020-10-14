import {
  Bar
} from 'vue-chartjs'
export default {
  extends: Bar,
  props: {
    chartData: {
      type: Array,
      required: false
    },
    chartLabels: {
      type: Array,
      required: true
    }
  },
  data() {
    return {
      options: {
        scales: {
          yAxes: [{
            ticks: {
              beginAtZero: true,
              stepSize: 1,
              suggestedMax: 10
            },
            gridLines: {
              display: true
            }
          }],
          xAxes: [{
            ticks: {
              padding: 0,
              display: true,
              maxTicksLimit: 15,
            },
            gridLines: {
              display: false,
            }
          }]
        },
        legend: {
          display: false
        },
        responsive: true,
        maintainAspectRatio: false
      }
    }
  },
  mounted() {
    this.renderChart({
        labels: this.chartLabels,
        datasets: [{
          label: 'Failed controls',
          borderColor: '#249EBF',
          borderWidth: 1,
          pointBorderColor: '#249EBF',
          backgroundColor: '#76a9fa',
          data: this.chartData
        }]
      },
      this.options
    )
  }
}
