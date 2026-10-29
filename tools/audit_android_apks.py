"""Compare APK composition; this is not a malware scanner or a Play verdict."""
import argparse
import hashlib
import json
from pathlib import Path
import zipfile


def inventory(path):
    with zipfile.ZipFile(path) as apk:
        names = apk.namelist()
        if len(names) != len(set(names)):
            raise ValueError('Duplicate ZIP entries')
        if apk.testzip() is not None:
            raise ValueError('Corrupt ZIP entry')
        if 'AndroidManifest.xml' not in names or 'classes.dex' not in names:
            raise ValueError('Not an ordinary Android APK')
        files = {n: hashlib.sha256(apk.read(n)).hexdigest() for n in names}
    return files


def compare(before, after):
    old, new = inventory(before), inventory(after)
    changed = sorted(n for n in old.keys() & new.keys() if old[n] != new[n])
    return {
        'beforeSha256': hashlib.sha256(Path(before).read_bytes()).hexdigest(),
        'afterSha256': hashlib.sha256(Path(after).read_bytes()).hexdigest(),
        'changedDex': [n for n in changed if n.endswith('.dex')],
        'changedThirdPartyNative': [n for n in changed if n.startswith('lib/') and not n.endswith('/libapp.so')],
        'changedFlutterAot': [n for n in changed if n.endswith('/libapp.so')],
        'added': sorted(new.keys() - old.keys()),
        'removed': sorted(old.keys() - new.keys()),
        'changedFiles': changed,
        'scope': 'Archive integrity and composition only; no malware clearance or Google classification.',
    }


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('before', type=Path)
    parser.add_argument('after', type=Path)
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    report = compare(args.before, args.after)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    print(json.dumps({k: v for k, v in report.items() if k != 'changedFiles'}))
