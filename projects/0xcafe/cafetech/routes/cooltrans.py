from __future__ import annotations

from typing import TYPE_CHECKING

import aiohttp
import aiohttp_jinja2
from aiohttp.web import HTTPBadRequest, Request

if TYPE_CHECKING:
    from blog_server import BlogServer


@aiohttp_jinja2.template("cooltrans.html")
async def get_cooltrans(s: BlogServer, req: Request):
    friendly_name = "3 / Tahoe City / Hwy 89 at Alpine Meadows"
    simple_name = "3---Tahoe-City---Hwy-89-at-Alpine-Meadows"
    stream = "/D3/89_Alpine_Meadows_PLA89_NB.stream"
    source = req.match_info.get("source", "caltrans")
    if loc := req.match_info.get("loc"):
        async with aiohttp.ClientSession().get(
            "https://0xcafe.tech/api/cooltrans/cctv/locations"
        ) as r:
            d = (await r.json())["locations"]

        loc_info = d.get(loc)
        friendly_name = loc_info["friendly_name"]
        simple_name = loc_info["simple_name"]
        stream = loc_info["stream"]

    if source not in {"caltrans", "ndot"}:
        raise HTTPBadRequest()

    title = f"{source.title()} CCTV: {friendly_name}"

    return {
        "title": title,
        "opengraph": {"title": title},
        "friendly_name": friendly_name,
        "simple_name": simple_name,
        "stream": source + stream,
        "meta_tags": {"description": title},
    }
