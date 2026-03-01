// 1분사주 Service Worker - PWA/TWA 오프라인 지원
const CACHE_NAME = '1min-saju-v1';
const OFFLINE_URL = '/offline.html';

// 캐시할 정적 리소스
const PRECACHE_URLS = [
    '/',
    '/manifest.json',
    '/icon-192.png',
    '/icon-512.png'
];

// 설치 시 캐시
self.addEventListener('install', (event) => {
    event.waitUntil(
        caches.open(CACHE_NAME).then((cache) => {
            return cache.addAll(PRECACHE_URLS);
        })
    );
    self.skipWaiting();
});

// 활성화 시 이전 캐시 정리
self.addEventListener('activate', (event) => {
    event.waitUntil(
        caches.keys().then((cacheNames) => {
            return Promise.all(
                cacheNames
                    .filter((name) => name !== CACHE_NAME)
                    .map((name) => caches.delete(name))
            );
        })
    );
    self.clients.claim();
});

// 네트워크 우선, 실패 시 캐시
self.addEventListener('fetch', (event) => {
    if (event.request.method !== 'GET') return;

    event.respondWith(
        fetch(event.request)
            .then((response) => {
                // 성공하면 캐시에도 저장
                const clone = response.clone();
                caches.open(CACHE_NAME).then((cache) => {
                    cache.put(event.request, clone);
                });
                return response;
            })
            .catch(() => {
                // 네트워크 실패 시 캐시에서
                return caches.match(event.request);
            })
    );
});
