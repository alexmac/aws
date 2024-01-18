from __future__ import annotations

import asyncio
import logging
from functools import partial
import os
from typing import List, Optional

from aiohttp.web import FileResponse
from aiohttp.typedefs import Middleware
import aiohttp_jinja2

from alxhttp.server import Server
import jinja2
from cafetech.routes.project import get_project
from cafetech.routes.sitemap import get_sitemap
from cafetech.routes.slash import get_slash


def get_file(fn: str):
    async def handler(_):
        return FileResponse(fn)
    return handler

class BlogServer(Server):
    def __init__(self, middlewares: Optional[List[Middleware]] = None):
        super().__init__(middlewares=middlewares)

        self.app.router.add_get(r"/", partial(get_slash, self))

        self.app.router.add_get(r"/sitemap.xml", partial(get_sitemap, self))

        self.app.router.add_get(r"/projects/{project_name}", partial(get_project, self))

        for f in ['robots.txt', 'tailwind.css']:
            self.app.router.add_get(f"/{f}", get_file(f))

        for f in os.listdir('favicon'):
            self.app.router.add_get(f"/{f}", get_file(f"favicon/{f}"))



async def main():  # pragma: nocover
    asyncio.get_running_loop().set_debug(True)
    logging.basicConfig(level=logging.INFO)
    log = logging.getLogger()
    s = BlogServer()
    aiohttp_jinja2.setup(s.app, loader=jinja2.FileSystemLoader('./templates'))
    await s.run_app(log, host='0.0.0.0', port=8080)


if __name__ == "__main__":  # pragma: nocover
    asyncio.run(main())
