import { Controller } from "@hotwired/stimulus";
import { DirectUpload } from "@rails/activestorage";

export default class extends Controller {
  static targets = ["input", "loader", "preview", "unloader"];

  uploadFile() {
    Array.from(this.inputTarget.files).forEach((file) => {
      this.showLoader(true)

      const upload = new DirectUpload(
        file,
        '/rails/active_storage/direct_uploads'
      );

      upload.create((error, blob) => {
        if (error) {
          this.showLoader(false)
        } else {
          this.createHiddenBlobInput(blob);
          this.inputTarget.value = null;
          this.updatePreview(blob);
          this.showLoader(false)
        }
      });
    });
  }

  showLoader(val) {
    if (val) {
      this.loaderTarget.classList.remove('hidden');
      if (this.hasUnloaderTarget) {
        this.unloaderTarget.classList.add('hidden');
      }
      this.loaderTarget.disabled = false;
    } else {
      this.loaderTarget.classList.add('hidden');
      if (this.hasUnloaderTarget) {
        this.unloaderTarget.classList.remove('hidden');
      }
    }
  }

  // add blob id to be submitted with the form
  createHiddenBlobInput(blob) {
    const hiddenField = document.createElement("input");
    hiddenField.setAttribute("type", "hidden");
    hiddenField.setAttribute("value", blob.signed_id);
    hiddenField.name = this.inputTarget.name;
    this.element.appendChild(hiddenField);
  }

  updatePreview(blob) {
    let url = `/rails/active_storage/blobs/${blob.signed_id}/${blob.filename}`;

    if (this.previewTarget.tagName === "IMG") {
      this.previewTarget.src = url;
    } else {
      this.previewTarget.style.backgroundImage = `url("${url}")`;
    }
  }
}