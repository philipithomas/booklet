import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["edit", "delete"];
  static values = { memberId: Number };

  connect() {
    const memberId = parseInt(document.querySelector("meta[name='current-member-id']").content);
    const memberPermission = document.querySelector("meta[name='current-member-permission']").content;

    // Show edit link if the reply's member matches the current member
    if (memberId === this.memberIdValue) {
      this.editTarget.classList.remove("hidden");
    }

    // Show delete link if the member can edit or their permission is admin/manager
    if (memberId === this.memberIdValue || memberPermission === "admin" || memberPermission === "manager") {
      this.deleteTarget.classList.remove("hidden");
    }
  }
}
