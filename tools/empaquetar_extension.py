"""Refresh an API 2 JSON envelope after editing its matching .dart source."""
import json
import sys
from pathlib import Path
package = Path(sys.argv[1]).resolve()
data = json.loads(package.read_text(encoding="utf-8"))
data["source"] = package.with_name(package.stem.replace("-", "_") + ".dart").read_text(encoding="utf-8")
package.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(package)
