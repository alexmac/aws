import json
import os
from typing import Any, Dict, Set
from dataclasses import dataclass

from aiohttp.web import HTTPBadRequest

projects_root = "templates/projects"

@dataclass
class Project:
    name: str
    article_path: str
    metadata: Dict[str, Any]

def _valid_project_names() -> Set[str]:
    html_files = set()
    for file in os.listdir(projects_root):
        if file.endswith(".html"):
            html_files.add(file[:-5])
    return html_files


valid_project_names: Set[str] = _valid_project_names()


def validate_project_name(project_name: str) -> Project:
    if project_name not in valid_project_names:
        raise HTTPBadRequest()

    try:
        metadata = json.load(open(f"templates/projects/{project_name}.json"))
    except Exception:
        metadata = dict()

    return Project(name=project_name, article_path=f"projects/{project_name}", metadata=metadata)
