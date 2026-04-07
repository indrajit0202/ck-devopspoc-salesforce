# --------------------------------------------------------------------------------------------------------------
# Description : The purpose of this shell script is to install the required dependencies for the CI/CD pipeline execution in GitHub Actions environment
# Author : Indrajit Pal
# Date : 07/04/2026
# --------------------------------------------------------------------------------------------------------------

set -e  # exit immediately if any command fails

# ── Salesforce CLI & plugins ──
if [ "$SF_CACHE_HIT" != "true" ]; then
  echo ">>> Installing Salesforce CLI..."
  npm install @salesforce/cli@latest -g

  echo ">>> Installing sfdx-git-delta..."
  echo 'y' | /usr/local/bin/sf plugins install sfdx-git-delta

  echo ">>> Installing SFDMU..."
  /usr/local/bin/sf plugins install sfdmu

  echo ">>> Installing SFDX Scanner..."
  /usr/local/bin/sf plugins install @salesforce/sfdx-scanner

  echo ">>> Installing Salesforce Code Analyzer..."
  /usr/local/bin/sf plugins install code-analyzer@latest

  echo ">>> Installing Skuid SFDX..."
  echo 'y' | /usr/local/bin/sf plugins install skuid-sfdx
else
  echo "✓ SF CLI & plugins restored from cache"
fi

# ── Java 17 ──
if [ "$JAVA_CACHE_HIT" != "true" ]; then
  echo ">>> Installing Java 17..."
  sudo apt-get update -qq
  sudo apt-get install -y openjdk-17-jre-headless
  sudo apt-get clean
else
  echo "✓ Java 17 restored from cache"
fi

# ── Always register PATH & env (for next steps) ──
echo "/usr/local/bin" >> $GITHUB_PATH
echo "SF_HOME=$HOME/.config/sf" >> $GITHUB_ENV
echo "JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64" >> $GITHUB_ENV
echo "/usr/lib/jvm/java-17-openjdk-amd64/bin" >> $GITHUB_PATH

# ── Verify ──
echo "--- Versions ---"
/usr/local/bin/sf --version
/usr/local/bin/sf plugins
/usr/lib/jvm/java-17-openjdk-amd64/bin/java -version