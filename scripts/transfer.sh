#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# transfer.sh – Pull files from an old Mac over Thunderbolt (or any SSH link)
#
# Usage:
#   bash scripts/transfer.sh <host>                  # transfer everything
#   bash scripts/transfer.sh --dry-run <host>         # preview only
#   bash scripts/transfer.sh --only ssh,gpg <host>    # specific groups
#   bash scripts/transfer.sh --skip workspace <host>  # skip large groups
#
# Prerequisites (on the OLD Mac):
#   1. System Settings → General → Sharing → Remote Login → ON
#   2. Connect Thunderbolt cable between the two Macs
#   3. System Settings → Network → Thunderbolt Bridge should appear
#      (link-local IPs are assigned automatically, or set manual IPs)
###############################################################################

title() { printf "\n\033[1;36m==> %s\033[0m\n" "$*"; }
note() { printf "\033[0;33m[!] %s\033[0m\n" "$*"; }
ok() { printf "\033[0;32m  ✓ %s\033[0m\n" "$*"; }
err() { printf "\033[0;31m  ✗ %s\033[0m\n" "$*" >&2; }

DRY_RUN=0
ONLY=""
SKIP=""
REMOTE_HOST=""
REMOTE_USER=""

usage() {
	cat <<-'EOF'
		Usage: transfer.sh [OPTIONS] <user@host | host>

		Options:
		  --dry-run, -n     Preview rsync commands without transferring
		  --only GROUPS     Comma-separated list of groups to transfer
		  --skip GROUPS     Comma-separated list of groups to skip
		  -h, --help        Show this help

		Groups: ssh, gpg, aws, kube, docker, workspace, cursor, history, misc, snoodev-ssh

		Example:
		  transfer.sh --dry-run george.leontiev@169.254.47.1
		  transfer.sh --skip workspace 192.168.2.1
		  transfer.sh --only ssh,gpg,history old-mac.local
	EOF
	exit 0
}

while [[ $# -gt 0 ]]; do
	case "$1" in
		--dry-run | -n) DRY_RUN=1 ;;
		--only)
			shift
			ONLY="$1"
			;;
		--skip)
			shift
			SKIP="$1"
			;;
		-h | --help) usage ;;
		-*)
			err "Unknown option: $1"
			usage
			;;
		*)
			REMOTE_HOST="$1"
			;;
	esac
	shift
done

if [ -z "$REMOTE_HOST" ]; then
	err "No remote host specified"
	usage
fi

if [[ $REMOTE_HOST == *@* ]]; then
	REMOTE_USER="${REMOTE_HOST%%@*}"
	REMOTE_HOST="${REMOTE_HOST#*@}"
fi

SSH_TARGET="${REMOTE_USER:+${REMOTE_USER}@}${REMOTE_HOST}"
REMOTE_HOME=""

should_run() {
	local group="$1"
	if [ -n "$ONLY" ]; then
		echo ",$ONLY," | grep -q ",$group," && return 0 || return 1
	fi
	if [ -n "$SKIP" ]; then
		echo ",$SKIP," | grep -q ",$group," && return 1 || return 0
	fi
	return 0
}

SSH_OPTS=(-o ConnectTimeout=30 -o ConnectionAttempts=3)
RSYNC_BASE=(rsync -avz --progress -e "ssh -o ConnectTimeout=30 -o ConnectionAttempts=3")
if [ "$DRY_RUN" -eq 1 ]; then
	RSYNC_BASE+=(--dry-run)
fi

sync_dir() {
	local label="$1" remote_path="$2" local_path="$3"
	shift 3
	local extra_args=("$@")

	title "Transferring: $label"

	if ! ssh "${SSH_OPTS[@]}" "$SSH_TARGET" "test -d '$remote_path' || test -f '$remote_path'" 2>/dev/null; then
		note "$remote_path does not exist on remote – skipping"
		return 0
	fi

	local size
	size=$(ssh "${SSH_OPTS[@]}" "$SSH_TARGET" "du -sh '$remote_path' 2>/dev/null | cut -f1" || echo "unknown")
	echo "  Remote size: $size"

	mkdir -p "$local_path"

	# Trailing slash on remote_path ensures contents are synced into local_path
	[[ $remote_path != */ ]] && remote_path="${remote_path}/"

	"${RSYNC_BASE[@]}" "${extra_args[@]}" "$SSH_TARGET:$remote_path" "$local_path/"
	ok "$label done"
}

sync_files() {
	local label="$1" local_dir="$2"
	shift 2
	local remote_files=("$@")

	title "Transferring: $label"
	mkdir -p "$local_dir"

	for rf in "${remote_files[@]}"; do
		if ! ssh "${SSH_OPTS[@]}" "$SSH_TARGET" "test -f '$rf'" 2>/dev/null; then
			note "$rf does not exist on remote – skipping"
			continue
		fi
		"${RSYNC_BASE[@]}" "$SSH_TARGET:$rf" "$local_dir/"
	done
	ok "$label done"
}

###############################################################################
# Pre-flight checks
###############################################################################

title "Pre-flight checks"

echo "Testing SSH connectivity to $SSH_TARGET ..."
echo "(You may be prompted to accept a host fingerprint and/or enter a password)"

if ! ssh "${SSH_OPTS[@]}" "$SSH_TARGET" "echo ok"; then
	err "Cannot connect to $SSH_TARGET via SSH"
	cat <<-'EOF'

		Troubleshooting:
		  1. On the OLD Mac: System Settings → General → Sharing → Remote Login → ON
		  2. Check Thunderbolt Bridge is active: System Settings → Network
		  3. Find the old Mac's IP: run 'ifconfig bridge0' on it
		  4. Try: ssh <user>@<ip> manually first
	EOF
	exit 1
fi
ok "SSH connection successful"

REMOTE_HOME=$(ssh "${SSH_OPTS[@]}" "$SSH_TARGET" 'echo $HOME')
echo "  Remote home: $REMOTE_HOME"

if [ "$DRY_RUN" -eq 1 ]; then
	note "DRY RUN – no files will actually be transferred"
fi

###############################################################################
# Transfer groups
###############################################################################

EXCLUDE_COMMON=(--exclude '.DS_Store')

# --- SSH ---
if should_run ssh; then
	sync_dir "SSH keys & config" "$REMOTE_HOME/.ssh" "$HOME/.ssh" \
		"${EXCLUDE_COMMON[@]}" --exclude 'agent'
fi

# --- GPG ---
if should_run gpg; then
	sync_dir "GPG keyring" "$REMOTE_HOME/.gnupg" "$HOME/.gnupg" \
		"${EXCLUDE_COMMON[@]}" --exclude 'S.gpg-agent*' --exclude 'S.scdaemon'
fi

# --- AWS ---
if should_run aws; then
	sync_dir "AWS config" "$REMOTE_HOME/.aws" "$HOME/.aws" \
		"${EXCLUDE_COMMON[@]}"
fi

# --- Kube ---
if should_run kube; then
	sync_dir "Kubernetes config" "$REMOTE_HOME/.kube" "$HOME/.kube" \
		"${EXCLUDE_COMMON[@]}" --exclude 'cache' --exclude 'http-cache'
fi

# --- Docker ---
if should_run docker; then
	sync_files "Docker config" "$HOME/.docker" \
		"$REMOTE_HOME/.docker/config.json"
fi

# --- Workspace ---
if should_run workspace; then
	title "Workspace size estimate"
	ws_size=$(ssh "${SSH_OPTS[@]}" "$SSH_TARGET" "du -sh '$REMOTE_HOME/workspace' 2>/dev/null | cut -f1" || echo "unknown")
	echo "  ~/workspace on remote: $ws_size"
	note "This may take a while. Use --skip workspace to skip, or --only workspace to run alone."

	sync_dir "Workspace" "$REMOTE_HOME/workspace" "$HOME/workspace" \
		"${EXCLUDE_COMMON[@]}" \
		--exclude 'node_modules' \
		--exclude '__pycache__' \
		--exclude '.venv' \
		--exclude 'venv' \
		--exclude '.tox' \
		--exclude '.mypy_cache' \
		--exclude '.pytest_cache' \
		--exclude 'target' \
		--exclude '.build'
fi

# --- Cursor ---
if should_run cursor; then
	sync_files "Cursor config" "$HOME/.cursor" \
		"$REMOTE_HOME/.cursor/mcp.json" \
		"$REMOTE_HOME/.cursor/argv.json"
	sync_dir "Cursor skills" "$REMOTE_HOME/.cursor/skills-cursor" "$HOME/.cursor/skills-cursor" \
		"${EXCLUDE_COMMON[@]}"
fi

# --- Shell history ---
if should_run history; then
	sync_files "Shell history" "$HOME" \
		"$REMOTE_HOME/.zsh_history" \
		"$REMOTE_HOME/.bash_history" \
		"$REMOTE_HOME/.python_history"
fi

# --- Misc dotfiles (not in the dotfiles repo) ---
if should_run misc; then
	sync_files "Misc dotfiles" "$HOME" \
		"$REMOTE_HOME/.claude.json"
fi

# --- Snoodev SSH config ---
if should_run snoodev-ssh; then
	sync_dir "Snoodev SSH config" "$REMOTE_HOME/src/ssh-config" "$HOME/src/ssh-config" \
		"${EXCLUDE_COMMON[@]}"
fi

###############################################################################
# Post-transfer permission hardening
###############################################################################

title "Fixing permissions"

if [ -d "$HOME/.ssh" ]; then
	if [ "$DRY_RUN" -eq 1 ]; then
		echo "+ chmod 700 ~/.ssh"
		echo "+ chmod 600 ~/.ssh/id_* ~/.ssh/config"
		echo "+ chmod 644 ~/.ssh/*.pub"
	else
		chmod 700 "$HOME/.ssh"
		find "$HOME/.ssh" -name 'id_*' ! -name '*.pub' -exec chmod 600 {} + 2>/dev/null || true
		find "$HOME/.ssh" -name '*.pub' -exec chmod 644 {} + 2>/dev/null || true
		[ -f "$HOME/.ssh/config" ] && chmod 600 "$HOME/.ssh/config"
		ok "SSH permissions fixed"
	fi
fi

if [ -d "$HOME/.gnupg" ]; then
	if [ "$DRY_RUN" -eq 1 ]; then
		echo "+ chmod 700 ~/.gnupg"
		echo "+ chmod 600 ~/.gnupg/private-keys-v1.d/*"
	else
		chmod 700 "$HOME/.gnupg"
		find "$HOME/.gnupg/private-keys-v1.d" -type f -exec chmod 600 {} + 2>/dev/null || true
		ok "GPG permissions fixed"
	fi
fi

###############################################################################
# Switch dotfiles remote to SSH (now that keys are in place)
###############################################################################

if [ "$DRY_RUN" -eq 0 ] && [ -f "$HOME/.ssh/id_ed25519" ]; then
	dotfiles_remote=$(git -C "$HOME" remote get-url origin 2>/dev/null || true)
	if [[ $dotfiles_remote == https://github.com/* ]]; then
		ssh_url="${dotfiles_remote/https:\/\/github.com\//git@github.com:}"
		title "Switching dotfiles remote to SSH"
		git -C "$HOME" remote set-url origin "$ssh_url"
		ok "origin → $ssh_url"
	fi
fi

###############################################################################
# Summary
###############################################################################

title "Transfer complete"

if [ "$DRY_RUN" -eq 1 ]; then
	note "This was a dry run. Re-run without --dry-run to actually transfer files."
else
	cat <<-'EOS'
		Next steps:
		  1. Run install.sh to set up Homebrew, symlinks, and services:
		       bash install.sh --skip-services
		  2. Grant Accessibility permissions (System Settings → Privacy & Security)
		  3. Re-run install.sh to start services:
		       bash install.sh
		  4. Authenticate CLI tools:
		       gh auth login
		       aws configure  (or verify ~/.aws/config)
		  5. Recreate Python venv if needed:
		       python3 -m venv ~/workspace/venv
	EOS
fi
