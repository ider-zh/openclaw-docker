if [ ! -d /home/node/.openclaw ] || [ -z "$(ls -A /home/node/.openclaw 2>/dev/null)" ]; then
  openclaw onboard \
    --non-interactive \
    --accept-risk \
    --flow quickstart \
    --auth-choice custom-api-key \
    --custom-api-key pk-test-key \
    --custom-base-url https://api.toop.ai/v1 \
    --custom-compatibility openai \
    --custom-model-id mimo-v2.5 \
    --skip-ui \
    --skip-health \
    --skip-channels \
    --skip-hooks \
    --skip-search \
    --skip-skills \
    --skip-daemon
fi

install_if_missing() {
  pkg="$1"
  id="$2"
  path="$3"

  if [ -n "$path" ] && [ -d "/home/node/.openclaw/npm/node_modules/$path" ]; then
    echo "Plugin '$id' 已存在于 /home/node/.openclaw/npm/node_modules/$path，跳过."
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
  