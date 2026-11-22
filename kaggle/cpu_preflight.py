"""Private, CPU-only Kaggle runtime probe. No model calls or credentials."""
from __future__ import annotations

import hashlib
import io
import json
import os
from pathlib import Path
import platform
import re
import shutil
import subprocess
import tarfile
import tempfile
import time
import urllib.error
import urllib.request


OUTPUT = Path('/kaggle/working/makefun-cpu-preflight')
if not OUTPUT.parent.is_dir():
    raise RuntimeError('Run this probe on a real Kaggle Notebook, not a local host')
OUTPUT.mkdir(exist_ok=True)
report = {
    'format': 'makefun-kaggle-preflight/1',
    'started_at_utc': time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime()),
    'platform': platform.system(),
    'architecture': platform.machine(),
    'python': platform.python_version(),
    'cpu_count': os.cpu_count(),
    'gpu_requested': False,
    'model_called': False,
    'native_codex_export_verified': False,
    'cpu_execution_passed': False,
}


def get_bytes(url: str, limit: int = 4_000_000) -> bytes:
    request = urllib.request.Request(url, headers={'User-Agent': 'makefun-kaggle-cpu-preflight/1'})
    with urllib.request.urlopen(request, timeout=30) as response:
        data = response.read(limit + 1)
    if len(data) > limit:
        raise ValueError('Download exceeds the probe limit')
    return data


def version(binary: str) -> str:
    result = subprocess.run([binary, '--version'], check=True, capture_output=True, text=True, timeout=10)
    return result.stdout.strip()


def node_at_least_22_18(value: str) -> bool:
    match = re.fullmatch(r'v(\d+)\.(\d+)\.(\d+)', value)
    return bool(match and tuple(map(int, match.groups())) >= (22, 18, 0))


def ensure_node() -> str:
    existing = shutil.which('node')
    if existing and node_at_least_22_18(version(existing)):
        report['node_source'] = 'preinstalled'
        return existing
    if platform.machine() not in {'x86_64', 'amd64'}:
        raise RuntimeError('This probe only installs the official Linux x64 Node binary')
    releases = json.loads(get_bytes('https://nodejs.org/dist/index.json'))
    release = next(r for r in releases if r['version'].startswith('v22.'))
    tag = release['version']
    name = f'node-{tag}-linux-x64.tar.xz'
    base = f'https://nodejs.org/dist/{tag}/'
    checksums = get_bytes(base + 'SHASUMS256.txt').decode()
    expected = next(line.split()[0] for line in checksums.splitlines() if line.split()[-1] == name)
    archive = get_bytes(base + name, 80_000_000)
    actual = hashlib.sha256(archive).hexdigest()
    if actual != expected:
        raise RuntimeError('Official Node release checksum mismatch')
    target = Path(tempfile.mkdtemp(prefix='makefun-node-')) / 'node'
    with tarfile.open(fileobj=io.BytesIO(archive), mode='r:xz') as package:
        member = package.getmember(f'node-{tag}-linux-x64/bin/node')
        if not member.isfile():
            raise RuntimeError('Expected a regular Node executable in the verified archive')
        source = package.extractfile(member)
        if source is None:
            raise RuntimeError('Node executable missing')
        target.write_bytes(source.read())
    target.chmod(0o700)
    report['node_source'] = 'verified official Node 22 release'
    report['node_archive_sha256'] = actual
    return str(target)


def check_url(url: str) -> dict:
    try:
        data = get_bytes(url)
        return {'http_status': 200, 'bytes_received': len(data)}
    except urllib.error.HTTPError as error:
        return {'http_status': error.code}
    except Exception as error:
        return {'error_type': type(error).__name__}


try:
    node = ensure_node()
    report['node'] = version(node)
    artifact = OUTPUT / 'node-result.json'
    code = ('const fs=require("node:fs");const v={value:21*2};'
            'fs.writeFileSync(process.argv[1],JSON.stringify(v));'
            'process.stdout.write(JSON.stringify(v));')
    result = subprocess.run([node, '-e', code, str(artifact)], check=True,
                            capture_output=True, text=True, timeout=20)
    assert json.loads(result.stdout) == {'value': 42}
    assert json.loads(artifact.read_text()) == {'value': 42}
    payload = b'makefun-kaggle-preflight-v1:42\n'
    (OUTPUT / 'deterministic-result.txt').write_bytes(payload)
    report['artifact_sha256'] = hashlib.sha256(payload).hexdigest()
    report['node_child_execution'] = True
    report['cpu_execution_passed'] = True
    report['network'] = {
        'github_public_source': check_url('https://raw.githubusercontent.com/ai2chiuo/makefun-cloud-workbench/main/README.md'),
        'makefun_public_requirements': check_url('https://make.fun/api/competitions/tiny-stack-vm-01-run-20261122/requirements'),
        'openai_public_discovery': check_url('https://auth.openai.com/.well-known/openid-configuration'),
    }
except Exception as error:
    report['error_type'] = type(error).__name__
    raise
finally:
    report['finished_at_utc'] = time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())
    (OUTPUT / 'probe-report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report, indent=2))
