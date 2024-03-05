var map = L.map('leafletmap').setView([39.18724, -120.19489], 9);

const player = videojs('vid', {
    fluid: true
});

L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19,
    attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
}).addTo(map);

fetch('/api/cooltrans/cctv/locations')
    .then(response => response.json())
    .then(json => {
        for (let key in json.locations) {
            const location = json.locations[key];
            const longitude = parseFloat(location.longitude);
            const latitude = parseFloat(location.latitude);
            const simple_name = location.simple_name;
            const friendly_name = location.friendly_name;

            var m = L.marker([latitude, longitude], {
                "title": friendly_name
            })

            m.on('click', function () {
                const videoElement = document.getElementById('vid');
                if (videoElement) {
                    player.loadMedia({
                        src: {
                            src: "/api/cooltrans/proxy/" + location.source + location.stream + "/playlist.m3u8",
                            type: "application/x-mpegURL",
                        }
                    })

                    var url = new URL(window.location.href);
                    url.pathname = `/cooltrans/${location.source}/${simple_name}`
                    history.pushState(null, document.title, url.toString());
                }
            })

            m.addTo(map);
        }
    });


