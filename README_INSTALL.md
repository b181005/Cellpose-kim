## One-time environment installer (Windows PowerShell)

This repository includes a small PowerShell script to create a Python virtual environment and install packages once.

Files added
- `scripts/install_env.ps1` — PowerShell script that creates a venv, installs packages from `requirements.txt` (if present), and writes a marker so the installer won't run again unless forced.
- `requirements.txt` — example requirements. Edit as needed.

How to run (PowerShell)
1. Open PowerShell in the repository root (for example, `c:\Users\...\Cellpose-kim`).
2. Run the installer:

   .\scripts\install_env.ps1

   To force re-run (ignores existing marker):

   .\scripts\install_env.ps1 -Force

3. Activate the environment:

   Set-Location .
   .\.venv\Scripts\Activate.ps1

4. Run your Python scripts or Jupyter. Deactivate by running `deactivate`.

Conda alternative (if you use conda)

1. Create environment with a name (example `cellpose-env`):

   conda create -n cellpose-env python=3.10 -y
   conda activate cellpose-env
2. Install from requirements:

   pip install -r requirements.txt

Notes
- The installer expects `python` on PATH. If not present, install Python from https://www.python.org/ or use the Microsoft Store installer.
- If you need GPU-enabled packages (e.g., PyTorch with CUDA), follow the upstream installation instructions for those packages rather than using the generic `pip install`.
