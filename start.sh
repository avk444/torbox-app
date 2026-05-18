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

      - name: Purge Binaries & Flatten History
        run: |
          # 1. Strip out the conflicting branding images
          rm -f public/icons/icon-512x512.png
          rm -f src/app/android-chrome-512x512.png
          rm -f public/android-chrome-512x512.png 2>/dev/null || true

          # 2. Wipe the local git tracking history in the worker
          rm -rf .git

          # 3. Re-initialize as a completely flat, clean commit
          git init
          git config user.name "github-actions"
          git config user.email "github-actions@github.com"
          git checkout -b main
          git add .
          git commit -m "Clean automation engine deployment"

      - name: Push to hub
        env:
          HF_TOKEN: ${{ secrets.HF_TOKEN }}
        run: |
          git push --force https://Avk44:$HF_TOKEN@huggingface.co/spaces/Avk44/torbox-manager HEAD:refs/heads/main
