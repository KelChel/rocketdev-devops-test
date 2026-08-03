#!/usr/bin/env python3
"""Validate generated Grafana dashboard JSON using only the Python standard library."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any


class DashboardValidationError(ValueError):
    pass


def require(condition: bool, message: str) -> None:
    if not condition:
        raise DashboardValidationError(message)


def validate_grid(panel: dict[str, Any], context: str) -> tuple[int, int, int, int]:
    grid = panel.get("gridPos")
    require(isinstance(grid, dict), f"{context}: gridPos must be an object")

    values = tuple(grid.get(key) for key in ("x", "y", "w", "h"))
    require(
        all(isinstance(value, int) and not isinstance(value, bool) for value in values),
        f"{context}: gridPos x/y/w/h must be integers",
    )
    x, y, width, height = values
    require(x >= 0 and y >= 0, f"{context}: gridPos x/y must be non-negative")
    require(width > 0 and height > 0, f"{context}: gridPos w/h must be positive")
    require(x + width <= 24, f"{context}: panel exceeds Grafana's 24-column grid")
    return x, y, width, height


def rectangles_overlap(
    first: tuple[int, int, int, int], second: tuple[int, int, int, int]
) -> bool:
    x1, y1, w1, h1 = first
    x2, y2, w2, h2 = second
    return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1


def validate_dashboard(path: Path) -> None:
    try:
        dashboard = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise DashboardValidationError(f"{path}: invalid JSON: {error}") from error

    require(isinstance(dashboard, dict), f"{path}: dashboard root must be an object")
    for field in ("title", "uid"):
        require(
            isinstance(dashboard.get(field), str) and bool(dashboard[field].strip()),
            f"{path}: {field} must be a non-empty string",
        )
    require(
        isinstance(dashboard.get("schemaVersion"), int),
        f"{path}: schemaVersion must be an integer",
    )

    panels = dashboard.get("panels")
    require(isinstance(panels, list) and panels, f"{path}: panels must be a non-empty list")

    panel_ids: set[int] = set()
    occupied: list[tuple[str, tuple[int, int, int, int]]] = []
    for index, panel in enumerate(panels):
        context = f"{path}: panels[{index}]"
        require(isinstance(panel, dict), f"{context} must be an object")
        panel_id = panel.get("id")
        require(
            isinstance(panel_id, int) and not isinstance(panel_id, bool),
            f"{context}: id must be an integer",
        )
        require(panel_id not in panel_ids, f"{context}: duplicate panel id {panel_id}")
        panel_ids.add(panel_id)

        for field in ("title", "type"):
            require(
                isinstance(panel.get(field), str) and bool(panel[field].strip()),
                f"{context}: {field} must be a non-empty string",
            )

        grid = validate_grid(panel, context)
        for other_context, other_grid in occupied:
            require(
                not rectangles_overlap(grid, other_grid),
                f"{context}: grid overlaps {other_context}",
            )
        occupied.append((context, grid))

        targets = panel.get("targets")
        require(isinstance(targets, list) and targets, f"{context}: targets must be non-empty")
        ref_ids: set[str] = set()
        for target_index, target in enumerate(targets):
            target_context = f"{context}.targets[{target_index}]"
            require(isinstance(target, dict), f"{target_context} must be an object")
            ref_id = target.get("refId")
            require(
                isinstance(ref_id, str) and bool(ref_id),
                f"{target_context}: refId must be a non-empty string",
            )
            require(ref_id not in ref_ids, f"{target_context}: duplicate refId {ref_id}")
            ref_ids.add(ref_id)
            require(
                isinstance(target.get("expr"), str) and bool(target["expr"].strip()),
                f"{target_context}: Prometheus expr must be non-empty",
            )

    templating = dashboard.get("templating")
    require(isinstance(templating, dict), f"{path}: templating must be an object")
    require(isinstance(templating.get("list"), list), f"{path}: templating.list must be a list")


def dashboard_paths(input_path: Path) -> list[Path]:
    if input_path.is_file():
        return [input_path]
    if input_path.is_dir():
        return sorted(input_path.glob("*.json"))
    return []


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("path", type=Path, help="Dashboard JSON file or directory")
    args = parser.parse_args()

    paths = dashboard_paths(args.path)
    if not paths:
        print(f"error: no dashboard JSON files found at {args.path}", file=sys.stderr)
        return 1

    failures = 0
    for path in paths:
        try:
            validate_dashboard(path)
        except DashboardValidationError as error:
            failures += 1
            print(f"FAIL {error}", file=sys.stderr)
        else:
            print(f"OK   {path}")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
