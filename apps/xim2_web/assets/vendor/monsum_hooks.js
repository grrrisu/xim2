export default {
  Json: {
    mounted() {
      this.handleEvent(`update-json-${this.el.id}`, (data) => {
        this.el.textContent = JSON.stringify(data, undefined, 2);
      });
    }
  }
}