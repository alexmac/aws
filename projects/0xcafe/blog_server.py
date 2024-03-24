from __future__ import annotations

import asyncio
import logging
import os
from functools import partial
from typing import List, Optional

import aiohttp_jinja2
import jinja2
from aiohttp.typedefs import Handler, Middleware
from aiohttp.web import Request, middleware
from alxhttp.file import get_file
from alxhttp.headers import content_security_policy, permissions_policy
from alxhttp.middleware import default_middleware
from alxhttp.server import Server
from alxhttp.xray import init_xray

from cafetech.routes.cooltrans import get_cooltrans
from cafetech.routes.project import get_project, get_project_bg
from cafetech.routes.sitemap import get_sitemap
from cafetech.routes.slash import get_slash


@middleware
async def security_headers(request: Request, handler: Handler):
    resp = await handler(request)

    resp.headers["content-security-policy"] = content_security_policy(
        default_src=["self"],
        style_src=["self", "unsafe-inline"],
        font_src=["self", "data:"],
        media_src=["self", "blob:"],
        object_src=["none"],
        img_src=[
            "self",
            "data:",
            "https://tile.openstreetmap.org",
        ],
        worker_src=["self", "blob:"],
    )

    resp.headers["permissions-policy"] = permissions_policy(
        autoplay=["self"],
        fullscreen=["self"],
    )

    resp.headers["cache-control"] = "public, max-age=10, stale-while-revalidate=600"
    return resp


class BlogServer(Server):
    def __init__(self, middlewares: Optional[List[Middleware]] = None):
        super().__init__(middlewares=middlewares)

        self.app.router.add_get(r"/", partial(get_slash, self))
        self.app.router.add_get(r"/cooltrans", partial(get_cooltrans, self))
        self.app.router.add_get(
            r"/cooltrans/{source}/{loc:[0-9a-zA-Z_-]+}", partial(get_cooltrans, self)
        )

        self.app.router.add_get(r"/sitemap.xml", partial(get_sitemap, self))

        self.app.router.add_get(r"/projects/{project_name}", partial(get_project, self))
        self.app.router.add_get(
            r"/projects/{project_name}/bg.png", partial(get_project_bg, self)
        )

        for f in [
            "breakout-worker.js",
            "breakout.css",
            "breakout.js",
            "gh.svg",
            "leaflet/layers-2x.png",
            "leaflet/layers.png",
            "leaflet/leaflet.css",
            "leaflet/leaflet.js",
            "leaflet/marker-icon-2x.png",
            "leaflet/marker-icon.png",
            "leaflet/marker-shadow.png",
            "map.js",
            "robots.txt",
            "tailwind.css",
            "video-js.css",
            "video.min.js",
        ]:
            self.app.router.add_get(f"/{f}", get_file(f"static/{f}"))

        for f in os.listdir("static/favicon"):
            self.app.router.add_get(f"/{f}", get_file(f"static/favicon/{f}"))


async def main():  # pragma: nocover
    asyncio.get_running_loop().set_debug(True)
    logging.basicConfig(level=logging.INFO)
    log = logging.getLogger()

    xray_enabled = await init_xray(log=log, service_name="0xcafe")

    middlewares = default_middleware(include_xray=xray_enabled)
    middlewares.append(security_headers)
    s = BlogServer(middlewares=middlewares)
    aiohttp_jinja2.setup(s.app, loader=jinja2.FileSystemLoader("./templates"))
    await s.run_app(log, host="0.0.0.0", port=8080)


if __name__ == "__main__":  # pragma: nocover
    asyncio.run(main())
