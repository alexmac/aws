const black = [0, 0, 0];
const white = [255, 255, 255];
// const black = [228, 228, 231];
// const white = [244, 244, 245];
const blackFill = `rgb(${black[0]},${black[1]},${black[2]})`
const whiteFill = `rgb(${white[0]},${white[1]},${white[2]})`
const blueFill = 'rgb(0,0,255)'
const redFill = 'rgb(255,0,0)'
// const blueFill = 'rgb(211,224,251)'
// const redFill = 'rgb(249,210,218)'

const w = 1024;
const h = 1024;

var mainCanvas = null;
var mainCanvasCtx = null;
var mainCanvasW;
var mainCanvasH;

var offscreenCanvas;
var offscreenCtx;
var offscreenCanvasWithBalls;
var offscreenCtxWithBalls;

const balls = [];
const numBalls = 256; //(w * h) / 32;

function initBuffer() {
    const pixelArray = new Uint8ClampedArray(w * h * 4);

    for (let i = 0; i < pixelArray.length; i += 4) {
        const c = Math.floor(Math.random() * 10) ? white : black;
        pixelArray[i] = c[0];
        pixelArray[i + 1] = c[1];
        pixelArray[i + 2] = c[2];
        pixelArray[i + 3] = 255;
    }

    const imageData = new ImageData(pixelArray, w, h);
    offscreenCtx.putImageData(imageData, 0, 0);
}

function initBalls() {
    for (let i = 0; i < numBalls; i++) {
        const ball = {
            x: Math.random() * w,
            y: Math.random() * h,
            dx: Math.random() * 2,
            dy: Math.random() * 2,
            isOdd: i % 2 === 0,
        };
        balls.push(ball);
    }
}

function initCanvas() {
    offscreenCanvas = new OffscreenCanvas(w, h);
    offscreenCtx = offscreenCanvas.getContext("2d", { alpha: false, willReadFrequently: true });
    offscreenCtx.fillstyle = blackFill;
    offscreenCtx.fillRect(0, 0, w, h);
    offscreenCtx.imageSmoothingEnabled = false;

    offscreenCanvasWithBalls = new OffscreenCanvas(w, h);
    offscreenCtxWithBalls = offscreenCanvasWithBalls.getContext("2d", { alpha: false, willReadFrequently: false });
    offscreenCtxWithBalls.fillstyle = blackFill;
    offscreenCtxWithBalls.fillRect(0, 0, w, h);
    offscreenCtxWithBalls.imageSmoothingEnabled = false;
}

function drawBall(ball) {
    const pixelX = Math.floor(ball.x);
    const pixelY = Math.floor(ball.y);

    offscreenCtxWithBalls.fillStyle = ball.isOdd ? redFill : blueFill;
    offscreenCtxWithBalls.fillRect(pixelX, pixelY, 1, 1);
}

function updateBallPosition(ball) {
    ball.x += ball.dx;
    ball.y += ball.dy;

    if (ball.x > w) {
        ball.x -= w;
    } else if (ball.x < 0) {
        ball.x += w;
    }

    if (ball.y > h) {
        ball.y -= h;
    } else if (ball.y < 0) {
        ball.y += h;
    }

    const pixelX = Math.floor(ball.x);
    const pixelY = Math.floor(ball.y);

    // Check for collisions with pixels
    // this logic is all garbage, but close enough to play around with the basic idea
    const x = Math.floor(ball.x)
    const y = Math.floor(ball.y)
    const pixel = offscreenCtx.getImageData(x, y, 1, 1).data;

    if (
        ball.x >= x &&
        ball.x <= x + 1 &&
        ball.y >= y &&
        ball.y <= y + 1
    ) {
        const pixelIsBlack = (pixel[0] === black[0] && pixel[1] === black[1] && pixel[2] === black[2])
        if ((ball.isOdd && pixelIsBlack) || (!ball.isOdd && !pixelIsBlack)) {
            const dx = ball.x - (x + 1 / 2);
            const dy = ball.y - (y + 1 / 2);

            if (Math.abs(dx) > Math.abs(dy)) {
                ball.dx = -ball.dx;
            } else {
                ball.dy = -ball.dy;
            }
            offscreenCtx.fillStyle = ball.isOdd ? whiteFill : blackFill;
            offscreenCtx.fillRect(x, y, 1, 1);
        }
    }
}

function animate() {
    for (let n = 0; n < 4; n++) {
        for (let i = 0; i < balls.length; i++) {
            const ball = balls[i];
            updateBallPosition(ball);
        }
    }

    var pattern = offscreenCtxWithBalls.createPattern(offscreenCanvas, "repeat");
    offscreenCtxWithBalls.fillStyle = pattern;
    offscreenCtxWithBalls.fillRect(0, 0, w, h);

    for (let i = 0; i < balls.length; i++) {
        const ball = balls[i];
        drawBall(ball);
    }
}

function timeout(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function renderFrame() {
    animate();
    mainCanvasCtx.fillStyle = mainCanvasCtx.createPattern(offscreenCanvasWithBalls, "repeat");
    mainCanvasCtx.fillRect(0, 0, mainCanvasW, mainCanvasH);
    requestAnimationFrame(renderFrame);
}

self.addEventListener('message', async (event) => {
    if (event.data.type === 'start') {
        initCanvas();
        initBuffer();
        initBalls();

        mainCanvas = event.data.canvas;
        mainCanvasW = mainCanvas.width;
        mainCanvasH = mainCanvas.height;
        mainCanvasCtx = mainCanvas.getContext("2d", { alpha: false });
        requestAnimationFrame(renderFrame);
    }
});
