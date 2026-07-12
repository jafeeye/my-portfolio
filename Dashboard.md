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