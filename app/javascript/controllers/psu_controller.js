import { Controller } from "@hotwired/stimulus"
// import { get } from "@rails/request.js"

export default class extends Controller {
  change(event) {
    // console.log(event.target.value);

    document.getElementById("psu_form").submit()

    // get(`/power_supplies?manufacturer=${event.target.value}`, {
    //   responseKind: "turbo-stream"
    // })
  }
}
