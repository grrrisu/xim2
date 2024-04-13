import Chart from "chart.js/auto";
import 'chartjs-adapter-moment';
import moment from 'moment';

const MonitorHook = {
  mounted() {
    const chart = new Chart(this.el, {
      type: 'line',
      data: {
        labels: [1,2,3],
        datasets: [{
          label: 'Duration',
          borderColor: "rgb(6, 182, 212, 0.8)",
          backgroundColor: "rgb(14, 116, 144, 0.8)",
          lineTension: 0,
          borderWidth: 2
        }]
      },
      options: {
        responsive: true,
        scales: {
          x: {
            display: true,
            type: 'timeseries',
            min: moment().toISOString(),
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
    })

    this.handleEvent("update-duration-chart", (data) => {
      chart.data.labels.push(data.x_axis);
      chart.data.datasets[0].data.push(data.duration);
      chart.update();
    });
  }
}

const DurationSummaryHook = {
  mounted() {
    const chart = new Chart(this.el, {
      type: 'line',
      data: {
        labels: [1,2,3],
        datasets: [{
          label: 'Vegetation',
          borderColor: "rgb(16, 185, 129, 0.8)",
          backgroundColor: "rgb(4, 120, 87, 0.8)",
          fill: true,
          lineTension: 0,
          borderWidth: 2
        },
        {
          label: 'Herbivore',
          borderColor: "rgb(249, 115, 22, 0.8)",
          backgroundColor: "rgb(194, 65, 12, 0.8)",
          fill: true,
          lineTension: 0,
          borderWidth: 2
        },
        {
          label: 'Predator',
          borderColor: "rgb(241, 65, 94, 0.8)",
          backgroundColor: "rgb(180, 14, 41, 0.8)",
          fill: true,
          lineTension: 0,
          borderWidth: 2
        }]
      },
      options: {
        responsive: true,
        scales: {
          x: {
            display: true,
            type: 'timeseries',
            min: moment().toISOString(),
            ticks: {
              color: "rgb(14, 165, 233, 0.8)",
            },
            
          },
          y: {
            stacked: true,
            display: true,
            beginAtZero: true,
            ticks: {
              color: "rgb(14, 165, 233, 0.8)",
            },
          }
        }
      }
    })

    this.handleEvent("update-duration-summary-chart", (data) => {
      chart.data.labels.push(data.x_axis);
      chart.data.datasets[0].data.push(data.vegetation);
      chart.data.datasets[1].data.push(data.herbivore);
      chart.data.datasets[2].data.push(data.predator);
      chart.update();
    });
  }
}

const OkSummaryHook = {
  mounted() {
    const chart = new Chart(this.el, {
      type: 'line',
      data: {
        labels: [1,2,3],
        datasets: [{
          label: 'Vegetation',
          borderColor: "rgb(16, 185, 129, 0.8)",
          backgroundColor: "rgb(4, 120, 87, 0.8)",
          lineTension: 0,
          borderWidth: 2
        },
        {
          label: 'Herbivore',
          borderColor: "rgb(249, 115, 22, 0.8)",
          backgroundColor: "rgb(194, 65, 12, 0.8)",
          lineTension: 0,
          borderWidth: 2
        },
        {
          label: 'Predator',
          borderColor: "rgb(241, 65, 94, 0.8)",
          backgroundColor: "rgb(180, 14, 41, 0.8)",
          lineTension: 0,
          borderWidth: 2
        }]
      },
      options: {
        responsive: true,
        scales: {
          x: {
            display: true,
            type: 'timeseries',
            min: moment().toISOString(),
            ticks: {
              color: "rgb(14, 165, 233, 0.8)",
            },
            
          },
          y: {
            display: true,
            //beginAtZero: false,
            ticks: {
              color: "rgb(14, 165, 233, 0.8)",
            },
          }
        }
      }
    })

    this.handleEvent("update-ok-summary-chart", (data) => {
      chart.data.labels.push(data.x_axis);
      chart.data.datasets[0].data.push(data.vegetation);
      chart.data.datasets[1].data.push(data.herbivore);
      chart.data.datasets[2].data.push(data.predator);
      chart.update();
    });
  }
}

export {MonitorHook, DurationSummaryHook, OkSummaryHook};