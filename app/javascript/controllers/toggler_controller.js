import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    submit() {
        let form = this.element.getElementsByTagName("form")[0];
        form.submit();
    }
}
