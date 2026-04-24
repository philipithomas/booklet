importScripts(
  "https://storage.googleapis.com/workbox-cdn/releases/6.4.1/workbox-sw.js",
);

const { CacheFirst, NetworkFirst } = workbox.strategies;
const { registerRoute } = workbox.routing;

// For every other page we use network first to ensure the most up-to-date resources
registerRoute(
  ({ request }) =>
    request.destination === "document" || request.destination === "",
  new NetworkFirst({
    cacheName: "documents",
  }),
);

// For assets (scripts and styles), we use cache first
registerRoute(
  ({ request }) =>
    request.destination === "script" || request.destination === "style",
  new CacheFirst({
    cacheName: "assets-styles-and-scripts",
  }),
);

// For images, we use cache first
registerRoute(
  ({ request }) => request.destination === "image",
  new CacheFirst({
    cacheName: "assets-images",
  }),
);

self.addEventListener("push", async (event) => {
  const data = await event.data.json();
  event.waitUntil(
    Promise.all([showNotification(data), updateBadgeCount(data.options)]),
  );
});

async function showNotification({ title, options }) {
  return self.registration.showNotification(title, options);
}

async function updateBadgeCount({ data: { badge } }) {
  return self.navigator.setAppBadge?.(badge || 0);
}

self.addEventListener("notificationclick", (event) => {
  event.notification.close();

  const url = new URL(event.notification.data.path, self.location.origin).href;
  event.waitUntil(openURL(url));
});

async function openURL(url) {
  const clients = await self.clients.matchAll({ type: "window" });
  const focused = clients.find((client) => client.focused);

  if (focused) {
    await focused.navigate(url);
  } else {
    await self.clients.openWindow(url);
  }
}
