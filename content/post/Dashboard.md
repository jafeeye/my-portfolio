---
title: Dashboard 方案
toc: true
date: 2026-07-10
---
## Homer
```
nano /var/www/html/dashboard/assets/custom.css



```


## Flame
https://github.com/pawelmalak/flame




## Flare
https://soulteary.com/2022/02/23/building-a-personal-bookmark-navigation-app-from-scratch-flare.html

## jump
https://github.com/daledavies/jump


## Glance/ Dynacat


![](static/i-really-like-how-easy-it-is-to-custom-glance-dynacat-v0-k1lom1cndv0h1.webp)


```
          - type: group
            widgets:
              - type: reddit
                subreddit: selfhosted
                show-thumbnails: true
                collapse-after: 8
              - type: reddit
                subreddit: pcmasterrace
                show-thumbnails: true
                collapse-after: 8
              - type: reddit
                subreddit: plex
                show-thumbnails: true
                collapse-after: 8
              - type: reddit
                subreddit: bookstack
                show-thumbnails: true
                collapse-after: 8
              - type: reddit
                subreddit: 3Dprinting
                show-thumbnails: true
                collapse-after: 8
              - type: reddit
                subreddit: bambulab
                show-thumbnails: true
                collapse-after: 8
```

```censored.yaml
## BRANDING ###
server:
  assets-path: /app/assets
 
branding:
  logo-url: /assets/logo.png
  favicon-url: /assets/logo.png
 
theme:
  custom-css-file: /assets/style.css
  light: true
  background-color: 34 30 94


### PAGES ###
pages:
  ### HOME ###
  - name: Home
    # Optionally, if you only have a single page you can hide the desktop navigation for a cleaner look
    hide-desktop-navigation: true
    columns:
      - size: small
        widgets:
          - type: clock
            title: TIME
            hour-format: 24h
            
          - type: bookmarks
            title: APPS
            groups:
              - title:
                same-tab: true
                links:
                  - title: NAS
                    url: https://nas.my-nas.com
                    icon: mdi:nas


          - type: releases
            cache: 1d
            show-source-icon: true
            token: ${GITHUB_TOKEN}
            limit: 20
            collapse-after: 4
            repositories:
              - codeberg:bookstack/bookstack
              - paperless-ngx/paperless-ngx
              - dani-garcia/vaultwarden


### MIDDLE ROW ###
      - size: full
        widgets:
          - type: custom-api
            title: Ce jour-là
            cache: 24h
            template: |
              {{ $month := now.Format "01" }}
              {{ $day := now.Format "02" }}
              {{ $url := printf "https://fr.wikipedia.org/api/rest_v1/feed/onthisday/events/%s/%s" $month $day }}
              {{ $resp := newRequest $url | withHeader "User-Agent" "yourNameDashboard/1.0 (https://yourdomain.com)" | getResponse }}
              {{ $events := $resp.JSON.Array "events" }}
              {{ $count := len $events }}
              {{ if gt $count 0 }}
                {{ $seed := add (mul now.Year 366) now.YearDay }}
                {{ $idx := mod $seed $count }}
                {{ range $i, $e := $events }}
                  {{ if eq $i $idx }}
                    {{ $year := $e.Int "year" }}
                    {{ $yearsAgo := sub now.Year $year }}
                    {{ $link := $e.String "pages.0.content_urls.desktop.page" }}
                    <p class="size-h4 color-paragraph">
                      <span class="color-highlight">{{ $year }}</span> ·
                      {{ if $link }}
                        <a href="{{ $link }}" target="_blank" rel="noopener noreferrer">{{ $e.String "text" }}</a>
                      {{ else }}
                        {{ $e.String "text" }}
                      {{ end }}
                    </p>
                    {{ if gt $yearsAgo 0 }}
                      <p class="size-h6 color-subdue">Il y a {{ $yearsAgo }} an{{ if gt $yearsAgo 1 }}s{{ end }}</p>
                    {{ end }}
                  {{ end }}
                {{ end }}
              {{ else }}
                <p class="size-h4 color-paragraph">Aucun événement trouvé pour aujourd'hui.</p>
              {{ end }}
              
          - type: group
            widgets:
              - type: reddit
                subreddit: selfhosted
                show-thumbnails: true
                collapse-after: 8
              - type: reddit
                subreddit: pcmasterrace
                show-thumbnails: true
                collapse-after: 8
              - type: reddit
                subreddit: plex
                show-thumbnails: true
                collapse-after: 8
              - type: reddit
                subreddit: bookstack
                show-thumbnails: true
                collapse-after: 8
              - type: reddit
                subreddit: 3Dprinting
                show-thumbnails: true
                collapse-after: 8
              - type: reddit
                subreddit: bambulab
                show-thumbnails: true
                collapse-after: 8


          - type: videos
            include-shorts: true
            channels:
              - UC_yP2DpIgs5Y1uWC0T03Chw # JDG
              - UCeeFfhMcJa1kjtfZAGskOCA # TechLinked
              - UC_R99mJdkzksbgeedOyLbKw # Ici Japon Corp.
              - UCeGEv5MBdmGMgZFPrAlEmFA # Tev - Ici Japon
              - UCPTlw9-dflN3_Sw9AfQs3vw # Faune Cool
              - UCH66RFWfw6CSm2T1EM4ik1g # Bookstack
              - UC4peNo-31r7fhQZgu0_JRIA # Sheshounet
              - UCDsMKIpr1ZHXHpACszKpRUw # JRM
              - UCMQSwUNSnMOP4IRysfeg8EA # Simon Puech
              - UCseGV3amBLISlIOMQodPfVQ # Sylvqin
              - UCGt553K1a2MNHfioKJFPCPA # ThéoBabac
              - UCHDxYLv8iovIbhrfl16CNyg # GameLinked
              - UC17vsYVoIwch5UzPar1LDmQ # ymfah


### RIGHT ROW ###
      - size: small
        widgets:
          - type: custom-api
            title: Paperless-NGX
            title-url: ${PAPERLESS_URL}
            url: ${PAPERLESS_URL}/api/statistics/
            headers:
              Authorization: Token ${PAPERLESS_TOKEN}
              Accept: application/json
            cache: 1m
            template: |
              {{ $total := .JSON.Int "documents_total" }}
              {{ $inbox := .JSON.Int "documents_inbox" }}
              {{ $correspondents := .JSON.Int "correspondent_count" }}


              <div class="flex justify-between text-center">
                <div>
                  {{ if gt $inbox 0 }}
                    <a href="${PAPERLESS_URL}/view/3"
                       target="_blank"
                       rel="noopener noreferrer"
                       style="text-decoration:none; color:inherit;">
                      <div class="size-h3" style="color: var(--color-negative) !important;">
                        {{ $inbox | formatNumber }}
                      </div>
                      <div class="size-h5 uppercase" style="color: var(--color-negative) !important;">
                        Inbox
                      </div>
                    </a>
                  {{ else }}
                    <div class="color-highlight size-h3">{{ $inbox | formatNumber }}</div>
                    <div class="size-h5 uppercase">À traiter</div>
                  {{ end }}
                </div>


                <div>
                  <div class="color-highlight size-h3">{{ $total | formatNumber }}</div>
                  <div class="size-h5 uppercase">Factures</div>
                </div>


                <div>
                  <div class="color-highlight size-h3">{{ $correspondents | formatNumber }}</div>
                  <div class="size-h5 uppercase">Correspondents</div>
                </div>
              </div>


          - type: group
            widgets:
              - type: bookmarks
                title: Tools
                groups:
                  - same-tab: true
                    links:
                      - title: Center text
                        url: https://onlinetexttools.com/center-text
                      - title: Check driver
                        url: https://www.pcilookup.com/
                      - title: IconsDB
                        url: https://www.iconsdb.com/
                      - title: iLovePDF
                        url: https://www.ilovepdf.com/fr
                      - title: IT-Tools
                        url: https://it-tools.tech
                      - title: MailTo Maker
                        url: https://mailto.vercel.app/
                      - title: Pictogrammers
                        url: https://pictogrammers.com/library/mdi/
                      - title: SVG Converter
                        url: https://svgconverter.app/
              - type: bookmarks
                title: Media
                groups:
                  - same-tab: true
                    color: 40 100 50
                    links:
                      - title: JustWatch
                        url: https://www.justwatch.com/fr
                      - title: LetterBoxd
                        url: https://letterboxd.com/
                      - title: Plex
                        url: https://app.plex.tv/desktop/


              - type: bookmarks
                title: Web & Info
                groups:
                  - same-tab: true
                    color: 200 50 50
                    links:
                      - title: it-connect
                        url: https://www.it-connect.fr/
                      - title: MariusHosting
                        url: https://Mariushosting.com
                      - title: PhoenixJP
                        url: https://www.phoenixjp.info/news/fr/numeriques-1

```






## Heimdall

在Debian 13 LXC 安裝，沒出現畫面Console mode改成shell (13預設是php8.4 還要引入其他套件庫)

```
# 1.安裝依賴套件,因為heidmall是用php8.2開發,套件要裝8.2
apt update && apt install -y nginx unzip git
apt install -y php8.4-fpm php8.4-cli php8.4-sqlite3 php8.4-xml php8.4-zip php8.4-mbstring php8.4-curl php8.4-intl php8.4-gd
systemctl enable php8.4-fpm

# 2.github下載套件
mkdir -p /var/www/heimdall 
cd /var/www/heimdall
# 在後面加上一個點代表在目前資料夾不創專案目錄
git clone https://github.com/linuxserver/Heimdall.git .

# 3.給權限
cp .env.example .env 
# 產生密鑰 # (注意：Heimdall 基於 Laravel，若有 composer 可執行 php artisan key:generate，若無，可以直接用 LinuxServer 預編譯版本) 
chown -R www-data:www-data /var/www/heimdall 
chmod -R 775 /var/www/heimdall/storage
```
配置nginx
```
nano /etc/nginx/sites-available/default

server {
    # 修改 Heimdall 進入點 public 資料夾
    root /var/www/heimdall/public;
    index index.php index.html index.htm;

    server_name _;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    # 修改解析PHP腳本
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        # 注意：填上PHP版本,php -v，把php8.4-fpm 改對應版本
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
    }
    # 禁止任何人下載設定檔
    location ~ /\.ht {
        deny all;
    }
}
```
檢查有些頁面錯誤
```

systemctl restart php8.4-fpm 
systemctl restart nginx


tail -n 50 /var/log/nginx/error.log
2026/07/14 01:03:50 [notice] 4577#4577: using inherited sockets from "5;6;"
```

### 出現Server 500 錯誤





![](static/Pasted%20image%2020260712220933.png)

```
`body {  
background: #eee;  
}  
.app-icon {  
border-radius:6px;  
max-height: 50px !important;  
}  
#app main, #app #sortable{  
margin: auto;  
width: 1200px;  
}  
div.item {  
background-color:rgba(255,255,255,0.01) !important;  
border:0px solid rgba(215,215,215,0.5);  
width:130px !important;  
height: 130px !important;  
transform:scale(0.9);  
margin:20px 0 !important;  
text-align: center;  
display: block;  
padding-right: 15px !important;  
background-image: none;  
}  
div.app-icon-container {  
opacity:0.9;  
margin: 0 auto;  
background: white;  
border-radius: 6px;  
box-shadow: 0 1px 5px rgba(0,0,0,.3);  
padding: 15px;  
align-items: center;  
width: 80px;  
height: 80px;  
}  
.item::after {  
display:none;  
box-shadow:0 0 40px 0px rgba(0,0,0,0.1) !important;  
}  
svg.svg-inline--fa.fa-arrow-alt-to-right {  
color:rgba(30,30,30,0.5) !important;  
}  
.homesearch {  
height:40px;  
}  
.searchform button {  
height:40px;  
line-height:0px !important;  
}  
.searchform input {  
outline-style: none;  
}  
.searchform{  
margin: 50px auto 0px auto !important;  
}  
div#app{  
background-repeat: repeat;  
background-size: auto !important;  
}  
#config-buttons a{  
background: rgba(0, 0, 0, 0.12);  
}  
div#sortable.ui-sortable {  
padding-top:0px !important;  
}

.item .title {  
color: #000 !important;  
margin-top: 10px;  
text-shadow: 1px 1px 1px rgba(200,200,200,.5);  
}

svg.svg-inline--fa.fa-arrow-alt-to-right{  
display: none;  
}

.item .link {  
padding-right: 0px;  
}`
```

![](static/customised-heimdall-dashboard-with-css-v0-n279ilg3bhwc1.webp)

```
/*masonry grid layout*/
#app #sortable.categories{
     display:inline-block;
     column-count:4;
     display:block;
}

/*center all columns in screen.*/
#app #sortable.categories{
     width:min-content;
}

/*set column count depending on screen width*/
@media only screen and (max-device-width: 767px) {
     #app #sortable.categories{
          column-count:1;
     }
     #config-buttons a{
          width:35px;
          height:35px;
    }
}

@media only screen and (min-device-width: 768px) and (max-device-width: 1160px) {
     #app #sortable.categories{
          column-count:2;
     }
}

@media only screen and (min-device-width: 1161px) and (max-device-width: 1515px){
     #app #sortable.categories{
          column-count:3;
     }
}

/*remove flex of category boxes*/
.category{
     display:inline-block;
}

/*change color and spacing of header box*/
#app #sortable.categories .category > .title{
     padding:10px 0px 10px 15px;
     border-radius: 10px 10px 0px 0px;
     background-color:#0000004f;
}

/*make buttons smaller*/
.item{
    height:50px
}

/*make all buttons same background color/*
/*requires removing individual overrides*/
.item{
    background-color:#161b1f;
}

/*hide white bubble*/
.item::after{
    display:none
}

/*hide arrow*/
.fa-arrow-alt-to-right{
     display:none;
}

/*change icon size*/
.app-icon{
     max-width:36px;
     max-height:36px;
}

/*change left padding of icon*/
.app-icon-container{
     flex-basis:36px;
}

/*realised I never actually read these*/
.tooltip{
     display:none;
}

/*make css editing area wider*/
/*you'll want to make this responsive if you do this on a phone*/
.module-container{
     max-width:1090px;
}
div.create .input{
     width:1020px;
}
div.create .input textarea{
     width:1020px;
     height:600px;
}



/*category entrance effect*/
.category{
	-webkit-animation: slide-in-top 0.5s cubic-bezier(0.250, 0.460, 0.450, 0.940) both;
	        animation: slide-in-top 0.5s cubic-bezier(0.250, 0.460, 0.450, 0.940) both;

}

/*animasta keyframes for effect*/

@-webkit-keyframes slide-in-top {
  0% {
    -webkit-transform: translateY(-1000px);
            transform: translateY(-1000px);
    opacity: 0;
  }
  100% {
    -webkit-transform: translateY(0);
            transform: translateY(0);
    opacity: 1;
  }
}
@keyframes slide-in-top {
  0% {
    -webkit-transform: translateY(-1000px);
            transform: translateY(-1000px);
    opacity: 0;
  }
  100% {
    -webkit-transform: translateY(0);
            transform: translateY(0);
    opacity: 1;
  }
}
```


### 自訂-修改標題名稱

### 步驟 1：先準備好 logo 圖片，讓網頁能存取到

最簡單的方式是把圖片放進 Heimdall 的 `public/storage` 目錄。先確認這個目錄存在並且有對外連結：
```bash
ls -la /var/www/heimdall/public/storage
```

如果沒有這個資料夾或是空的，先建立 symlink（Laravel 標準做法）：
```bash
cd /var/www/heimdall
php artisan storage:link
```

接著把你的 logo 檔案（例如 `gss-logo.png`）放到：
```bash
/var/www/heimdall/storage/app/public/gss-logo.png
```

放好之後，瀏覽器應該可以透過這個網址看到圖片：
```
http://172.16.8.137/storage/gss-logo.png
```

先用瀏覽器開這個網址測試看看，圖片有出現再繼續下一步，避免 CSS 抓不到圖檔卻找不到原因。
### 步驟 2：在你的 Custom CSS 最後面加上這段

```css
/* top brand header bar */
body::before {
    content: "";
    display: block;
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 60px;
    background-color: #ffffff;
    background-image: url('/storage/gss-logo.png');
    background-repeat: no-repeat;
    background-position: 20px center;
    background-size: auto 30px;
    border-bottom: 1px solid #e0e0e0;
    z-index: 999;
}
```

優化過後
```
/* ============================================================
   Heimdall - GSS Dashboard
   Grid 排版 + 保留 Tiles 搜尋
   ============================================================ */


/* ============================================================
   全域
   ============================================================ */

html,
body {
    margin: 0;
    min-height: 100%;
}

body {
    overflow-x: hidden;
}


/* 主背景 */
#app .content {
    background-color: #026fbc;
    min-height: 100vh;

    padding-top: 60px;

    box-sizing: border-box;
}


/* ============================================================
   GSS Header
   ============================================================ */

body::before {
    content: "";

    display: block;

    position: fixed;

    top: 0;
    left: 0;

    width: 100%;
    height: 60px;

    background-color: #ffffff;

    background-image: url('/storage/gss-logo.png');

    background-repeat: no-repeat;

    background-position: 20px center;

    background-size: auto 30px;

    border-bottom: 1px solid #e0e0e0;

    z-index: 999;
}


/* ============================================================
   Search
   ============================================================ */

.searchform {

    margin-top: 15px !important;

    margin-bottom: 35px !important;
}


/* ============================================================
   Categories 總容器
   ============================================================ */

#app #sortable.categories {

    display: grid !important;

    /*
       根據螢幕寬度自動排列 Category
    */
    grid-template-columns:
        repeat(auto-fit, minmax(300px, 1fr));

    gap: 28px;

    width:
        calc(100% - 140px) !important;

    max-width: 1500px !important;

    margin-left: auto !important;

    margin-right: auto !important;

    column-count: unset !important;

    column-width: unset !important;

    align-items: start;
}


/* ============================================================
   Category 外框
   ============================================================ */

#app #sortable.categories .category {

    display: grid !important;

    /*
       Category 裡的書籤自動換行
    */
    grid-template-columns:
        repeat(auto-fit, minmax(240px, 1fr));

    /*
       書籤間距
    */
    gap: 8px 12px;

    width: 100% !important;

    margin: 0 !important;

    /*
       左右留白
    */
    padding:
        0
        14px
        14px
        14px;

    box-sizing: border-box;

    background-color:
        rgba(0, 55, 92, 0.40);

    border-radius: 10px;

    overflow: hidden;

    break-inside: auto !important;

    -webkit-animation:
        slide-in-top
        0.5s
        cubic-bezier(0.250, 0.460, 0.450, 0.940)
        both;

    animation:
        slide-in-top
        0.5s
        cubic-bezier(0.250, 0.460, 0.450, 0.940)
        both;
}


/* ============================================================
   Category 標題
   ============================================================ */

#app #sortable.categories
.category > .title {

    /*
       Header 橫跨整個 Category
    */
    grid-column: 1 / -1;

    /*
       Category 有左右 14px padding
       Header 往外補回去
    */
    margin-left: -14px;

    margin-right: -14px;

    margin-bottom: 7px;

    padding:
        10px
        14px;

    box-sizing: border-box;

    background-color:
        rgba(0, 35, 65, 0.55);

    border-radius:
        10px
        10px
        0
        0;
}


#app #sortable.categories
.category > .title a {

    color: #ffffff;

    text-decoration: none;
}


/* ============================================================
   App Container
   ============================================================ */

#app #sortable.categories
.category > .item-container {

    /*
       非常重要：
       不要設定 display:block !important

       Heimdall Tiles 搜尋會自己切換 display:none
    */

    width: 100%;

    min-width: 0;

    margin: 0;

    box-sizing: border-box;

    break-inside: avoid;
}


/* ============================================================
   App Button
   ============================================================ */

.item {

    width: 100%;

    height: 50px !important;

    min-height: 50px;

    margin: 0 !important;

    box-sizing: border-box;

    border-radius: 6px;

    border: none;

    background:
        linear-gradient(
            90deg,
            #161b1f 0%,
            #4a4a4a 100%
        ) !important;
}


/* Hover */
.item:hover {

    filter: brightness(1.10);

    transition:
        filter 0.15s ease;
}


/* 隱藏白色 bubble */
.item::after {

    display: none;
}


/* 隱藏右邊箭頭 */
.fa-arrow-alt-to-right {

    display: none;
}


/* ============================================================
   Icon
   ============================================================ */

.app-icon {

    max-width: 36px;

    max-height: 36px;
}


.app-icon-container {

    flex-basis: 36px;

    margin-left: 4px;
}


/* ============================================================
   Bookmark 文字
   ============================================================ */

.item .details {

    min-width: 0;
}


.item .details .title {

    overflow: hidden;

    text-overflow: ellipsis;

    white-space: nowrap;
}


/* ============================================================
   Tooltip
   ============================================================ */

.tooltip {

    display: none;
}


/* ============================================================
   Animation
   ============================================================ */

@-webkit-keyframes slide-in-top {

    0% {

        -webkit-transform:
            translateY(-1000px);

        transform:
            translateY(-1000px);

        opacity: 0;
    }

    100% {

        -webkit-transform:
            translateY(0);

        transform:
            translateY(0);

        opacity: 1;
    }
}


@keyframes slide-in-top {

    0% {

        -webkit-transform:
            translateY(-1000px);

        transform:
            translateY(-1000px);

        opacity: 0;
    }

    100% {

        -webkit-transform:
            translateY(0);

        transform:
            translateY(0);

        opacity: 1;
    }
}


/* ============================================================
   Large Desktop
   ============================================================ */

@media only screen
and (min-width: 1600px) {

    #app #sortable.categories {

        grid-template-columns:
            repeat(4, minmax(300px, 1fr));
    }
}


/* ============================================================
   Desktop
   ============================================================ */

@media only screen
and (min-width: 1200px)
and (max-width: 1599px) {

    #app #sortable.categories {

        grid-template-columns:
            repeat(3, minmax(280px, 1fr));
    }
}


/* ============================================================
   Tablet
   ============================================================ */

@media only screen
and (min-width: 768px)
and (max-width: 1199px) {

    #app #sortable.categories {

        width:
            calc(100% - 70px) !important;

        grid-template-columns:
            repeat(2, minmax(260px, 1fr));
    }
}


/* ============================================================
   Mobile
   ============================================================ */

@media only screen
and (max-width: 767px) {

    #app #sortable.categories {

        width:
            calc(100% - 30px) !important;

        grid-template-columns:
            1fr;

        gap: 20px;
    }


    #app #sortable.categories .category {

        grid-template-columns:
            1fr;

        padding-left: 10px;

        padding-right: 10px;

        padding-bottom: 10px;
    }


    #app #sortable.categories
    .category > .title {

        margin-left: -10px;

        margin-right: -10px;
    }


    #config-buttons a {

        width: 35px;

        height: 35px;
    }
}


/* ============================================================
   低高度畫面
   ============================================================ */

@media only screen
and (max-height: 900px) {

    .searchform {

        margin-top: 8px !important;

        margin-bottom: 20px !important;
    }


    #app #sortable.categories {

        gap: 20px;
    }


    #app #sortable.categories .category {

        gap: 6px 10px;

        padding-bottom: 10px;
    }


    #app #sortable.categories
    .category > .title {

        padding-top: 7px;

        padding-bottom: 7px;

        margin-bottom: 6px;
    }


    .item {

        height: 44px !important;

        min-height: 44px;
    }


    .app-icon {

        max-width: 31px;

        max-height: 31px;
    }
}


/* ============================================================
   很矮的畫面
   ============================================================ */

@media only screen
and (max-height: 760px) {

    .searchform {

        margin-bottom: 12px !important;
    }


    .item {

        height: 40px !important;

        min-height: 40px;
    }


    .app-icon {

        max-width: 28px;

        max-height: 28px;
    }


    #app #sortable.categories
    .category > .title {

        padding-top: 5px;

        padding-bottom: 5px;
    }
}


/* ============================================================
   Settings CSS Editor
   ============================================================ */

.module-container {

    max-width: 1090px;
}


div.create .input {

    width: 1020px;
}


div.create .input textarea {

    width: 1020px;

    height: 600px;
}
```

自訂義js
```
/* ============================================================
   Heimdall Categories - Custom Drag & Drop
   ------------------------------------------------------------
   功能：
   1. 保留 Heimdall Tiles 搜尋
   2. Category 內 App 可拖曳排序
   3. 可連續拖曳
   4. 排序後寫回 Heimdall /order
   5. 重新整理後保留順序
   ============================================================ */

$(document).ready(function () {

    /* ========================================================
       基本檢查
       ======================================================== */

    const rootElement =
        document.getElementById("sortable");

    if (!rootElement) {
        console.error(
            "[Heimdall Custom Sort] #sortable not found."
        );
        return;
    }

    if (typeof Sortable === "undefined") {
        console.error(
            "[Heimdall Custom Sort] SortableJS not found."
        );
        return;
    }


    /* ========================================================
       Heimdall URL
       ======================================================== */

    const baseElement =
        document.querySelector("base");

    let heimdallBase;

    if (
        baseElement &&
        baseElement.href
    ) {

        heimdallBase =
            baseElement.href;

    } else {

        heimdallBase =
            window.location.origin + "/";

    }


    /*
     * 確保結尾有 /
     */
    if (
        !heimdallBase.endsWith("/")
    ) {

        heimdallBase += "/";

    }


    const orderUrl =
        new URL(
            "order",
            heimdallBase
        ).href;


    console.log(
        "[Heimdall Custom Sort] Order URL:",
        orderUrl
    );


    /* ========================================================
       取得 Heimdall 原本 root Sortable
       ======================================================== */

    const rootSortable =
        Sortable.get(
            rootElement
        );


    /*
     * 我們會控制 Category 內的 App，
     * 所以 Heimdall 原本 root sortable
     * 在 Categories 模式下保持 disabled。
     */
    function disableRootSortable() {

        if (rootSortable) {

            try {

                rootSortable.option(
                    "disabled",
                    true
                );

            } catch (error) {

                console.warn(
                    "[Heimdall Custom Sort] Unable to disable root Sortable:",
                    error
                );

            }

        }

    }


    /* ========================================================
       儲存目前 App 排序
       ======================================================== */

    function saveAppOrder() {

        const ids = [];


        /*
         * 按照：
         *
         * Category 1
         *   App
         *   App
         *
         * Category 2
         *   App
         *   App
         *
         * 的實際 DOM 順序收集 ID。
         */
        $("#sortable.categories .category")
            .each(function () {

                $(this)
                    .children(
                        ".item-container"
                    )
                    .each(function () {

                        const id =
                            $(this)
                                .attr(
                                    "data-id"
                                );


                        if (
                            id !== undefined &&
                            id !== null &&
                            id !== ""
                        ) {

                            ids.push(
                                String(id)
                            );

                        }

                    });

            });


        if (
            ids.length === 0
        ) {

            console.warn(
                "[Heimdall Custom Sort] No App IDs found."
            );

            return;
        }


        console.log(
            "[Heimdall Custom Sort] Saving order:",
            ids
        );


        /*
         * 使用 jQuery AJAX。
         *
         * Heimdall 自己也是透過 jQuery
         * POST 排序資料。
         */
        $.ajax({

            url:
                orderUrl,

            type:
                "POST",

            data: {
                order: ids
            },

            success:
                function (
                    response,
                    textStatus,
                    xhr
                ) {

                    console.log(
                        "[Heimdall Custom Sort] ✓ Order saved.",
                        "HTTP:",
                        xhr.status
                    );

                },

            error:
                function (
                    xhr,
                    textStatus,
                    errorThrown
                ) {

                    console.error(
                        "[Heimdall Custom Sort] ✗ Order save failed."
                    );

                    console.error(
                        "HTTP status:",
                        xhr.status
                    );

                    console.error(
                        "Status:",
                        textStatus
                    );

                    console.error(
                        "Error:",
                        errorThrown
                    );

                    console.error(
                        "Response:",
                        xhr.responseText
                    );

                }

        });

    }


    /* ========================================================
       Category Sortable instances
       ======================================================== */

    let categorySortables = [];


    /* ========================================================
       是否處於 Heimdall 編輯模式
       ======================================================== */

    function isEditMode() {

        return $("#app")
            .hasClass(
                "header"
            );

    }


    /* ========================================================
       強制重新確認 Sortable 狀態
       ======================================================== */

    function refreshSortableState() {

        const enabled =
            isEditMode();


        /*
         * 父層永遠不要跟 Category
         * 同時處理 App 拖曳。
         */
        disableRootSortable();


        categorySortables
            .forEach(function (
                sortable
            ) {

                try {

                    sortable.option(
                        "disabled",
                        !enabled
                    );

                } catch (error) {

                    console.warn(
                        "[Heimdall Custom Sort] Sortable state error:",
                        error
                    );

                }

            });


        console.log(
            "[Heimdall Custom Sort]",
            enabled
                ? "EDIT MODE - enabled"
                : "NORMAL MODE - disabled"
        );

    }


    /* ========================================================
       初始化 Category Sortables
       ======================================================== */

    function initializeCategorySortables() {

        /*
         * 先清理舊 instance，
         * 避免重複綁定。
         */
        categorySortables
            .forEach(function (
                sortable
            ) {

                try {

                    sortable.destroy();

                } catch (error) {

                    /* ignore */

                }

            });


        categorySortables = [];


        const categories =
            document.querySelectorAll(
                "#sortable.categories .category"
            );


        categories.forEach(
            function (
                category
            ) {

                /*
                 * 如果這個 category 已經被其他程式
                 * 建立過 Sortable，先移除。
                 */
                const existing =
                    Sortable.get(
                        category
                    );


                if (existing) {

                    try {

                        existing.destroy();

                    } catch (error) {

                        /* ignore */

                    }

                }


                const sortable =
                    Sortable.create(
                        category,
                        {

                            /*
                             * 預設關閉。
                             *
                             * 進入 Heimdall 編輯模式才打開。
                             */
                            disabled:
                                true,


                            /*
                             * 只能拖 App。
                             *
                             * 不包含 Category title。
                             */
                            draggable:
                                ".item-container",


                            /*
                             * 不設定 group。
                             *
                             * 所以 App 只能在自己的
                             * Category 裡重新排序。
                             */
                            group:
                                false,


                            /*
                             * 動畫
                             */
                            animation:
                                150,


                            /*
                             * Grid 排版不要強制 vertical。
                             *
                             * SortableJS 自己判斷。
                             */


                            /*
                             * 使用 fallback，
                             * 對 Heimdall link 元素較穩定。
                             */
                            forceFallback:
                                true,


                            fallbackOnBody:
                                true,


                            fallbackTolerance:
                                3,


                            /*
                             * 不讓 dragover 往父層冒泡，
                             * 避免 #sortable 原生 Sortable
                             * 搶到事件。
                             */
                            dragoverBubble:
                                false,


                            /*
                             * 避免文字被選取後無法拖動。
                             */
                            preventOnFilter:
                                false,


                            /*
                             * CSS classes
                             */
                            ghostClass:
                                "heimdall-sortable-ghost",

                            chosenClass:
                                "heimdall-sortable-chosen",

                            dragClass:
                                "heimdall-sortable-drag",


                            /* ==================================
                               Drag Start
                               ================================== */

                            onStart:
                                function () {

                                    /*
                                     * 再關一次父層。
                                     *
                                     * 因為 Heimdall 本身可能
                                     * 剛剛又把它打開。
                                     */
                                    disableRootSortable();


                                    console.log(
                                        "[Heimdall Custom Sort] Drag started."
                                    );

                                },


                            /* ==================================
                               Drag End
                               ================================== */

                            onEnd:
                                function (
                                    evt
                                ) {

                                    console.log(
                                        "[Heimdall Custom Sort] Drag ended:",
                                        evt.oldIndex,
                                        "→",
                                        evt.newIndex
                                    );


                                    /*
                                     * 只有實際位置有變
                                     * 才送出儲存。
                                     */
                                    if (
                                        evt.oldIndex !==
                                        evt.newIndex
                                    ) {

                                        saveAppOrder();

                                    }


                                    /*
                                     * 非常重要：
                                     *
                                     * 拖完後重新確認我們自己的
                                     * Sortable 還是 Enabled。
                                     *
                                     * 避免第一次拖完後被 Heimdall
                                     * 或 Sortable global state 關掉。
                                     */
                                    setTimeout(
                                        function () {

                                            disableRootSortable();


                                            categorySortables
                                                .forEach(
                                                    function (
                                                        instance
                                                    ) {

                                                        try {

                                                            instance.option(
                                                                "disabled",
                                                                false
                                                            );

                                                        } catch (
                                                            error
                                                        ) {

                                                            console.warn(
                                                                "[Heimdall Custom Sort] Re-enable error:",
                                                                error
                                                            );

                                                        }

                                                    }
                                                );


                                            console.log(
                                                "[Heimdall Custom Sort] Ready for next drag."
                                            );

                                        },
                                        50
                                    );

                                }

                        }
                    );


                categorySortables.push(
                    sortable
                );

            }
        );


        console.log(
            "[Heimdall Custom Sort]",
            categorySortables.length,
            "categories initialized."
        );


        refreshSortableState();

    }


    /* ========================================================
       第一次初始化
       ======================================================== */

    /*
     * 稍微等 Heimdall 自己的 app.js
     * 初始化完成。
     */
    setTimeout(
        function () {

            initializeCategorySortables();

            disableRootSortable();

        },
        300
    );


    /* ========================================================
       Heimdall 編輯按鈕
       ======================================================== */

    /*
     * Heimdall 點 ↔ 後，
     * 自己會先切換 #app.header
     * 並控制原生 sortable。
     *
     * 所以我們稍微晚一點再接管。
     */
    $("#app").on(
        "click.heimdallCustomSort",
        "#config-button",
        function () {

            setTimeout(
                function () {

                    refreshSortableState();

                },
                150
            );


            /*
             * 第二次保險。
             *
             * 防止 Heimdall 後續程式
             * 又把 root sortable 打開。
             */
            setTimeout(
                function () {

                    disableRootSortable();

                    refreshSortableState();

                },
                350
            );

        }
    );


    /* ========================================================
       防止原生 root Sortable 被重新打開
       ======================================================== */

    /*
     * 編輯模式期間每 1 秒檢查一次。
     *
     * 這不是重新建立 Sortable，
     * 只是在 root 被 Heimdall 打開時
     * 再把它關掉。
     */
    setInterval(
        function () {

            if (
                isEditMode()
            ) {

                disableRootSortable();

            }

        },
        1000
    );


    /* ========================================================
       Debug helper
       ======================================================== */

    /*
     * F12 Console 可以輸入：
     *
     * heimdallSortDebug()
     *
     * 查看目前狀態。
     */
    window.heimdallSortDebug =
        function () {

            console.log(
                "=============================="
            );

            console.log(
                "Heimdall Custom Sort Debug"
            );

            console.log(
                "Edit mode:",
                isEditMode()
            );

            console.log(
                "Category Sortables:",
                categorySortables.length
            );

            console.log(
                "Order URL:",
                orderUrl
            );

            console.log(
                "Root Sortable:",
                rootSortable
            );


            categorySortables
                .forEach(
                    function (
                        sortable,
                        index
                    ) {

                        console.log(
                            "Category",
                            index + 1,
                            "disabled:",
                            sortable.option(
                                "disabled"
                            )
                        );

                    }
                );


            console.log(
                "=============================="
            );

        };

});
```







## Homepage
http://IP:3000
```bookmarks.yaml
- Developer:
    - Github:
        - icon: gitlab.svg
          href: https://github.com/

- Social:
    - Reddit:
        - abbr: RE
          href: https://reddit.com/

- Entertainment:
    - YouTube:
        - abbr: YT
          href: https://youtube.com/
```

## Navhub

專案預覽：[https://git-hub-cc.github.io/Deploy/navhub](https://git-hub-cc.github.io/Deploy/navhub) 備用預覽：[https://navhub-cc.netlify.app](https://navhub-cc.netlify.app/) 專案地址：[https://github.com/git-hub-cc/NavHub](https://github.com/git-hub-cc/NavHub)


## [Bujic Panel](https://github.com/chao-eng/bujic-panel)

## Navidash