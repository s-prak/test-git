if ls | grep -Eq '^sbom-v[0-9]+\.[0-9]+\.[0-9]+\.csv$'; then
    echo "Found SBOM file"
    rm -f sbom-*.csv
    # Generate new SBOM
    if [ -f yarn.lock ]; then
    echo "Generating SBOM using Yarn"
    npx -y --package @mojaloop/ml-depcheck-utility@1.1.1 generate-sbom-yarn
    else
    echo "Generating SBOM using NPM"
    npx -y --package @mojaloop/ml-depcheck-utility@1.1.1 generate-sbom-npm
    fi
    git add .
    git commit -m "chore(sbom): update $sbom_file [skip ci]" || echo "No changes to commit"
    git push origin main || echo "Git push failed"
else
    echo "No matching sbom-<version>.csv found. Skipping SBOM generation."
fi