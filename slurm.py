#!/usr/bin/env python3
import subprocess
import sys
import shlex
import re
from pathlib import Path
from glob import glob

SBATCH_ID_RE = re.compile(r"Submitted batch job (\d+)")
PARSABLE_RE  = re.compile(r"^\s*(\d+)(?:;\d+)?\s*$", re.MULTILINE)

def _run(cmd, check=True, text=True):
    return subprocess.run(cmd, capture_output=True, check=check, text=text)

def submit_via_run(run_sh_path: str, script_path: str, script_args=None, use_parsable=True):
    """
    Submit a job using your run.sh wrapper and return (job_id, stdout, stderr).
    `script_args` is a list of extra CLI args passed to the sbatch job script.
    """
    if script_args is None:
        script_args = []

    # Build command: run.sh [--parsable] <your_sbatch_script> [args...]
    cmd = [run_sh_path]
    if use_parsable:
        cmd.append("--parsable")  # sbatch prints only the jobid (or jobid;array)
    cmd.append(script_path)
    cmd.extend(script_args)

    # Execute
    res = _run(cmd)
    out = (res.stdout or "").strip()
    err = (res.stderr or "").strip()

    # Try to parse job id (handle --parsable and normal formats)
    job_id = None
    m = PARSABLE_RE.search(out)
    if m:
        job_id = m.group(1)
    else:
        m = SBATCH_ID_RE.search(out)
        if m:
            job_id = m.group(1)

    if not job_id:
        # include stderr to help debugging
        raise RuntimeError(
            f"Could not parse Job ID from run.sh/sbatch output.\nSTDOUT:\n{out}\nSTDERR:\n{err}"
        )

    return job_id, out, err

def get_logdir_from_setup(project_root: Path) -> Path:
    """
    Source code/00_setup.sh in a bash login shell and echo $LOGDIR.
    Returns a Path (may raise if not found).
    """
    bash_cmd = f'source "{project_root}/code/00_setup.sh" >/dev/null 2>&1; printf "%s" "$LOGDIR"'
    res = _run(["bash", "-lc", bash_cmd])
    logdir = (res.stdout or "").strip()
    if not logdir:
        raise RuntimeError("Could not resolve $LOGDIR by sourcing code/00_setup.sh")
    return Path(logdir)

def find_logs_for_job(logdir: Path, job_id: str):
    """
    Your run.sh names logs like:
      $LOGDIR/%x-[<NOW>]-[%a]-OUT-[%J]
      $LOGDIR/%x-[<NOW>]-[%a]-ERR-[%J]
    We don’t know %x, %a, or the NOW string, so we glob on *[jobid].
    Returns (out_logs, err_logs) lists (possibly empty).
    """
    out_glob = str(logdir / f"*OUT-[{job_id}]")
    err_glob = str(logdir / f"*ERR-[{job_id}]")
    return sorted(glob(out_glob)), sorted(glob(err_glob))

def main():
    if len(sys.argv) < 3:
        print("Usage:\n  python submit_via_run.py /path/to/run.sh /path/to/job_script.sh [script_args ...]")
        sys.exit(1)

    run_sh = sys.argv[1]
    job_script = sys.argv[2]
    job_args = sys.argv[3:]

    # Submit through your wrapper
    job_id, out, err = submit_via_run(run_sh, job_script, job_args, use_parsable=True)
    print(f"[OK] Submitted via run.sh -> Job ID: {job_id}")

    # Try to resolve $LOGDIR and show where logs will land
    try:
        project_root = Path(run_sh).resolve().parent.parent  # .../OrganizationAndAnnotationOfEkuaryoticGenomes
        logdir = get_logdir_from_setup(project_root)
        out_logs, err_logs = find_logs_for_job(logdir, job_id)
        if out_logs or err_logs:
            print("[INFO] Located matching log files:")
            for p in out_logs:
                print(f"  OUT: {p}")
            for p in err_logs:
                print(f"  ERR: {p}")
        else:
            print(f"[INFO] Logs will appear under: {logdir} (once SLURM opens them).")
    except Exception as e:
        print(f"[WARN] Could not resolve logs automatically: {e}")

if __name__ == "__main__":
    main()
