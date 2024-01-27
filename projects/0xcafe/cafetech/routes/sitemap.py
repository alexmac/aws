from __future__ import annotations

from typing import TYPE_CHECKING, List

from aiohttp.web import Response
from lxml import etree
from yarl import URL

from cafetech.templates import valid_project_names

if TYPE_CHECKING:
    from blog_server import BlogServer


def _generate_sitemap(urls: List[URL]) -> str:
    urlset = etree.Element(
        "urlset", attrib={}, nsmap={None: "http://www.sitemaps.org/schemas/sitemap/0.9"}
    )

    for url in urls:
        url_element = etree.SubElement(urlset, "url", attrib={}, nsmap={})
        loc = etree.SubElement(url_element, "loc", attrib={}, nsmap={})
        loc.text = str(url)

        loc = etree.SubElement(url_element, "changefreq", attrib={}, nsmap={})
        loc.text = str("weekly")

    return etree.tostring(
        urlset, pretty_print=True, xml_declaration=True, encoding="UTF-8"
    ).decode("utf-8")


async def get_sitemap(s: BlogServer, request):
    root = URL("https://0xcafe.tech")

    urls = [root, root / "cooltrans"]

    urls += [root / "projects" / project for project in valid_project_names]

    return Response(
        body=_generate_sitemap(urls), headers={"content-type": "application/xml"}
    )
