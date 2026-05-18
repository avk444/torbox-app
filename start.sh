name: Sync to Hugging Face Hub
on:
  push:
    branches: [automation-engine]
  workflow_dispatch:

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Nuclear Purge of Binaries & Reset History
        run: |
          # 1. Find and completely destroy ALL image/binary assets across all folders
          find . -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.ico" -o -name "*.gif" -o -name "*.svg" \) -print -delete

          # 2. Wipe out the git tracking history completely to clear the cache
          rm -rf .git

          # 3. Re-initialize a 100% clean, text-only repository tracking state
          git init
          git config user.name "github-actions"
          git config user.email "github-actions@github.com"
          git checkout -b main
          git add .
          git commit -m "Pure text automation deployment package"

      - name: Push to hub
        env:
          HF_TOKEN: ${{ secrets.HF_TOKEN }}
        run: |
          git push --force https://Avk44:$HF_TOKEN@huggingface.co/spaces/Avk44/torbox-manager main:main
