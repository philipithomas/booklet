import { ColorPreview } from "tailwindcss-stimulus-components"

export default class ColorPicker extends ColorPreview {
    update_form() {
        this.colorTarget.setAttribute('value', this.color);
    }
}