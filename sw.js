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
const CACHE = "cvm-consolidate-v20";
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

/* Which URL is the app itself. Everything else in this folder — a checker page,
   a note, anything added later — is an ordinary page and must be treated as one.

   Getting this wrong caused two faults worth naming. Any successful navigation
   was being stored AS index.html, so opening a sibling page replaced the cached
   app with that page. And any path the server did not have fell back to serving
   index.html, so a missing or mistyped URL silently opened the assessment
   instead of saying "not found" — which is what made a checker page that had not
   been uploaded yet look as though it opened the assessment. */
const SCOPE_PATH = (() => {
  try { return new URL(self.registration.scope).pathname; } catch (e) { return "/"; }
})();
const isAppPage = url => {
  try {
    const p = new URL(url).pathname;
    return p === SCOPE_PATH || p === SCOPE_PATH + "index.html";
  } catch (e) { return false; }
};

/* Newest wins, with what is already here as the safety net. */
function networkFirst(req, cacheAs) {
  return new Promise(resolve => {
    let settled = false;
    const done = r => { if (!settled) { settled = true; resolve(r); } };
    const fallback = () => caches.match(cacheAs || req, { ignoreSearch: true }).then(hit => hit || null);
    const timer = setTimeout(() => fallback().then(hit => { if (hit) done(hit); }), PAGE_TIMEOUT);
    fetch(req)
      .then(res => {
        clearTimeout(timer);
        if (res && res.ok) {
          const copy = res.clone();
          caches.open(CACHE).then(c => c.put(cacheAs || req, copy));
          done(res);
        } else {
          /* A 404 or a 500 is a reply, not an app. Prefer the copy of THIS page if
             there is one; otherwise pass the server's answer through honestly. */
          fallback().then(hit => done(hit || res));
        }
      })
      .catch(() => { clearTimeout(timer); fallback().then(hit => done(hit || Response.error())); });
  });
}

self.addEventListener("fetch", event => {
  const req = event.request;
  if (req.method !== "GET" || new URL(req.url).origin !== self.location.origin) return;

  if (req.mode === "navigate" || req.destination === "document") {
    // The app keeps its canonical cache entry; any other page caches under its own URL.
    event.respondWith(networkFirst(req, isAppPage(req.url) ? "./index.html" : null));
    return;
  }

  // Assets: instant from cache, refreshed quietly for next time.
  event.respondWith(
    caches.match(req, { ignoreSearch: true }).then(hit => {
      if (hit) {
        fetch(req).then(res => {
          if (res && res.ok) caches.open(CACHE).then(c => c.put(req, res.clone()));
        }).catch(() => {});
        return hit;
      }
      /* No index.html fallback here: handing the app's HTML back in place of a
         missing icon or script hides the real failure. */
      return fetch(req).then(res => {
        if (res && res.ok) {
          const copy = res.clone();
          caches.open(CACHE).then(c => c.put(req, copy));
        }
        return res;
      }).catch(() => Response.error());
    })
  );
});
