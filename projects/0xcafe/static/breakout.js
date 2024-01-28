
const blobUrls = [];
const worker = new Worker('/breakout-worker.js');

const htmlCanvas = document.getElementById("canvas");
htmlCanvas.width = 1024;
htmlCanvas.height = 1024;
const offscreen = htmlCanvas.transferControlToOffscreen();
worker.postMessage({ type: 'start', canvas: offscreen }, [offscreen]);
