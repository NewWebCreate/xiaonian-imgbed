# 小念图床 · Vercel 部署版

纯前端图床。图片字节经 **Vercel Serverless 函数**写入 GitHub 仓库，外链走 jsDelivr CDN；图片链接储存在你自己的 `json.wunian.fun`。

## 架构

```
浏览器选图 → POST /api/upload（Vercel 函数）
         → 服务端用 api/upload.js 内写死的配置（含 GitHub PAT）把图片写入仓库 xiaonian-imgbed/img/
         → 返回 cdn.jsdelivr.net/gh/... 外链
         → 外链同时写入 json.wunian.fun/api/imgku 的 Image-link 数组（沿用原项目链接储存逻辑）
```

- 免费、免备案、免银行卡。
- **前端不含任何密钥**：GitHub PAT 只写在 `api/upload.js`（Vercel 服务端函数），浏览器永远拿不到，也不会触发 GitHub 密钥扫描拦截。
- **无需在 Vercel 配环境变量**：`owner / repo / branch / prefix / token` 均已写死在 `api/upload.js` 顶部 `GH` 对象，部署即可用。若日后设置了同名环境变量，会自动优先采用环境变量的值。

## 一键部署到 Vercel

1. 仓库 `https://github.com/NewWebCreate/xiaonian-imgbed-site`（**已设为 private**，用于保护服务端源码中的 token）。
2. 打开 https://vercel.com → **Add New → Project** → 导入该仓库（private 仓库 Vercel 同样可导入，已授权即可）。
3. Framework Preset 选 **Other**，Root Directory 保持 `/`，Build Command / Output 留空。
4. **无需配置任何环境变量**，直接点 **Deploy**，约 30 秒后拿到 `xxx.vercel.app` 即可使用。

> 若之前导入的是公开版本，建议在 Vercel 项目里 **Remove** 旧的，重新导入这个 private 仓库，或确认部署源指向 `xiaonian-imgbed-site`。

## 自定义域名（wunian.fun 子域）

Vercel 项目 **Settings → Domains** 添加如 `img.wunian.fun`；再到阿里云 DNS 给该子域加一条 CNAME 指向 `cname.vercel-dns.com`，等待 Vercel 校验通过。

## 本地预览

```bash
python -m http.server 8000
# 浏览器打开 http://127.0.0.1:8000
```

本地没有 `/api/upload`，上传会自动回退到前端直传——此时需在 `script.js` 顶部 `GH_CONFIG.token` 填入你的 PAT。

## 配置项

- `api/upload.js` 顶部 `GH` 对象：`owner` / `repo` / `branch` / `prefix` / `token`（已写死，部署即用）。
- `script.js` 顶部 `GH_CONFIG`：本地直传回退用，仅 `owner` / `repo` / `branch` / `pathPrefix` 有用（部署版无需填 token）。
- 图片链接储存在 `json.wunian.fun/api/imgku`（`API_BASE`，位于 script.js 顶部），登录态同样在此。

## 上传优化（规避 504 超时）

- 小于 1MB 的图片走 **Contents API 单次 PUT**（1 次网络往返，最快）。
- 超过 1MB 自动回退 **Git Data API**（支持任意大小）。
- 每次 GitHub 请求都带 15 秒超时，接口变慢会立即失败报错，而不是挂到上限被 Vercel 掐成 504。
- `vercel.json` 已把函数 `maxDuration` 设为 60 秒（Hobby 上限）。

## 安全

- token 仅在 Vercel 服务端（`api/upload.js`），不进前端、不进公开仓库（本仓库已 private）。
- 建议日后将 token 换成 **fine-grained PAT 仅授权 `xiaonian-imgbed` 单一仓库**，进一步收窄权限；保留 private 仓库可避免源码中的 token 被公开读取。

## 弃用说明

原第三方 ImgBB 上传、以及 Cloudflare R2（强制绑银行卡，已弃用）方案均已移除，当前仅保留 GitHub 直传（经 Vercel 代理）。

## 使用指南

### 页面入口

- **上传页（默认）**：拖拽或点选图片上传，进度条实时显示百分比。
- **图库页**：查看本地（浏览器）与云端（登录后）已上传图片，支持点击放大、复制直链、下载、批量删除。
- **背景设置**：切换站点背景图（内置多张，或随机背景）。
- **我的**：未登录时提示去登录；登录后可查看云端存储空间与账号信息。

### 催促登录提示

- **电脑端**：未登录时，每次进入网站都会在「用户名」下方弹出悬浮窗，带关闭叉号；登录后自动隐藏。
- **手机端**：页面加载后在屏幕底部显示悬浮登录提示，可一键「去登录」或关闭。
- 关闭仅对本次会话生效，**下次进入仍会再次提示**（符合「每次进入均显示」的设计）。

### Hash 路由

支持通过 URL hash 直达指定页面，方便分享与回退：

| 链接 | 进入页面 |
|------|----------|
| `index#upload` 或 `/` | 上传页 |
| `index#gallery` | 图库页 |
| `index#bg` | 背景设置 |
| `index#mine` | 我的 |

例：访问 `https://img.wunian.fun/index#mine` 直接进入「我的」页面。浏览器前进/后退按钮也会随 hash 切换页面。
（已开启 Vercel `cleanUrls`，网页地址无需 `.html`：`index.html` → `/index`，`login.html` → `/login`。）

### 404 重定向

- **非法 hash**（如 `#abc` 等未定义路由）：自动跳转回主页（上传页）。
- **服务器级未知路径**（如访问不存在的 `.html`）：由仓库根目录 `404.html` 自动重定向回主页。

### 其他细节

- **网页后缀隐藏**：`vercel.json` 已开启 `cleanUrls`，访问网页无需输入 `.html`（`login.html` → `/login`，`index.html` → `/index`；首页仍可用 `/`）。图片直链本身保留原文件名后缀，不受影响。
- **上传进度**：进度从 0% 起随上传平滑递增，完成后缓动到 100%，不会出现中途突跳到满格。
- **页面美化**：毛玻璃头部、按钮悬浮动效、卡片阴影与圆角、进度条辉光等视觉优化。

## 本地预览

```bash
python -m http.server 8000
# 浏览器打开 http://127.0.0.1:8000
```

本地没有 `/api/upload`，上传会自动回退到前端直传——此时需在 `script.js` 顶部 `GH_CONFIG.token` 填入你的 PAT。

