import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    submit() {
        let form = document.getElementById("psu_filters");
        form.submit();
    }
};
