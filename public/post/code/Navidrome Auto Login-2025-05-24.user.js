// ==UserScript==
// @name         Navidrome Auto Login (修正版)
// @namespace    http://tampermonkey.net/
// @version      2025-05-20 // 建議更新版本號
// @description  自動填入 Navidrome 登入資訊（支援 React）
// @author       You
// @match        http://192.168.8.104:4533/app*
// @grant        none
// @run-at       document-idle // 可以嘗試 document-idle，確保 DOM 結構較為穩定後執行
// ==/UserScript==

(function() {
  'use strict';

  // === 你的 Navidrome 登入資訊 ===
  const username = 'root';
  const password = '';

  // === 觸發 React 的更新事件 ===
  function reactInput(inputElement, value) {
    if (!inputElement) {
      console.error('reactInput: inputElement is null');
      return;
    }
    const nativeInputValueSetter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    nativeInputValueSetter.call(inputElement, value);

    const ev = new Event('input', { bubbles: true });
    inputElement.dispatchEvent(ev);
  }

  console.log('Navidrome Auto Login script started.');

  // === 定期檢查是否載入好欄位 ===
  const interval = setInterval(() => {
    console.log('Checking for login elements...');

    // 嘗試使用 data-testid (Navidrome 常用) 或 name 屬性
    const userInput = document.querySelector('input[data-testid="username"]') || document.querySelector('input[name="username"]');
    const passInput = document.querySelector('input[data-testid="password"]') || document.querySelector('input[name="password"]');
    // 登入按鈕也可能使用 data-testid，或者 type="submit"
    const loginButton = document.querySelector('button[data-testid="loginButton"]') || document.querySelector('button[type="submit"]');

    // 確認是否在登入頁面 (一個簡單的判斷方式是這些元素是否存在)
    // Navidrome 的登入頁面 URL 通常包含 /login (例如 /app/#/login)
    // 如果你想更精確，可以檢查 window.location.hash 或 window.location.pathname
    // 例如: if (!window.location.hash.includes('/login') && !(userInput && passInput && loginButton)) {
    //    console.log('Not on login page or elements not found, clearing interval.');
    //    clearInterval(interval); // 如果不在登入頁，或已登入，則停止
    //    return;
    // }


    if (userInput && passInput && loginButton) {
      console.log('Login elements found:', {userInput, passInput, loginButton});
      clearInterval(interval); // 找到元素後就清除計時器

      // 檢查元素是否可見且可用 (非必須，但有助於調試)
      if (userInput.offsetParent === null || passInput.offsetParent === null || loginButton.offsetParent === null) {
          console.warn("Elements found but may not be visible/interactive yet. Proceeding anyway.");
      }
      if (loginButton.disabled) {
          console.warn("Login button is disabled. Waiting a bit before click might help if it enables later.");
      }

      // 使用 reactInput 觸發 React/Vue 更新
      console.log('Attempting to fill username...');
      reactInput(userInput, username);
      console.log('Attempting to fill password...');
      reactInput(passInput, password);

      // 增加一個小延遲，確保 React 有時間處理 input 事件，例如更新按鈕的啟用狀態
      setTimeout(() => {
        if (loginButton.disabled) {
            console.error("Login button is still disabled before click. Login might fail.");
        }
        console.log('Attempting to click login button...');
        loginButton.click();
        console.log('Login button clicked.');
      }, 500); // 嘗試 500ms 延遲，可以根據情況調整

    } else {
      // 如果開發者工具中能手動選到元素，但腳本找不到，可能是時機問題
      // console.log('Login elements not found yet. User:', !!userInput, 'Pass:', !!passInput, 'Button:', !!loginButton);
    }
  }, 500); // 檢查頻率設為 500ms
})();

