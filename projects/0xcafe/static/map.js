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

            var m = L.marker([latitude, longitude], {
                "title": key
            })

            m.on('click', function () {
                const videoElement = document.getElementById('vid');
                if (videoElement) {
                    player.loadMedia({
                        src: {
                            src: "/api/cooltrans/proxy" + location.stream + "/playlist.m3u8",
                            type: "application/x-mpegURL",
                        }
                    })
                }
            })

            m.addTo(map);
        }
    });


