import { Controller } from "@hotwired/stimulus";
import ahoy from "ahoy.js";
import { getCookie, setCookie } from "./lib/cookie";

export default class extends Controller {
  connect() {
    // Clear the app badge when the user opens the app
    if (navigator.clearAppBadge) {
      navigator.clearAppBadge().catch((error) => {
        console.error("Error clearing app badge:", error);
      });
    }
  }

  requestNotificationPermission() {
    // Check if the browser supports notifications
    if (this.notificationsAvailable()) {
      // Request permission from the user to send notifications
      Notification.requestPermission().then((permission) => {
        ahoy.track("push_notifications_request", { permission });
        if (permission === "granted") {
          // If permission is granted, register the service worker
          this.registerServiceWorker();
          ahoy.track("push_notifications_granted");
        } else if (permission === "denied") {
          console.warn("member rejected to allow notifications.");
          ahoy.track("push_notifications_denied");
        } else {
          console.warn("User still didn't give an answer about notifications.");
        }
      });
    } else {
      console.warn("Push notifications not supported.");
    }
    this.markPromptedNotifications();
  }

  notificationsAvailable() {
    return "Notification" in window;
  }

  notificationsDenied() {
    this.markPromptedNotifications();
  }

  registerServiceWorker() {
    // Check if the browser supports service workers
    if ("serviceWorker" in navigator) {
      // Register the service worker script (service_worker.js)
      navigator.serviceWorker
        .register("/service_worker.js")
        .then((serviceWorkerRegistration) => {
          // Check if a subscription to push notifications already exists
          serviceWorkerRegistration.pushManager
            .getSubscription()
            .then((existingSubscription) => {
              if (!existingSubscription) {
                // If no subscription exists, subscribe to push notifications
                serviceWorkerRegistration.pushManager
                  .subscribe({
                    userVisibleOnly: true,
                    applicationServerKey: this.vapidPublicKey(),
                  })
                  .then((subscription) => {
                    // Save the subscription on the server
                    this.saveSubscription(subscription);
                  });
              }
            });
        })
        .catch((error) => {
          console.error("Error during registration Service Worker:", error);
        });
    }
  }

  vapidPublicKey() {
    const encodedVapidPublicKey =
      document.querySelector('meta[name="vapid-public-key"]').content;
    return this.urlBase64ToUint8Array(encodedVapidPublicKey);
  }

  urlBase64ToUint8Array(base64String) {
    const padding = "=".repeat((4 - base64String.length % 4) % 4);
    const base64 = (base64String + padding).replace(/-/g, "+").replace(
      /_/g,
      "/",
    );
    const rawData = window.atob(base64);
    const outputArray = new Uint8Array(rawData.length);

    for (let i = 0; i < rawData.length; ++i) {
      outputArray[i] = rawData.charCodeAt(i);
    }

    return outputArray;
  }

  saveSubscription(subscription) {
    // Extract necessary subscription data
    const endpoint = subscription.endpoint;
    const p256dh = btoa(
      String.fromCharCode.apply(
        null,
        new Uint8Array(subscription.getKey("p256dh")),
      ),
    );
    const auth = btoa(
      String.fromCharCode.apply(
        null,
        new Uint8Array(subscription.getKey("auth")),
      ),
    );

    // Send the subscription data to the server
    fetch("/push_subscriptions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        "X-CSRF-Token": document
          .querySelector('meta[name="csrf-token"]')
          .getAttribute("content"),
      },
      body: JSON.stringify({ endpoint, p256dh, auth }),
    })
      .then((response) => {
        if (response.ok) {
          ahoy.track("push_subscription_saved");
          console.log("Subscription successfully saved on the server.");
        } else {
          ahoy.track("push_subscription_error");
          console.error("Error saving subscription on the server.");
        }
      })
      .catch((error) => {
        ahoy.track("push_subscription_error", { error });
        console.error("Error sending subscription to the server:", error);
      });
  }

  isPWA() {
    return window.matchMedia("(display-mode: standalone)").matches;
  }

  hasPromptedNotifications() {
    if (this.isPWA()) {
      return getCookie("notifications-pwa-prompted");
    } else {
      return getCookie("notifications-prompted");
    }
  }

  markPromptedNotifications = (event) => {
    if (this.isPWA()) {
      setCookie("notifications-pwa-prompted", true);
    } else {
      setCookie("notifications-prompted", true);
    }
  };
}
