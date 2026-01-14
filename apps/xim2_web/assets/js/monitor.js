import Chart from "chart.js/auto";
import 'chartjs-adapter-moment';

const chartOptions = {
  responsive: true,
  scales: {
    x: {
      display: true,
      type: 'time',
      time: {
        displayFormats: {
          second: 'mm:ss',
          minute: 'mm',
          hour: 'HH:mm',
          day: 'MMM dd'
        }
      },
      ticks: {
        color: "rgb(14, 165, 233, 0.8)",
      },

    },
    y: {
      display: true,
      beginAtZero: false,
      ticks: {
        color: "rgb(14, 165, 233, 0.8)",
      },
    }
  }
}

const initChart = function (chart, data) {
  if (data.type) chart.config.type = data.type
  chart.data.datasets = data.datasets;
  if (data.options.stacked) chart.options.scales.y.stacked = data.options.stacked;
  if (data.options.beginAtZero) chart.options.scales.y.beginAtZero = data.options.beginAtZero;
  chart.update();
}

const trimData = function (chart, maxDataPoints) {
  if (chart.data.labels.length > maxDataPoints) {
    chart.data.labels.shift();
    chart.data.datasets.forEach((_dataset, i) => {
      chart.data.datasets[i].data.shift();
    });
  }
}

// const MonitorHook = {
//   mounted() {
//     const chart = new Chart(this.el, {
//       type: 'line',
//       data: {
//         labels: [1, 2, 3],
//         datasets: [{
//           label: 'Duration',
//           borderColor: "rgb(6, 182, 212, 0.8)",
//           backgroundColor: "rgb(14, 116, 144, 0.8)",
//           lineTension: 0,
//           borderWidth: 2
//         }]
//       },
//       options: {
//         responsive: true,
//         scales: {
//           x: {
//             display: true,
//             type: 'time',
//             time: {
//               displayFormats: {
//                 second: 'mm:ss',
//                 minute: 'mm',
//                 hour: 'HH:mm',
//                 day: 'MMM dd'
//               }
//             },
//             ticks: {
//               color: "rgb(14, 165, 233, 0.8)",
//             },

//           },
//           y: {
//             display: true,
//             beginAtZero: false,
//             ticks: {
//               color: "rgb(14, 165, 233, 0.8)",
//             },
//           }
//         }
//       }
//     })

//     this.handleEvent("update-duration-chart", (data) => {
//       console.log("chart")
//       console.log(data)
//       chart.data.labels.push(new Date(data.time));
//       chart.data.datasets[0].data.push(data.duration);

//       // Limit the number of data points to prevent memory issues
//       const maxDataPoints = 200;
//       if (chart.data.labels.length > maxDataPoints) {
//         chart.data.labels.shift();
//         chart.data.datasets[0].data.shift();
//       }
//       chart.update();
//     });
//   }
// }

const ChartHook = {
  mounted() {
    const chart = new Chart(this.el, {
      type: 'line',
      data: {
        datasets: []
      },
      options: chartOptions
    });

    this.handleEvent(`init-chart-${this.el.id}`, (data) => {
      initChart(chart, data)
    });

    this.handleEvent(`update-chart-${this.el.id}`, (data) => {
      tmpData[data.index] = data.result;
      chart.data.labels.push(data.x_axis);
      data.results.forEach((result, index) => {
        chart.data.datasets[index].data.push(result);
      })
      trimData(chart, 100)
      chart.update();
    });
  }
}

const ChartAsyncHook = {
  mounted() {
    const chart = new Chart(this.el, {
      type: 'line',
      data: {
        datasets: []
      },
      options: chartOptions
    });

    var tmpData = [];

    this.handleEvent(`init-chart-${this.el.id}`, (data) => {
      initChart(chart, data)
    });

    this.handleEvent(`update-chart-${this.el.id}`, (data) => {
      tmpData[data.index] = data.result;
      if (data.index == chart.data.datasets.length - 1) {
        trimData(chart, 100)
        chart.data.labels.push(data.x_axis);
        tmpData.forEach((result, index) => {
          chart.data.datasets[index].data.push(result);
        })

        chart.update();
      }
    });
  }
}

export { ChartAsyncHook, ChartHook };
