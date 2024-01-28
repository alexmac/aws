from __future__ import annotations

from typing import TYPE_CHECKING

import aiohttp_jinja2

from cafetech.templates import valid_project_names

if TYPE_CHECKING:
    from blog_server import BlogServer


@aiohttp_jinja2.template("layout.html")
async def get_slash(s: BlogServer, request):
    return {
        "article_path": "slash",
        "projects": sorted(valid_project_names),
        "opengraph": dict(),
        "meta_tags": {"description": "An old fashioned website."},
        "stylesheets": ["/breakout.css"],
        "scripts": ["/breakout.js"],
    }
