import os
from typing import Set, Tuple
from aiohttp.web import HTTPBadRequest

projects_root = 'templates/projects'

def _valid_project_names() -> Set[str]:
    html_files = set()
    for file in os.listdir(projects_root):
        if file.endswith(".html"):
            html_files.add(file[:-5])
    return html_files

valid_project_names: Set[str]  = _valid_project_names()

def validate_project_name(project_name: str) -> Tuple[str, str]:
    if project_name not in valid_project_names:
        raise HTTPBadRequest()
    return (project_name, f'projects/{project_name}')
