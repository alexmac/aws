from __future__ import annotations

from typing import TYPE_CHECKING

import aiohttp_jinja2
from aiohttp.web import Request, Response

from cafetech.img import generate_8bit_pattern
from cafetech.templates import valid_project_names, validate_project_name

if TYPE_CHECKING:
    from blog_server import BlogServer


@aiohttp_jinja2.template("layout.html")
async def get_project(s: BlogServer, req: Request):
    proj = validate_project_name(req.match_info["project_name"])

    md = proj.metadata.get("opengraph", {})

    md["og:image"] = f"/{proj.article_path}/bg.png"

    return {
        "article_path": proj.article_path,
        "projects": sorted(valid_project_names),
        "opengraph": md,
        "meta_tags": proj.metadata.get("meta_tags", {}),
    }


async def get_project_bg(s: BlogServer, req: Request):
    proj = validate_project_name(req.match_info["project_name"])

    return Response(body=generate_8bit_pattern(proj.name), content_type="image/png")
