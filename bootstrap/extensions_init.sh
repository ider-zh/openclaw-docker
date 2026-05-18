## Load top-level .env for local testing when NOT running inside a container
# When running inside Docker, envs are provided by docker-compose `env_file` or the container environment,
# so sourcing the host .env is unnecessary and may fail (file not mounted). Detect container by /.dockerenv.
if [ ! -f /.dockerenv ] && [ -f "$(dirname "$0")/../.env" ]; then
  set -o allexport
  . "$(dirname "$0")/../.env"
  set +o allexport
fi

# Defaults (can be overridden via .env or docker-compose env_file)
OPENCLAW_API_KEY="${OPENCLAW_CUSTOM_API_KEY:-pk-test-key}"
OPENCLAW_BASE_URL="${OPENCLAW_CUSTOM_BASE_URL:-https://api.toop.ai/v1}"
OPENCLAW_COMPAT="${OPENCLAW_CUSTOM_COMPATIBILITY:-openai}"
OPENCLAW_MODEL="${OPENCLAW_CUSTOM_MODEL_ID:-mimo-v2.5}"
OPENCLAW_PROVIDER_ID="${OPENCLAW_CUSTOM_PROVIDER_ID:-toop}"
GATEWAY_BIND="${OPENCLAW_GATEWAY_BIND:-lan}"
GATEWAY_PORT="${OPENCLAW_GATEWAY_PORT:-18789}"

# Build skip flags based on environment variables (default to true to preserve previous behavior)
SKIP_FLAGS=""
[ "${OPENCLAW_SKIP_UI:-true}" = "true" ] && SKIP_FLAGS="$SKIP_FLAGS --skip-ui"
# [ "${OPENCLAW_SKIP_HEALTH:-true}" = "true" ] && SKIP_FLAGS="$SKIP_FLAGS --skip-health"
# [ "${OPENCLAW_SKIP_CHANNELS:-true}" = "true" ] && SKIP_FLAGS="$SKIP_FLAGS --skip-channels"
# [ "${OPENCLAW_SKIP_HOOKS:-true}" = "true" ] && SKIP_FLAGS="$SKIP_FLAGS --skip-hooks"
# [ "${OPENCLAW_SKIP_SEARCH:-true}" = "true" ] && SKIP_FLAGS="$SKIP_FLAGS --skip-search"
# [ "${OPENCLAW_SKIP_SKILLS:-true}" = "true" ] && SKIP_FLAGS="$SKIP_FLAGS --skip-skills"
# [ "${OPENCLAW_SKIP_DAEMON:-true}" = "true" ] && SKIP_FLAGS="$SKIP_FLAGS --skip-daemon"

if [ ! -d /home/node/.openclaw ] || [ -z "$(find /home/node/.openclaw -mindepth 1 \( -name '.gitkeep' -o -name '.gitignore' \) -prune -o -print -quit 2>/dev/null)" ]; then
  openclaw onboard \
    --non-interactive \
    --mode local \
    --accept-risk \
    --flow quickstart \
    --auth-choice custom-api-key \
    --custom-api-key "$OPENCLAW_API_KEY" \
    --custom-base-url "$OPENCLAW_BASE_URL" \
    --custom-compatibility "$OPENCLAW_COMPAT" \
    --custom-model-id "$OPENCLAW_MODEL" \
    --custom-provider-id "$OPENCLAW_PROVIDER_ID" \
    --gateway-bind "$GATEWAY_BIND" \
    --gateway-port "$GATEWAY_PORT" $SKIP_FLAGS
fi

install_if_missing() {
  pkg="$1"
  id="$2"
  path="$3"

  if [ -n "$path" ] && [ -d "/home/node/.openclaw/npm/node_modules/$path" ]; then
    echo "Plugin '$id' 已存在于 /home/node/.openclaw/npm/node_modules/$path, 跳过."
    return
  fi

  if openclaw plugins list --json 2>/dev/null | grep -q '"id": "'$id'"'; then
    echo "Plugin '$id' 已安装，跳过."
  else
    echo "Installing plugin '$pkg'..."
    timeout 300 openclaw plugins install --dangerously-force-unsafe-install "$pkg" || true
  fi
}

mkdir -p /home/node/.openclaw/extensions
cd /home/node/.openclaw/extensions
install_if_missing @soimy/dingtalk dingtalk @soimy/dingtalk
install_if_missing @tencent-connect/openclaw-qqbot@latest openclaw-qqbot @tencent-connect/openclaw-qqbot
install_if_missing @tencent-weixin/openclaw-weixin openclaw-weixin @tencent-weixin/openclaw-weixin
  