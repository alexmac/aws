from __future__ import annotations

from typing import TYPE_CHECKING

import aiohttp_jinja2

if TYPE_CHECKING:
    from blog_server import BlogServer


@aiohttp_jinja2.template("cooltrans.html")
async def get_cooltrans(s: BlogServer, request):
    return {
        "opengraph": dict(),
        "meta_tags": {"description": "An old fashioned website."},
    }
