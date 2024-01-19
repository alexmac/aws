from __future__ import annotations

from typing import TYPE_CHECKING

import aiohttp_jinja2
from aiohttp.web import Request

from cafetech.templates import valid_project_names, validate_project_name

if TYPE_CHECKING:
    from blog_server import BlogServer


@aiohttp_jinja2.template("layout.html")
async def get_project(s: BlogServer, req: Request):
    _, project_path = validate_project_name(req.match_info["project_name"])

    return {
        "article_path": project_path,
        "projects": sorted(valid_project_names),
    }
