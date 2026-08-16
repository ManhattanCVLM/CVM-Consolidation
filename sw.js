/* CVM Maturity Assessment — offline service worker.

   The page itself is fetched NETWORK FIRST; everything else is cache first.

   That split is the whole point. A wholly cache-first worker serves the copy it
   already has and only fetches the new one in the background, so the first visit
   after an update still shows the old app and you need a second visit to see the
   new one — which reads, correctly, as "the update did not work". Network first
   for the page means a reload with any signal at all gets the current version;
   the cached copy is the fallback when the network fails or is slow, so it still
   opens instantly on a train.

   Assets — icons, the manifest — stay cache first: they are small, they rarely
   change, and they change with the cache name when they do.

   Bump CACHE whenever index.html changes. */
const CACHE = "cvm-consolidate-v11";
const ASSETS = [
  "./",
  "./index.html",
  "./manifest.webmanifest",
  "./icon-192.png",
  "./icon-512.png",
  "./icon-512-maskable.png",
  "./apple-touch-icon.png"
];
const PAGE_TIMEOUT = 3500;      // beyond this, a slow network is worse than yesterday's copy

/* No skipWaiting here on purpose. A new worker that takes over the moment it
   installs would swap the app out from under someone mid-question — and since
   the page reloads when control changes, that is a reload they did not ask for.
   It waits instead, the page offers "a new version is ready", and the swap
   happens when they say so. The page itself is already current either way,
   because navigations are network first. */
self.addEventListener("install", event => {
  event.waitUntil(caches.open(CACHE).then(c => c.addAll(ASSETS)));
});

self.addEventListener("activate", event => {
  event.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

/* The page asks for this when someone taps "Reload now" on the update notice. */
self.addEventListener("message", event => {
  if (event.data && event.data.type === "SKIP_WAITING") self.skipWaiting();
});

function cached(req) {
  return caches.match(req, { ignoreSearch: true })
    .then(hit => hit || caches.match("./index.html"));
}

self.addEventListener("fetch", event => {
  const req = event.request;
  if (req.method !== "GET" || new URL(req.url).origin !== self.location.origin) return;

  // The page: newest wins, with the cache as the safety net.
  if (req.mode === "navigate" || (req.destination === "document")) {
    event.respondWith(
      new Promise(resolve => {
        let settled = false;
        const done = r => { if (!settled) { settled = true; resolve(r); } };
        const timer = setTimeout(() => cached(req).then(done), PAGE_TIMEOUT);
        fetch(req)
          .then(res => {
            clearTimeout(timer);
            if (res && res.ok) caches.open(CACHE).then(c => c.put("./index.html", res.clone()));
            done(res);
          })
          .catch(() => { clearTimeout(timer); cached(req).then(done); });
      })
    );
    return;
  }

  // Everything else: instant from cache, refreshed quietly for next time.
  event.respondWith(
    caches.match(req, { ignoreSearch: true }).then(hit => {
      if (hit) {
        fetch(req).then(res => {
          if (res && res.ok) caches.open(CACHE).then(c => c.put(req, res.clone()));
        }).catch(() => {});
        return hit;
      }
      return fetch(req)
        .then(res => {
          if (res && res.ok) {
            const copy = res.clone();
            caches.open(CACHE).then(c => c.put(req, copy));
          }
          return res;
        })
        .catch(() => caches.match("./index.html"));
    })
  );
});
