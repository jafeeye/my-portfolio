---
title: js
toc: true
date: 2026-06-21
---
跳過影片檢查
```js
const v = document.querySelector("video"); 
v.currentTime = v.duration; 
v.dispatchEvent(new Event("ended"));
```

