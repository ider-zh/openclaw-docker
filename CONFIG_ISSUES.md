# Configuration Issues by Version

这个文件用于记录每个 `openclaw` 版本相关的配置坑、兼容性问题和调试经验。

## 记录格式建议

- 版本：`v2026.5.12`
- 场景：例如 `docker-compose / .env / bootstrap/extensions_init.sh / openclaw/openclaw.json`
- 问题：简要描述发生了什么
- 解决方案：如何修复，或当前可行的 workaround
- 备注：必要时补充其他信息
- 示例配置目录：`config-samples/openclaw/`

### bootstrap/extensions_init.sh

- 问题：当宿主目录里仅有 `.gitkeep` 时，原始空目录判断误判导致 `openclaw onboard` 不执行。
- 解决方案：忽略 `.gitkeep` / `.gitignore` 后再判断目录是否“真正为空”。
- 备注：可将目录初始化逻辑与 `docker-compose` 的 `env_file` 配置一起使用。

---

## v2026.5.12

### `openclaw/openclaw.json`

- 问题：使用私有IP部署的 provider, 会出现 `SsrFBlockedError`。
- 解决方案：添加 `models.providers.your_provider.request.allowPrivateNetwork: true`。

### `openclaw/identity/device.json`
- 备注: `openclaw-weixin` 凭证目录
- example:
```json
{
  "version": 1,
  "deviceId": "string",
  "publicKeyPem": "-----BEGIN PUBLIC KEY-----\nstring\n-----END PUBLIC KEY-----\n",
  "privateKeyPem": "-----BEGIN PRIVATE KEY-----\nMstring\n-----END PRIVATE KEY-----\n",
  "createdAtMs": 1779061595461
}
```

